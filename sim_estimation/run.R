args = commandArgs(trailingOnly=TRUE)

# example call "Rscript this.R 3 32 
if (length(args) != 2) {
  stop("Expects two command line arguments (M, r)")
} 

M =  as.integer(args[1])
r =  as.integer(args[2])


library(raster)
library(stmra)

outfile = basename(tempfile(pattern = "EXP_A_1_1_RESULT_",fileext = ".RData"))

load("sim_spacetime.RData")
br = raster::brick(sim)

print(paste(Sys.time(), ": M = ", M, " | ", "r = ", r, sep=""))
part = stmra_partition(M, r, br)
lower = c(1e-3, 1e-3, 1e-3, 1e-3)
upper = c(1, 4*var(sim), 4*var(sim), 50)
theta0 = c(0.5, var(sim), var(sim)*0.1, 1)
time = system.time(model_result <- 
                     stmra(part,cov_fun = stmra_cov_metric_exp,data = br, theta0 = theta0, lower_bounds = lower, optim.method = 2,
                                    upper_bounds = upper, trace = TRUE))[3]

A_1_1_RESULT = list()
A_1_1_RESULT$M = M
A_1_1_RESULT$r = r
A_1_1_RESULT$model = model_result
A_1_1_RESULT$time = time

save(A_1_1_RESULT, file = outfile)







