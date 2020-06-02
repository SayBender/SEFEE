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

run_SEFEE.m

to run in the background:
nohup /usr/local/MATLAB/R2019a/bin/matlab -nodesktop -nodisplay < run_SEFEE.m > output.txt &

NOTE: you need to download all the required libraries detailed above and fix the paths to the libraries and also the path to where you want the results saved. 

---------------------------------------------------------------------------------------------------------

Baselines:

- MultiVariateRandomForest (MVRF):

To compare with SEFEE which provides multi-output joint prediction we used the idea of Multivariate Random Forests laid out by:

"Segal, M., & Xiao, Y. (2011). Multivariate random forests. Wiley Interdisciplinary Reviews: Data Mining and Knowledge Discovery, 1(1), 80-87."

An implementation of MVRF already exists using R (https://cran.r-project.org/web/packages/MultivariateRandomForest/MultivariateRandomForest.pdf), however this implementation works only on very small scale data. 

Thus, using Bagged trees in MATLAB R2019 (treeBagger) we implemented MVRF with some differences. The R implementation uses a matrix reponse variable, however, response variable in Bagged trees is column vector. So we train multiple bagged trees (one for each error type). More details are specified in MVRFdo.m.

NOTE: the baselines do not work directly with 3D arrays (tensors) so we had to unroll tensor into matrix (or in other words convert the data into MVRF ready format). All specific details are laid out in MVRFdataprep.m and MVRFdo.m.

To run MVRF experiment, simply run:

MVRFdo.m

the above script loads the data and uses the sample data to run the experiment. You don't need to convert or create the data. However, should you want to create different train and test sets, you can refer to MVRFdataprep.m to create different subsets for train and test sets based on the sample tensor.

----------------------------------------------------------------------------------------------------
