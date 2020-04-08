args = commandArgs(trailingOnly=TRUE)

# example call "Rscript this.R 3 32 
if (length(args) != 2) {
  stop("Expects two command line arguments (M, r)")
} 

M =  as.integer(args[1])
r =  as.integer(args[2])


id = paste("M2_porcu_", M, "_", r, "_" ,format(Sys.time(), "%Y-%m-%dT%H-%M-%S"), sep="")


###
library(stmra)
library(raster) 
files = sort(list.files("data", full.names = TRUE))[1:30]
x = raster::stack(files)

lat = rep(coordinates(x)[,2], nlayers(x))
sst = as.vector(x)
trend = lm(sst ~ I(lat^2) +I(lat))
summary(trend)

res = sst - cbind(1, lat^2, lat) %*% (coef(trend))
y = setValues(x, as.vector(res))

rm(res, trend, sst, lat, x)

mask = mean(y, na.rm = TRUE)
mask_all = y
for (i in 1:nlayers(mask_all)) {
  mask_all[[i]] = mask
}
rm(mask)

nonna_indexes = which(!is.na(as.vector(y)))
length(nonna_indexes)

set.seed(266308)
training_set = sample(nonna_indexes,100000)
set.seed(NULL)

v = as.vector(y)
v[-training_set] = NA
training_data = setValues(y, v)
rm(v)
#######


part = stmra_partition(M, r, y, region_minsize = c(0, 0, 5))
lower = c(0.1,   100,  0.1,   0.01)
upper = c( 50,   15000,  30,   15)
theta0 = c(8.63, 1000, 10, 0.2)
model = stmra(part,stmra_cov_porcu_etal_15, training_data, theta0 = theta0, lower = lower, upper= upper, trace = TRUE, control=list(ftol_abs = 0.2, maxeval = 500))


#######


result_A_singlepart = NULL
pred_A_singlepart = NULL
result_B_singlepart = NULL
pred_B_singlepart = NULL



########
# VAL 1: 
# Data: training_data
# Pred Locs_ All non-NA from non-training data

cc = system.time(pred_A_singlepart <- predict(model, data = training_data, mask = mask_all))[3]
result_A_singlepart = stmra_assess(pred_A_singlepart, y)
result_A_singlepart$measures = c(result_A_singlepart$measures, "runtime" = cc)
result_A_singlepart$measures
save(model, result_A_singlepart, pred_A_singlepart, result_B_singlepart, pred_B_singlepart, file = paste("RESULT_", id, ".RData", sep=""))



#######
# VAL 2: 
# All except pixels in spatiotemporal validation boxes
# Pred_Locs: All from validation boxes


pred_data = y
mask_regions = y
mask_regions[] = NA
for (i in 11:19) {
  v = NA
  pred_data[[i]][extent(-160, -140, -60, -40)] <- v
  mask_regions[[i]][extent(-160, -140, -60, -40)] <- 1
  pred_data[[i]][extent(60, 80, -18, 2)] <- v
  mask_regions[[i]][extent(60, 80, -18, 2)] <- 1
  pred_data[[i]][extent(-33, -13, 40, 60)] <- v
  mask_regions[[i]][extent(-33, -13, 40, 60)] <- 1
}
# raster::animate(pred_data)

cc = system.time(pred_B_singlepart <- predict(model, data = pred_data, mask = mask_regions))[3]
result_B_singlepart = stmra_assess(pred_B_singlepart, y)
result_B_singlepart$measures = c(result_B_singlepart$measures, "runtime" = cc)
result_B_singlepart$measures
save(model, result_A_singlepart, pred_A_singlepart, result_B_singlepart, pred_B_singlepart, file = paste("RESULT_", id, ".RData", sep=""))


