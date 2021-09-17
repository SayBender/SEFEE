# SEFEE

SEFEE is a Multi-output lightweight forecasting approach based on tensor decomposition. It recieves multi-dimensional data as input and outputs multi-dimensional joint predictions. For now, only 3-way tensors are supported. SEFEE is implemented in MATLAB R2019 and uses tensor_toolbox, poblano_toolbox and CMTF_toolbox libraries for tensor operations. If you found this resource useful, please consider citing [this paper](https://dl.acm.org/doi/10.5555/3433701.3433786) as well as the libraries mentioned below. 

We downloaded these libraries locally at various dates between 2017 and 2019 and used the version at the time, so it is possible the developers changed things about these open-source libraries. We share the version we used, please find the specific versions from publisher's website. For questions regarding the code, repository and paper in general, **please create an Issue under Issues tab**.  

- You can find tensor_toolbox at: https://www.tensortoolbox.org/getting_started.html (We used version 2.6)
- You can find CMTF_toolbox at: http://www.models.life.ku.dk/joda/CMTF_Toolbox (We used v1.1) CMTF toolbox is not an up-to-date toolbox, the publishers have not updated it since 2014. So we mostly base our experiments on tensor_toolbox (which don't use Side information) However, in pur paper we have done experiments with side information as well to show slight improvement over no side information. 
- You can find Poblano toolbox at: https://github.com/sandialabs/poblano_toolbox (v1.1)

Download the relevant libraries and put them in the same folder as the other .m files. 

You can run the prediction by simply running ``SEFEE.m`` by inputing a tensor (which can include all the data) and giving the index for the desired observed window and time-steps to predict. There are detailed explanations inside SEFEE and predictSEF which are the main functions.

The data used to conduct experiments in the paper are proprietary. Thus, a sample tensor data is provided in sample.mat.

Example:
To run SEFEE tensor experiment, simply open ``run_SEFEE.m`` and fix details speific to your local system (i.e paths,..), and then simply run the script:
```
run_SEFEE.m
```
to run in the background:
```
nohup /usr/local/MATLAB/R2019a/bin/matlab -nodesktop -nodisplay < run_SEFEE.m > output.txt &
```
NOTE: you need to download all the required libraries detailed above and fix the paths to the libraries and also the path to where you want the results saved. 

---------------------------------------------------------------------------------------------------------

Baselines:

- Random Forests:

To compare with SEFEE which provides multi-output joint prediction we used the idea of Multivariate Random Forests (MVRF) laid out by:

"Segal, M., & Xiao, Y. (2011). Multivariate random forests. Wiley Interdisciplinary Reviews: Data Mining and Knowledge Discovery, 1(1), 80-87."

An implementation of MVRF already exists using R with very detailed documentation (https://cran.r-project.org/web/packages/MultivariateRandomForest/MultivariateRandomForest.pdf), You can use our sample data with that package as well. However, R is notoriously slow, and their implementation works only on very small scale data in a reasonable time. 

Thus, using Bagged trees in MATLAB R2019 (treeBagger) we implemented MVRF with some differences. The R implementation uses a matrix reponse variable, however, response variable in Bagged trees is column vector. So we train multiple bagged trees (one for each error type). More details are specified in ``MVRFdo.m``.

NOTE: the baselines do not work directly with 3D arrays (tensors) so we had to unroll tensor into matrix (or in other words convert the data into MVRF ready format). All specific details are laid out in ``MVRFdataprep.m`` and ``MVRFdo.m``.

To run MVRF experiment, simply run:
```
MVRFdo.m
```
the above script loads the data and uses the sample data provided to run the experiment. You don't need to convert or create the data. However, you can refer to MVRFdataprep.m to create different subsets for train and test sets based on the sample tensor.

----------------------------------------------------------------------------------------------------

- LSTM

(python 3)
Since we are working with multivatiate time-series (predict multiple outputs at each prediction) we need to use a multivatiate LSTM model. Thus, we used the code from: https://machinelearningmastery.com/how-to-develop-lstm-models-for-time-series-forecasting/  with minimal change. We used Bidirectional LSTM instead of Vanilla. To understand how the code prepares the data for multivarite LSTM please refer to the link above and read details under "Multiple Parallel Series".

The data used for LSTM experiment is provided both in Sample_data.mat and separately as ``data_lstm.csv``

data_lstm (dimension: 2000 X 5000) is exactly the tensor sample data (10 nodes X 500 errors X 2000 time-steps) but unrolled along its 3rd dimension to matrix using tensor_toolbox's tenmat function and then stored as csv so it can be read using pandas read_csv. 
By unrolling the tensor into matrix like this, we don't lose any information, it is simply a 2D matrix instead of 3D matrix (tensor). The rows would represent time-steps which is suitable for time-series prediction. Column would represent the 1st and 2nd dimensions of the original tensors. For example, row 1 column 15 would represent, time 1, node 5, error 2.

```
#   This code is entirely based on the link provided above with minimal change. 
#   for more details please refer to that link.

#for top portion
import numpy as np
import pandas as pd 
from keras.models import load_model
#--------
# for bottom portion
from numpy import array
from keras.models import Sequential
from keras.layers import LSTM
from keras.layers import Dense
from keras.layers import Bidirectional


data = pd.read_csv('data_lstm.csv')
data = np.array(data)

num_step = 4
num_features = data.shape[1]
# defining the model
our_model = define_model(num_step,num_features)
#creating train dataset
X, y = BiDir.split_sequences(data,num_step)
print(X.shape, y.shape)

train_size = 1000

our_model.fit(X[:train_size],y[:train_size], epochs=1000)

our_model.save('Model-4steps-BiDir.h5')

#-------------------------------------

def define_model(n_steps,n_features):
    # choose a number of time steps
    # convert into input/output
    #X, y = split_sequences(data, n_steps)
    # the dataset knows the number of features, e.g. 2
    # define model
    model = Sequential()
    model.add(Bidirectional(LSTM(100, activation='relu', return_sequences=True, input_shape=(n_steps, n_features))))
    model.add(Bidirectional(LSTM(100, activation='relu')))
    model.add(Dense(n_features))
    model.compile(optimizer='adam', loss='mse',metrics=['accuracy'])
    #print(model.summary())
    return model

def split_sequences(sequences, n_steps):
    X, y = list(), list()
    for i in range(len(sequences)):
        # find the end of this pattern
        end_ix = i + n_steps
        # check if we are beyond the dataset
        if end_ix > len(sequences)-1:
            break
        # gather input and output parts of the pattern
        seq_x, seq_y = sequences[i:end_ix, :], sequences[end_ix, :]
        X.append(seq_x)
        y.append(seq_y)
    return array(X), array(y)
    
```

# Citation (BibTeX)
 If you found this resource useful, please consider citing this paper:
```
@inproceedings{10.5555/3433701.3433786,
author = {Yazdi, Amirhessam and Lin, Xing and Yang, Lei and Yan, Feng},
title = {SEFEE: Lightweight Storage Error Forecasting in Large-Scale Enterprise Storage Systems},
year = {2020},
isbn = {9781728199986},
publisher = {IEEE Press},
abstract = {With the rapid growth in scale and complexity, today's enterprise storage systems need to deal with significant amounts of errors. Existing proactive methods mainly focus on machine learning techniques trained using SMART measurements. However, such methods are usually expensive to use in practice and can only be applied to a limited types of errors with a limited scale. We collected more than 23-million storage events from 87 deployed NetApp-ONTAP systems managing 14,371 disks for two years and propose a lightweight training-free storage error forecasting method SEFEE. SEFEE employs Tensor Decomposition to directly analyze storage error-event logs and perform online error prediction for all error types in all storage nodes. SEFEE explores hidden spatio-temporal information that is deeply embedded in the global scale of storage systems to achieve record breaking error forecasting accuracy with minimal prediction overhead.},
booktitle = {Proceedings of the International Conference for High Performance Computing, Networking, Storage and Analysis},
articleno = {64},
numpages = {14},
keywords = {lightweight forecasting, tensor decomposition, storage failures, training-free prediction, error prediction},
location = {Atlanta, Georgia},
series = {SC '20}
}
```
