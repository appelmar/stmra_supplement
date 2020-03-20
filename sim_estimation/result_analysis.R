library(raster)
library(colorspace)

results_all_theta = data.frame()
theta_true = c(0.2, 1, 0.05, 0.02) 
result_files = list.files(pattern = "EXP_A_1_1_RESULT.*.RData", full.names = TRUE)
for (f in result_files) {
  e = new.env()
  load(f, envir = e)
  M = e$A_1_1_RESULT$M
  r = e$A_1_1_RESULT$r
  theta1 = e$A_1_1_RESULT$model$theta[1]
  theta2 = e$A_1_1_RESULT$model$theta[2]
  theta3 = e$A_1_1_RESULT$model$theta[3]
  theta4 = e$A_1_1_RESULT$model$theta[4]
  results_all_theta = rbind(results_all_theta, data.frame(M = M, r = r, theta1 = theta1, theta2 = theta2, theta3 = theta3, theta4 = theta4, time = e$A_1_1_RESULT$time, exp_time = as.POSIXct(file.info(f)$ctime[1]), iter = nrow(e$A_1_1_RESULT$model$estimation_log)))
}


M_factor = as.factor(results_all_theta$M)
r_factor = as.factor(results_all_theta$r)

col_scale = function(n) {
  rev(qualitative_hcl(n, "Dark 3"))
}

M_col = col_scale(4)[1+as.integer(M_factor)]
M_symb = 0+as.integer(M_factor)+1
M_levels_int = sort(unique(as.integer(M_factor)+1))


if (file.exists("EXP_A_1_1_EXPVGMFIT.RData"))
  load("EXP_A_1_1_EXPVGMFIT.RData")


layout(matrix(1:4, 2, 2, byrow = TRUE))
par(mar=c(4,4,1.5,1))
par(mgp=c(2.5,1,0))
par(cex=1.1)

if (file.exists("EXP_A_1_1_EXPVGMFIT.RData"))
  vgm.best.range = vgm.estimates$range[which.min(abs(theta_true[1] - vgm.estimates$range))]

plot(results_all_theta$r, results_all_theta$theta1, col=M_col, pch=M_symb,
     xlab = "Number of Basis Functions (r)", ylab = "Range",
     ylim = c( 0.1,  0.5))
grid()
if (file.exists("EXP_A_1_1_EXPVGMFIT.RData"))
  abline(h = vgm.best.range, col="blue", lty="dashed")
abline(h = theta_true[1], col="red", lty="dashed")
legend(x = "topright", legend =  paste(levels(M_factor), "  "), col = col_scale(4)[M_levels_int], title="M", pch=0+M_levels_int, bg =  "white",ncol = 3)

if (file.exists("EXP_A_1_1_EXPVGMFIT.RData"))
  vgm.best.psill = vgm.estimates$psill[which.min(abs(theta_true[2] - vgm.estimates$psill))]
plot(results_all_theta$r, results_all_theta$theta2, col=M_col, pch=M_symb,
     xlab = "Number of Basis Functions (r)", ylab = "Partial Sill",
     ylim = c(0.7, 2.5))
grid()
if (file.exists("EXP_A_1_1_EXPVGMFIT.RData"))
  abline(h = vgm.best.psill, col="blue", lty="dashed")
abline(h = theta_true[2], col="red", lty="dashed")

if (file.exists("EXP_A_1_1_EXPVGMFIT.RData"))
  vgm.best.nugget = vgm.estimates$nugget[which.min(abs(theta_true[3] - vgm.estimates$nugget))]
plot(results_all_theta$r, results_all_theta$theta3, col=M_col, pch=M_symb,
     xlab = "Number of Basis Functions (r)", ylab = "Nugget",
     ylim = c(theta_true[3] - 0.1, theta_true[3] + 0.1))
grid()
if (file.exists("EXP_A_1_1_EXPVGMFIT.RData"))
  abline(h = vgm.best.nugget, col="blue", lty="dashed")
abline(h = theta_true[3], col="red", lty="dashed")

if (file.exists("EXP_A_1_1_EXPVGMFIT.RData"))
  vgm.best.anis = vgm.estimates$anis[which.min(abs(theta_true[4] - vgm.estimates$anis))]
plot(results_all_theta$r, results_all_theta$theta4, col=M_col, pch=M_symb,
     xlab = "Number of Basis Functions (r)", ylab = "Spacetime Anisotropy",
     ylim = c(theta_true[4] - 0.01, theta_true[4] + 0.01))
grid()
abline(h = theta_true[4], col="red", lty="dashed")
if (file.exists("EXP_A_1_1_EXPVGMFIT.RData"))
  abline(h = vgm.best.anis, col="blue", lty="dashed")