function [X,Y] = MVRFdataprep(T,G) 
%MVRFDATAPREP Recieves a tensor and makes the Multivariate Random Forest ready data. 
%   e is the error type to be predicted which is a single scalar 1,2,.,1369
%   T : raw data is the tensor of shape (I,J,time) I nodes, J error types
%   X : predictor variables/training data. Note this can also be used to
%   create the test data as well. all you need to do is to give a later
%   portion of T as input and also control the length of train/test set
%   with Xlen (more details below).
%   Y : Response variable / Class label / output
%   G : Optional input. Group of error types to be predicted. If specified,
%   the output set (response variables, will be from this group not all
%   error types.
%  Dimensions: if T is a [I X J X K] 3D array;   X is [(IK +1) X J] matrix  and
%  Y is [IK X J] matrix. 

%   Example usage: 
%       [Xtest_rf,Ytest_rf]= MVRFdataprep(Sample_tensor(:,:,1001:end))
%           having already set Xlen manually to the length of test set (i.e. 900)
%       [Xtrain_rf,Ytrain_rf]= MVRFdataprep(Sample_tensor);
%           having already set Xlen manually to the length of train set (i.e. 1000)
if nargin < 2
    G=[];
end
Xlen = 900; % The train/test dataset should include information from how many time-steps.
            % play with this variable to get your desired length for
            % training and test set. Be careful not to create overlapping
            % train and test set by controlling what portion of T you use
            % as input. e.g. use whole T from begining while setting Xlen
            % to 1000 to use the first 1000 time-steps to create training
            % set. And then use T(starting from 1001 time-step) with Xlen =
            % 900 to get a non-overlapping test set.You can use the same
            % periods for tensor SEFEE experiments as well and compare. Our
            % results on Sample dataset (not reported in paper: in paper
            % the results on real dataset is reported) was 71.7% precision
            % and 86.9% recall for MVRFdo and 86 and 92 percent for SEFEE
            % respecitvely for same period. (Note for SEFEE we do not use
            % entire first 1000 time-steps as observed tensor, only the
            % week leading up to 1000 (1000 - 86 up to 999 and start predicting from 1000)
            % refer to SEFEE.m for more details on that.
sz = size(T);

X = zeros(Xlen * sz(1),sz(2)+1); % +1 is to put the node number as the first column of the training data and test data.
if nargin < 2
    Y = zeros(Xlen * sz(1),sz(2));
else
    Y = zeros(Xlen * sz(1),length(G));
end
%Y=[];
s = 1;  % sample: this is the row index of X and Y.

for t=1:Xlen
    for i=1:sz(1)
        X(s,1) = i; % this is that "+1"
        X(s,2:end) = T(i,:,t);
        %Y(s)=T(i,e,t+1);
        if nargin <2
            Y(s,:)=T(i,:,t+1); % The response variables/labels are the values at the next time.
                               % This will effectively create Multivariate Random Forest data.
        else
            Y(s,:)=T(i,G,t+1);
        end
        s = s+1;
    end
end

%Y = transpose(Y);


end

