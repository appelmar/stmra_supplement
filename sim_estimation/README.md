# Parameter Estimation of Simulated Data

This experiment contains R scripts to run parameter estimation on simulated data for different MRA parameter values and to produce figures / tables similar to the ones in the paper.
Notice that depending on the choice of MRA parameters, execution of the scripts may take a long time.


To run parameter estimation with a given number of partitioning levels $M$ and basis functions $r$, please perform the following steps on the command line:


1. Please make sure to use this folder as working directory.

2. Run  e.g. `Rscript --vanilla run.R 3 16` to start parameter estimation with $M=3$ and $r=16$, using data from `sim_spacetime.RData`.

3. Repeat step 2 with different models and/or values for $M$, and $r$.

4. Run `Rscript --vanilla run_variogram.R` to fit experimental variograms with different starting values. 

5. If finished, you may execute `result_analysis.R` and check produced tables and figures.

6. If desired, run `Rscript --vanilla simulate_data.R` to generate a new realization, overwriting `sim_spacetime.RData`, and repeat the previous steps.