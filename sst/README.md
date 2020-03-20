# Sea-Surface Temperature Data Example

This experiment contains R scripts to run the three models as described in the paper (`M1_separable.R`, `M2_porcu.R`, `M3_nonstationary.R`) and a script to analyse results and produce figures / tables similar to the ones in the paper. Notice that depending on the choice of MRA parameters, execution of the scripts may take a long time.

To run a model with a given number of partitioning levels $M$ and basis functions $r$, please perform the following steps on the command line:

1. Please make sure to use this folder as working directory.

2. Run  e.g. `Rscript --vanilla M1_separable.R 3 16` to execute the script of the separable model with $M=3$ and $r=16$.

3. Repeat step 2 with different models and/or values for $M$, and $r$.

4. Each model execution will produce an `.RData`file.

5. If finished, you may execute `result_analysis.R` and check produced tables and figures.
