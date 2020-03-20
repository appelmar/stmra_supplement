args = commandArgs(trailingOnly=TRUE)

# example call "Rscript this.R 3 32 
if (length(args) != 2) {
  stop("Expects two command line arguments (M, r)")
} 

M =  as.integer(args[1])
r =  as.integer(args[2])

library(raster)
library(stmra)
outfile = basename(tempfile(pattern = "EXP_A_1_2_RESULT_",fileext = ".RData"))

A_1_2_RESULT = data.frame(M = NULL,
                          r = NULL,
                          RMSE = NULL,
                          MAE = NULL,
                          COV2SD = NULL,
                          COR = NULL,
                          time = NULL)

load("sim_spacetime.RData")
br = raster::brick(sim)

part = stmra_partition(M, r, br)
model_1 = stmra(part, stmra_cov_metric_exp, br, theta = theta)


pred_data = br
temp_data = as.array(pred_data)
temp_data[validation_set] = NA
pred_data = brick(temp_data)
crs(pred_data) = crs(br)
extent(pred_data) = extent(br)

time_1 = system.time(pred_1 <- predict(model_1, data = pred_data))[3]
result_1 = stmra_assess(pred_1, br)


# write output
A_1_2_RESULT = data.frame(M = M,
                          r = r,
                          RMSE = unname(result_1$measures["RMSE"]),
                          MAE = unname(result_1$measures["MAE"]),
                          COV2SD = unname(result_1$measures["COV2SD"]),
                          COR = unname(result_1$measures["COR"]),
                          time = unname(time_1))

save(A_1_2_RESULT, file = outfile)


