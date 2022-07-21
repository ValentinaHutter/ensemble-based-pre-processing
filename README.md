# Observation pre-processing for ensemble-based data assimilation
Data assimilation pre-processing using R's gamlss and crch based on SAMOS

This repository shows an application of SAMOS in pre-processing. 
The data includes a Values.csv and a Errors.csv, which only include two stations, to give an example of SAMOS without taking up too much space. These files are extracted from feedback files, which include first guess means and observations as well as the observation error and the first guess standard deviations over five years.

1. One can start the SAMOS computation by executing the SAMOS.R file, which saves three files to the data: Climatology.csv, Coefficients.csv, CoefficientsSigma.csv. This is already done, but could be repeated with different data or modified to process a different year. In this case the year 2020 is excluded for the computation of the climatology and the regression coefficients, while the Climatology.csv then holds the whole temporal period. 

2. In the SAMOS.ipynb the Climatology and the Coefficients and CoefficientsSigma are used to correct the first guess mean and standard deviation. The notebook is then used to explore the data and create plots. 
