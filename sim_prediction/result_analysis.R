library(colorspace)
library(raster)

results_all = data.frame()
result_files = list.files(pattern = "EXP_A_1_2_RESULT.*.RData", full.names = TRUE)
for (f in result_files) {
  e = new.env()
  load(f, envir = e)
  results_all = rbind(results_all, cbind(e$A_1_2_RESULT, exp_time = file.info(f)$ctime[1]))
}

####################################
## "mean prediction" scores
load("sim_spacetime.RData")
br = raster::brick(sim)
pred_data = br
temp_data = as.array(pred_data)
temp_data[validation_set] = NA
pred_data = brick(temp_data)
crs(pred_data) = crs(br)
extent(pred_data) = extent(br)
resid_1 = mean(as.vector(pred_data), na.rm = TRUE) - as.vector(br)[validation_set]
WITHIN2SD_1 = sum(as.vector(br)[validation_set] > (mean(as.vector(pred_data), na.rm = TRUE) - 2*sd(as.vector(pred_data), na.rm = TRUE)) & as.vector(br)[validation_set] < (mean(as.vector(pred_data), na.rm = TRUE) + 2*sd(as.vector(pred_data), na.rm = TRUE))) / length(as.vector(br)[validation_set])

mean_pred_stats = c("RMSE" = sqrt(mean(resid_1^2, na.rm = TRUE)),
                    "MAE"  = mean(abs(resid_1), na.rm = TRUE),
                    "MSE" = mean(resid_1^2, na.rm = TRUE),
                    "COR"  = NA,
                    "COV2SD" = WITHIN2SD_1)



########################################
# Add R2
results_all$MSE = results_all$RMSE^2
results_all$R2  = 1 - (results_all$MSE)/(mean_pred_stats["MSE"])
####




M_factor = as.factor(results_all$M)
r_factor = as.factor(results_all$r)

col_scale = function(n) {
  rev(qualitative_hcl(n, "Dark 3"))
}
M_col = col_scale(4)[as.integer(M_factor)]
M_symb = 0+as.integer(M_factor)


layout(matrix(1:4, nrow=2, byrow=TRUE))

par(mar=c(4,4,1.5,1))
par(mgp=c(2.5,1,0))
par(cex=1.1)


plot(results_all$r, results_all$RMSE, col=M_col, pch=M_symb,
     xlab = "Number of Basis Functions (r)",
     ylab = "RMSE")
grid()
legend(x = "topright", legend =  paste(levels(M_factor), "  "), col = col_scale(4), title="M",pch=0+as.integer(levels(M_factor)), bg ="white", ncol=2) 


plot(results_all$time, results_all$RMSE, col=M_col, pch=M_symb,
     log="x", xlab = "Computation Time (seconds)", ylab = "RMSE")
grid()


results_all$EFF = (results_all$R2) / results_all$time
plot(results_all$r, results_all$EFF, col=M_col, pch=M_symb,
     ylab = "Prediction Speed (1/s)", xlab = "Number of Basis Functions (r)")
grid()


# uncertainty estimtation
plot(results_all$r, results_all$COV2SD, col=M_col, pch=M_symb,
     ylab = "COV2SD", xlab = "Number of Basis Functions (r)")
grid()

