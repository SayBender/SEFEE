# SEFEE

SEFEE is a tensor decomposition based approach to predict storage errors. It is implemented in MATLAB R2019 and uses tensor_toolbox, poblano_toolbox and CMTF_toolbox libraries. Please cite us as well as the libraries below if you plan to use this in your publication:

We downloaded these libraries locally at various dates between 2017 and 2019 and used the version at the time, so it is possible the developers changed things about these open-source libraries. We share the version we used, please find the specific versions from publisher's website. If for any reason your downloaded packages were not able to work with SEFEE, please contact SEFEE author at <placeholder>. 

- You can find tensor_toolbox at: https://www.tensortoolbox.org/getting_started.html (We used version 2.6)
- You can find CMTF_toolbox at: http://www.models.life.ku.dk/joda/CMTF_Toolbox (We used v1.1) CMTF toolbox is not an up-to-date toolbox, the publishers have not updated it since 2014. So we mostly base our experiments on tensor_toolbox (which don't use Side information) However, in pur paper we have done experiments with side information as well to show slight improvement over no side information. 
- You can find Poblano toolbox at: https://github.com/sandialabs/poblano_toolbox (v1.1)

Download the relevant libraries and put them in the same folder as the other .m files. 

You can run the prediction by simply running SEFEE.m by inputing a tensor (which can include all the data) and giving the index for the desired observed window and time-steps to predict. There are detailed explanations inside SEFEE and predictSEF which are the main functions.

The data used to conduct experiments in the paper are proprietary. Thus, a sample tensor data is provided in sample.mat.

Example:
To run SEFEE tensor experiment, simply open run_SEFEE.m and fix details speific to your local system (i.e paths,..), and then simply run the script:
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

An implementation of MVRF already exists using R with very detailed documentation (https://cran.r-project.org/web/packages/MultivariateRandomForest/MultivariateRandomForest.pdf), You can use our sample data with that package as well. However this implementation works only on very small scale data. 

Thus, using Bagged trees in MATLAB R2019 (treeBagger) we implemented MVRF with some differences. The R implementation uses a matrix reponse variable, however, response variable in Bagged trees is column vector. So we train multiple bagged trees (one for each error type). More details are specified in MVRFdo.m.

NOTE: the baselines do not work directly with 3D arrays (tensors) so we had to unroll tensor into matrix (or in other words convert the data into MVRF ready format). All specific details are laid out in MVRFdataprep.m and MVRFdo.m.

To run MVRF experiment, simply run:
```
MVRFdo.m
```
the above script loads the data and uses the sample data to run the experiment. You don't need to convert or create the data. However, should you want to create different train and test sets, you can refer to MVRFdataprep.m to create different subsets for train and test sets based on the sample tensor.

----------------------------------------------------------------------------------------------------

- LSTM

(python 3)
Since we are working with multivatiate time-series (predict multiple outputs at each prediction) we need to use a multivatiate LSTM model. Thus, we used the code from: https://machinelearningmastery.com/how-to-develop-lstm-models-for-time-series-forecasting/  with minimal change. We used Bidirectional LSTM instead of Vanilla. To understand how the code prepares the data for multivarite LSTM please refer to the link above and read details under "Multiple Parallel Series".

The data used for LSTM experiment is provided both in Sample_data.mat and separately as data_lstm.csv

data_lstm is exactly the tensor sample data but unrolled along its 3rd dimension to matrix using tensor_toolbox's tenmat function and then stored as csv so it can be read using pandas read_csv. This way, the rows would represent time, and column would represent node and error information. For example row 1 column 15 would represent, time 1, node 5 at error 2 (remember we have 10 nodes).

```
#This code is entirely based on the link provided above with minimal change. for more details please refer to that link.

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
