# SEFEE

SEFEE is a tensor decomposition based approach to predict storage errors. It is implemented in MATLAB R2019 and uses tensor_toolbox, poblano_toolbox and CMTF_toolbox libraries. Please cite us as well as the libraries below if you plan to use this in your publication:

We downloaded these libraries locally at various dates between 2017 and 2019 and used the version at the time, so it is possible the developers changed things about these open-source libraries. We share the version we used, please find the specific versions from publisher's website. If for any reason your downloaded packages were not able to work with SEFEE, please contact SEFEE author at <placeholder>. 

- You can find tensor_toolbox at: https://www.tensortoolbox.org/getting_started.html (We used version 2.6)
- You can find CMTF_toolbox at: http://www.models.life.ku.dk/joda/CMTF_Toolbox (We used v1.1) CMTF toolbox is not an up-to-date toolbox, the publishers have not updated it since 2014. So we mostly base our experiments on tensor_toolbox (which don't use Side information) However, in pur paper we have done experiments with side information as well to show slight improvement over no side information. 
- You can find Poblano toolbox at: https://github.com/sandialabs/poblano_toolbox (v1.1)

Download the relevant libraries and put them in the same folder as the other .m files. 

You can run the prediction by simply running SEFEE.m by inputing a tensor (which can include all the data) and giving the index for the desired observed window and time-steps to predict. There are detailed explanations inside SEFEE and predictSEF which are the main functions.

The data used to conduct experiments in the paper are proprietary. Thus, a sample tensor data is provided in sample.mat.

AN EXAMPLE AND SAMPLE DATA WILL BE ADDED VERY SOON 
