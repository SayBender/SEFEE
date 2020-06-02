from = 1001; %this is the first time-step that is going to be predicted
steps = 900; % for how many predictions (step) should we run the experiment
rank = 200; % you are welcome to try this with different ranks. It might produce better/worse results.

fprintf('Initializing experiment ALS on sample data predicting from %d for %d steps and rank %d  \n', from,steps,rank);
addpath('/path/to/SEFEE_directory/');
addpath('/path/to/SEFEE_directory/CMTF_Toolbox');
addpath('/path/to/SEFEE_directory/tensor_toolbox');
addpath('/path/to/SEFEE_directory/poblano_toolbox');
fprintf('Libraries added.\n');
load('sampleData.mat')
fprintf('Data Loaded.\n');
fprintf('Experiment in progress...\n');
[Tf_ALS_200,time, res, Tfw] = SEFEE(Sample_tensor,from-86,from-1,steps,rank); %uses an observed window of 86 prior to "from" (refer to SEFEE.m for more detail)
fprintf('Experiment ALS Completed predicting from %d for %d steps and rank %d  \n', from,steps,rank);
save('/path/to/Results/Results_SampleData_SEFEE','Tf_ALS_200','time','res','Tfw');
fprintf('saved!\n');
fprintf('------------------------------------------------------------------------\n');
fprintf('---------------------------------END------------------------------------\n');
fprintf('------------------------------------------------------------------------\n');
