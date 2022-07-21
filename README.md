# Observation pre-processing for ensemble-based data assimilation
Data assimilation pre-processing using R's gamlss and crch based on SAMOS

This repository shows an application of SAMOS in pre-processing. 
The data includes a Values.csv and a Errors.csv, which only include two stations, to give an example of SAMOS without taking up too much space. 

1. One can start the computation by executing the SAMOS.R file, which saves three files to the data: Predictions.csv, Coefficients.csv, CoefficientsSigma.csv. This is already done, but could be repeated to process other stations.

2. Afterwards, an Ipynb is used to explore the data and create plots. 
