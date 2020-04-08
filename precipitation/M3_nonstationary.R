args = commandArgs(trailingOnly=TRUE)

# example call "Rscript this.R 3 32
if (length(args) != 2) {
  stop("Expects two command line arguments (M, r)")
} 

M =  as.integer(args[1])
r =  as.integer(args[2])


id = paste("M3_nonstationary_", M, "_", r, "_" ,format(Sys.time(), "%Y-%m-%dT%H-%M-%S"), sep="")

###
library(stmra)
library(raster) 
library(car)
s = stack(sort(list.files("data",pattern=".tif", full.names = TRUE))[1:30])
data = as.array(s)

# power transform
lambda = 0.03 #ptransf$lambda
gamma = 0.001 #ptransf$gamma
data_transformed = (bcnPower(data, lambda = lambda, gamma =gamma))
data_transformed = data_transformed - mean(data_transformed)


br = brick(data_transformed)
extent(br) <- extent(s)
crs(br) <- crs(s)
#######







#######
result_A_singlepart = NULL
result_B_singlepart = NULL
########



set.seed(26318)
pred_data = br
validation_set = 
  cbind(sample(1:length(pred_data), length(pred_data) - 100000, replace = FALSE))
temp_data = as.array(pred_data)
temp_data[validation_set] = NA
pred_data = brick(temp_data)
crs(pred_data) = crs(br)
extent(pred_data) = extent(br)
set.seed(NULL)


part = stmra_partition(M, r, pred_data, region_minsize = c(0, 0, 5))
lower = c(0.001, 0.001, 0.5, rep(0.1,9), rep(0.5,9), rep(0.5,9))
upper = c(  1,     1,  30,  rep(20,9),  rep(50,9),  rep(50,9))
theta0 = c(0.1, 0.1, 5, rep(2,9), rep(10, 9), rep(10,9))
model = stmra(part,stmra_cov_nonstationary_R2_separable, pred_data, theta0 = theta0, lower = lower, upper= upper, trace = TRUE, control=list(ftol_abs = 0.2, maxeval = 500))




# VAL 1, 90%

cc = system.time(pred <- predict(model, data = pred_data))[3]
result_A_singlepart = stmra_assess(pred, br)
result_A_singlepart$measures = c(result_A_singlepart$measures, "runtime" = cc)
result_A_singlepart$measures

save(model, result_A_singlepart, result_B_singlepart, file = paste("RESULT_", id, ".RData", sep=""))



#######
# VAL 2
pred_data = br
validation_set = NULL

#z = stmra_stack_to_matrix(pred_data)
for (it in 1:nlayers(pred_data)) {
  if (it %% 2 == 0) {
    pred_data[[it]][,1:round(dim(pred_data)[2]/2)] <- NA
  }
  else {
    pred_data[[it]][,round(dim(pred_data)[2]/2):(dim(pred_data)[2])] <- NA
  }
}

cc = system.time(pred <- predict(model, data = pred_data))[3]
result_B_singlepart = stmra_assess(pred, br)
result_B_singlepart$measures = c(result_B_singlepart$measures, "runtime" = cc)
result_B_singlepart$measures

save(model, result_A_singlepart, result_B_singlepart, file = paste("RESULT_", id, ".RData", sep=""))








