%    script to run Multivariate Random Forest with the given data. You are welcome to create your own data or use MVRFdataprep
%    to create train and test sets with different sizes. In this experiment the first 1000 time-steps is used to create
%    train set and the next 900 for test sets. Last 100 is unused.
load('sampleData.mat')
numerrors = 500; 
Ypred_rf = zeros(9000,numerrors);  % 9000 = 10 * 900 (900 being the length of the test set) refer to MVRFdataprep.m  and below for more details.
tic
%   MVRF does not work with tensors (3D arrays) directly, so we had to
%   unroll the tensor into matrices by combining time (3rd) and node
%   dimension. So the first 10 rows of the Sample rf data is associated
%   with node 1 to node 10 at first time-steps and row 11 to 20 is
%   associated with 2nd time step and so on. This is more obvious/visible in
%   Xtrain and Xtest as the first column captures the node number.

%   Ytrain_rf is the matrix of response variables. We use one column vector
%   at a time to train Random Forest and combine the prediction results
%   back into matrix form. At the end you can convert Matrix back to tensor
%   form since it was unrolled version of the tensor in the first place.


for i=1:numerrors  %  we do this in a loop one error at a time, because a matrix response variable was not possible (Y) 
     %          so at each iteration we train a Random forest using
     %          training data from all nodes and errors to predict 1 error
     %          type at a time (for all nodes and times) and then we move to the next. So Response variable
     %          will be a column vector (i.e. Ytrain_rf(:,i) ). however the training
     %          data and test data are all matrix and at each iteration the
     %          predicted error type (column vector) would be inserted in
     %          the proper column. Note that we have merged two dimensions
     %          (node and time to get a matrix as it was not possible to
     %          train RF directly on tensor.) By looking at MVRFdataprep
     %          the way the data is treated would be more clear. Note that
     %          by playing with Xlen and by giving the desired portion of the input sample data
     %          you can control the length of train and test sets. 
     fprintf("predicting error %d\n",i);
     Mreg = TreeBagger(20,Xtrain_rf,Ytrain_rf(:,i),'NumPredictorsToSample', 400, 'MinLeafSize',60,'Method','regression');
     Ypred_i = predict(Mreg,Xtest_rf);
     Ypred_rf(:,i)=Ypred_i;
end

disp(toc)

%prediction accuracy: accuracy(Ytest_rf,round(Ypred_rf));

