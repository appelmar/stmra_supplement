# Spatiotemporal Multi-Resolution Approximations for Analyzing Global Environmental Data

This repository contains scripts and data to reproduce analyses of the paper _Spatiotemporal Multi-Resolution Approximations for Analyzing GlobalEnvironmental Data_.
The content of subdirectories is described below.

| Directory     | Description          
| ------------- | --------------------------------------- | 
| sim_estimation     | Parameter estimation experiments on simulated data (Section 3.1) | 
| sim_prediction     | Prediction experiments on simulated data (Section 3.2) | 
| sst                | Sea-surface temperature data example (Section 4.1) | 
| precipitation      | Precipitation data example (Section 4.2) | 

To reproduce the analysis, please follow the steps described in individual `README.md` files.


## Requirements

Please make sure you have the latest version of R and the following packages are installed:

* `stmra` (from GitHub, run `remotes::install_github("appelmar/stmra")` to install)
* `raster` (from CRAN)
* `nloptr` (from CRAN)
* `Rcpp` (from CRAN)
* `RandomFields` (from CRAN)
* `gstat` (from CRAN)
* `spacetime` (from CRAN)
* `car` (from CRAN)
* `colorspace` (from CRAN)