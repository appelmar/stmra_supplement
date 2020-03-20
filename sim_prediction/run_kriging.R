require(raster)
require(spacetime)
require(gstat)
require(stmra)

outfile =  basename(tempfile(pattern = "EXP_A_1_2_KRIGING_1_",fileext = ".RData"))

load("sim_spacetime.RData")
br = raster::brick(sim)

  
pred_data = br
temp_data = as.array(pred_data)
temp_data[validation_set] = NA
pred_data = brick(temp_data)
crs(pred_data) = crs(br)
extent(pred_data) = extent(br)

z = as.data.frame(stmra_stack_to_matrix(br))
v.fitted <- vgmST("metric", joint = vgm(theta[2],"Exp", theta[1], theta[3]), stAni=theta[4])


x.validation = STIDF((SpatialPoints(z[,c("x","y")], proj4string = CRS(proj4string(br)))), as.Date("2018-08-01") + z[,"t"] - 1, z[,"value", drop=FALSE])
stopifnot(assertthat::are_equal(x.validation@data$value, z[,"value"]))
x.old = STIDF((SpatialPoints(z[-validation_set,c("x","y")], proj4string = CRS(proj4string(br)))), as.Date("2018-08-01") + z[-validation_set,"t"] - 1, z[-validation_set,"value", drop=FALSE])
stopifnot(assertthat::are_equal(x.old@data$value, z[-validation_set,"value"]))

#x.new = x.validation[validation_set]
x.new = STIDF(SpatialPixels(SpatialPoints(z[validation_set,c("x","y")], proj4string = CRS(proj4string(br)))), as.Date("2018-08-01") + z[validation_set,"t"] - 1, z[validation_set,"value" , drop=FALSE])
stopifnot(assertthat::are_equal(x.new@data$value, z[validation_set,"value"]))
x.new@data[,"value"] <- NA 

print(paste(Sys.time(),": STARTING KRIGING 1", sep=""))
time_1 = system.time(pred_1 <- krigeST(value ~ 1, data = x.old, newdata = x.new, computeVar = TRUE, modelList = v.fitted,progress=TRUE))
print(paste(Sys.time(),": FINISHED KRIGING 1", sep=""))
resid_1 = as.vector(pred_1@data[,"var1.pred"]) -  as.vector(z[validation_set,"value"])

COV2SD = z[validation_set,"value"] > as.vector(pred_1@data[,"var1.pred"]) - 2 * sqrt(as.vector(pred_1@data[,"var1.var"]))    &  z[validation_set,"value"] < as.vector(pred_1@data[,"var1.pred"]) + 2 * sqrt(as.vector(pred_1@data[,"var1.var"])) 
COV2SD = sum(COV2SD, na.rm = TRUE) / length(validation_set)
result_1 = c("RMSE" = sqrt(mean(resid_1^2, na.rm = TRUE)),
  "MAE"  = mean(abs(resid_1), na.rm = TRUE),
  "COR"  = cor(as.vector(pred_1@data[,"var1.pred"]), as.vector(z[validation_set,"value"]), use="complete.obs"),
  "COV2SD" = COV2SD)


print(paste(Sys.time(),": STATS 1: ", sep=""))
print(result_1)
  


A_1_2_RESULT = data.frame(M = NA,
                          r = NA,
                          RMSE = unname(result_1["RMSE"]),
                          MAE = unname(result_1["MAE"]),
                          COV2SD = unname(result_1["COV2SD"]),
                          COR = unname(result_1["COR"]),
                          time = unname(time_1)[3])


save(A_1_2_RESULT, file = outfile)











