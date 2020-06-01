function [Tf,time,results,Tfw] = SEFEE(Z,obsA,obsB,tsteps,R,e)
%SEFEE recieves a 3D double array (tensor) Z along with additional input
%and returns a tensor of predicted time-steps. It works in a moving window fashion. 
% Example usage:
%       imagine Ztest is a tenosr of size 10 X 40 X 3000 which is our
%       actual data.
%       [Tf_test,time,result_test] = SEFEE(Ztest,1001,1086,500);
%       This code takes whode data Ztest and uses obsB-obsA+1 time-steps
%       for observed tensor and the rest to simulate actual arrivals. It then predicts 500 steps
%       in the future and uses 500 time-steps from Ztest to compare with Tf for accuracy. In
%       this case the X_obs would be of size 10 by 40 by 86. Tf will have
%       the size 10 X 40 X 500. the first slice to predict would be
%       time-step 1087 which will be compared to the actual 1087th tensor
%       slice for accuracy. 
%   INPUT:
%   - Z: input tensor, it is either a 3D array or a struct including a 3D array, the
%   side information and the dimensions as its objects. The code automatically detects if
%   we have submitted a 3D array or a struct. In former case, CP_ALS from tensor_toolbox is used while in latter 
%   CMTF_toolbox is used in which case the struct should comply with cmtf_check.m which verifies if the struct works with CMTF_toolbox.
%   - obsA and obsB: control the size of observed tensor. This is the subset of the
%   tensor data that is observed.  It is recommended to give large enough observed tensor to allow
%   for prediction algorithm to pick up time-of-day effects. But too large a observed tensor will hamper computation time.
% For example,
%   set obsA and obsB to a value that amounts to 1 week or multiple of weeks
%   depending on size of your other dimensions, the context (workload, scenario, usecase) and the time-bin used. For
%   example, if the data is 2-hour time-binned, then there are 84 2 hours
%   in a week, Autocorrelation function shifts the trace and I've seen in
%   practice if we add 2 more to the size it will accomodate up
%   to the desired (e.g. 84) time-of-day effect, so in the example we use
%   86 (84 +2). If the data is day binned, then an observed window amounting to a month would be a good consideration.
%   - tsteps: for how many time-steps you want to run the prediction/simulation. So
%   the way SEFEE works is, it predicts the next time-step and once the
%   actual data arrives, it shifts the observed window and repeats in a moving window fashion. So it
%   is possible to simulate multiple prediction steps without waiting for
%   actual arrival of data by giving an earlier portion of tensor as
%   observed data and then use the upcoming tensor slices as actual
%   arrivals.
%   R: decomposition rank to use for factorization of observed tensor . tensor decompositon is prone to
%   overfactoring, and finidng the rank of the tensor is an np-hard
%   problem, so it is strongly advised to use a small number of time-steps
%   (tstep) to run multiple predictions with various ranks and stop at the
%   rank that doesn't significantly improve accuracy. 
%   (OPTIONAL) if the user doesn't give R then 0 will be passed as R to prediction funciton(predict) and in this case
           % the prediction function would use the loose rank upper bound = min(IJ,JK,IK) as the rank where (I,J,K) are tensor dimensions.
           
%   Output:
%       - Tf: the forecasted tensor. Refer to example above for details
%       - Time: 
           
fprintf('SEFEE_local\n');
tic;
%toggles (flags)
count =0;
timer_o = 0; %one-time computations timer: this captures times taken prior to the first prediction. this includes computing the initial tod matrix.
timer_tps = 0; %this timer captures the total time taken to predict steps. 
%                For those steps that happen to coincide with the interval to update tod matrix,
%                the computation time to compute tod matrix is also
%                included in that step's time. This setting would inflate
%                tps (time-per-step) if the number of steps to predict is
%                not multiple of sint (tod update interval). For example,
%                imagine one time computation is 50 seconds, and we do this
%                computation every 20 steps, but if we set tsepts to 2,
%                then the tps will be high. Consequently, if we set sint to
%                a very low number (we update tod matrix more frequently
%                than needed) it causes tps to be high. I did not fix this
%                issue, because sint and tsteps are usually set
%                proportionally. However, you can set a separate timer for
%                only the portion of the step in which recomputatation
%                happens and then deduct that time from the total running
               % time and capture the recomputation time in a different variable.
dynamic = 1;  %if set to 0, the time-of-day values will not be updated when additional data comes.
htod = 1;   % heterogeneous time-of-day effect, if set to 0 the default s which 0 will be used and no per node error seasonality will be computed.
gs = 0; % Global time-of-day, if set to 1, the time effect e will be computed 
         % as a global setting for all errors and nodes for prediction.
         % Obviosuly gs is effective only if htod is set to 0. because
         % otherwise, heterogeneous time of day effect will be in effect. if both gs
         % and htod are set to 0, then the given e or the default e will
         % be used as global tod setting for all elements in the data.
lag = obsB-obsA-1; %the lag used for auto-correlation function to compute time-of-day effect. This is the largest possible lag that works 
                   %with obsB and obsA.
sint = lag; %interval to recompute time-of-day effect matrix (s), matters only if dynamic is set to 1 (On)
upsize = 5 * lag; %if the dynamic computation of tod is on, then this value will say how far back in time should
                  %we go for updating tod. We set this 3 times the
                  %lag for default to consider more recent values. This
                  %depends on the data at hand and context. 
%initialize       
if nargin <5
    R = 0; 
end
if nargin <6
    e =12; % (OPTIONAL) Default =12;  this is global setting for time-of-day effect e.g. if our 
           % data is Day-binned and e is set to 7 it triggers day of the week effect.
end
if nargin ==6  % If we have specifically given an arbitrary time effect "e" to be used globally, there is no point in calculating it.
    gs = 0;
end
s = 0; %time-of-day matrix is set to 0, and used as a simple flag, unless it is computed using acf. (if htod = 1, s will be a matrix)

%--------------------------
if isstruct(Z)
    D = Z.object{1};
    if isfield(Z,'miss')
        W= Z.miss{1}; %This is in case we want to assign different weights to different elements. The weighted version of tensor 
                       %decomposition is very sensitive to missing data, so
                       %if we apply this on the entire sparse dataset,
                       %overall the performance might be worse. I test this out on specific time-steps to just see as proof of concept 
                       %that it is possible to slightly improve decomposition accuracy (Not prediction accuracy necessarily) for certain I and J pairs
                       %while getting worse results for the rest. Plus you might want to increse the maximum iterations
                       %for which to run CP decomposition. At same iteration compared to non-weighted approach we might not have
                       %reached the same point in minimization since we have manipulated the weights. 
                       %so it is very hard and heuristic to compare the weighted and non-weighted approach. 
                       %What the weighted approach does is for those facor vector rows associated with
                       %higher weight, the CP decomposition tries to
                       %penalize decomposition performance more and try to decompose
                       %better. W tensor is added to minimization objective of tensor decomposition, where we try to minimize the difference
                       %between actual tensor and estimated factorized tensor. One important thing to consider is that if
                       %the rank used already results in the best possible
                       %decomposition, weight can't do anything extra.
                       %However, it is possible that the rank used for the
                       %entire process does not yield the best possible
                       %decomposition for certain rows (by rows I mean rows
                       %in resulting factor matrices). It is possible to
                       %test this part out for a specific subset of the
                       %tensor where it is more dense. For example, for prediction use the
                       %portion of tensor where the individual elements
                       %(node, errors) or (I,J) that we used a higher
                       %weight for is more dense. 
    end
else
    D = Z;
end

% COMPUTING INITIAL VALUES Using observed set (from beginning of data up to the end of observed tensor).  
if gs   % global time effect (only relevant if htod is off that is set to 0)
    [m2,s2] = acfhelper(D(:,:,1:obsB),lag);
    tabs2 = tabulate(s2(:));
    e = tabs2(tabs2(:,2)==max(tabs2(2:end,2))); %finding which lag is most popular and use it globally
end

if htod  % heter ToD effect: this is the initial computation of heterogeneous time-of-day effect.
    tic;
    fprintf('Computing Time-of-day effect from step 1 to %d . \n',obsB);
    [m,s] = acfhelper(D(:,:,1:obsB),lag); % s is the Time-of-day matrix of shape I X J that holds a separate Tod value for each element in tensor.
    fprintf('heterogeneous time-of-day effect computed in %.2f seconds\n',toc);
    %timer = timer + toc;
end

toc;
timer_o = timer_o + toc;

% the first 2 steps are predicted outside the loop to initialize Tf to be a
% tensor. It is also possible to just do this for 1 step and then use another if
% statement within the moving window loop to cat Tp1 with the first step
% from the loop only (if i==1), and then continue as is. 
tic;
Tp1 = predictSEF(Z,obsA,obsB,s,R,e);
toc;
    timer_tps = timer_tps + toc;
    count = count +1;
    fprintf('*** predicion of time-step [%d] finished in [%.2f] seconds.***\n',1,toc);
    
tic;
Tp2 = predictSEF(Z,obsA+1,obsB+1,s,R,e);
Tf = cat(3,Tp1,Tp2);
toc;
    timer_tps = timer_tps + toc;
    count = count +1;
    fprintf('*** predicion of time-step [%d] finished in [%.2f] seconds.***\n',2,toc);
% Moving window training process...

for i=2:tsteps-1
    tic;
    if dynamic
        if mod(i,sint)==0 % the part of code put here will be the dynamic part as for every sint steps the following variables
            if htod     % are recomputed and passed to proper functions.
                fprintf('Recomputing time-of-day effect matrix at iteration ( %d ) \n',i);
                [m,s]=acfhelper(D(:,:,obsA+i-upsize:obsB+i),lag);
            end
            if gs
                [m2,s2] = acfhelper(D(:,:,obsA+i-upsize:obsB+i),lag);
                tabs2 = tabulate(s2(:));
                %e = tabs2(find(tabs2(:,2)==max(tabs2(2:end,2))));
                e = tabs2(tabs2(:,2)==max(tabs2(2:end,2)));
            end
            %hitMiss3D(D(:,:,ta+1:ta+i-1),Tf);
        end
    end
    %if mod(i,100)==0   %to save the predicted tensor every 100 steps
       %fname = ['/home/ubuntu/data/Comparisons/Outputs/Checkpoint_t' num2str(tsteps) '_R' num2str(R) '_' num2str(obsA) '_' num2str(obsB) '_Iter_' num2str(i)];
       %save(fname,'Tf');
    %end
    Tpz = predictSEF(Z,obsA+i,obsB+i,s,R,e);
    Tf = cat(3,Tf,Tpz);
    elapsed = toc;
    fprintf('*** predicion of time-step [%d] finished in [%.2f] seconds.***\n',i+1,elapsed);
    timer_tps = timer_tps + elapsed;
    count = count +1;
end
fprintf('-------------------------\n');

Tfw = Tf; %only matters if it is weighted decomposition.

if isfield(Z,'miss')
    Tf = Tf.*W(:,:,obsB+1:obsB+tsteps);
end
results = accuracy(D(:,:,obsB+1:obsB+tsteps),round(Tf)); %saving the performance results at 0.5 threshold (round function).
tps = timer_tps/count;
time = timer_tps + timer_o;
fprintf("### Total time = %.3f seconds | Average time per step = %.3f seconds\n###", time, tps); 

end


