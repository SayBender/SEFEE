from = 1001; %this is the first step that is going to be predicted
steps = 900; 
rank = 200; % you are welcome to try this with different ranks. It might produce better/worse results.
%diary time_1.out
fprintf('Initializing experiment ALS on sample data predicting from %d for %d steps and rank %d  \n', from,steps,rank);
addpath('/home/ayazdi/Documents/AWS/SEFEE_local/');
addpath('/home/ayazdi/Documents/AWS/SEFEE_local/CMTF_Toolbox');
addpath('/home/ayazdi/Documents/AWS/SEFEE_local/tensor_toolbox');
addpath('/home/ayazdi/Documents/AWS/SEFEE_local/poblano_toolbox');
fprintf('Libraries added.\n');
%load('July2919.mat')
fprintf('Data Loaded.\n');
fprintf('Experiment in progress...\n');
[Tf_ALS_200,time, res, Tfw] = SEFEE(Sample_tensor,from-86,from-1,steps,rank);
fprintf('Experiment ALS Completed predicting from %d for %d steps and rank %d  \n', from,steps,rank);
save('/home/ayazdi/Documents/AWS/SEFEE_local/Comparisons/Results/Results_D8_SEFEE2','Tf_ALS_D8','time','res','Tfw');
fprintf('saved!\n');
fprintf('------------------------------------------------------------------------\n');
fprintf('---------------------------------END------------------------------------\n');
fprintf('------------------------------------------------------------------------\n');
%diary off
% Download directory from AWS: scp -i ec2yazdi.pem -r ubuntu@ec2-54-174-132-126.compute-1.amazonaws.com:/home/ubuntu/AWS_data ./
% Running in background: nohup /usr/local/MATLAB/R2019a/bin/matlab -nodesktop -nodisplay < Main_ALS_100.m > Z_core2.txt &