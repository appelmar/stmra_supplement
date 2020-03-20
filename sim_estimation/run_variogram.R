library(spacetime)
library(gstat)
library(sp)
library(raster)
load("exp_A_1_1/sim_spacetime.RData")
br = raster::brick(sim)
br


z = NULL
for (i in 1:nlayers(br)) {
  z = rbind(z, cbind(coordinates(br), i, as.vector(raster::subset(br, i))))
}
colnames(z) <- c("x", "y", "t", "value")
z = as.data.frame(z)
#coordinates(z) = c("x","y","t")
# 
geom = SpatialPixels(SpatialPoints(coordinates(br), proj4string = CRS(proj4string(br))))
time = as.POSIXct("2018-08-01", tz="GMT") + 0:(nlayers(br)-1)
x = STFDF(geom, time, z[,"value", drop=FALSE])
#x = STIDF(SpatialPixels(SpatialPoints(z[,c("x","y")], proj4string = CRS(proj4string(br)))), as.Date("2018-08-01") + z[,"t"] - 1, z[,"value", drop=FALSE])
# 
v.exp.1 = variogramST(value ~ 1, data = x)
v.exp.2 = variogramST(value ~ 1, data = x, cutoff = 1, width = 1/30)
v.exp.3 = variogramST(value ~ 1, data = x, cutoff = 1, width = 1/50)

plot(v.exp.1)
plot(v.exp.2)
plot(v.exp.3)



lower = c(1e-5, 1e-5, 1e-5, 1e-5)
upper = c(1, 4*var(sim), 4*var(sim), 50)

vgm.start.1 <- vgmST("metric", joint = vgm(1,"Exp", 0.2, 0.05), stAni=0.02)# correct
vgm.start.2 <- vgmST("metric", joint = vgm(var(sim)*0.9,"Exp", 1, var(sim)*0.1), stAni=1) # same as MRA experiments
vgm.start.3 <- vgmST("metric", joint = vgm(var(sim),"Exp", 0.1, 0.001), stAni=1) #
vgm.start.4 <- vgmST("metric", joint = vgm(var(sim)*0.9,"Exp", 0.01, var(sim)*0.1), stAni=1) #
vgm.start.5 <- vgmST("metric", joint = vgm(var(sim)*0.9,"Exp", 0.01, var(sim)*0.1), stAni=0.02) #
vgm.start.6 <- vgmST("metric", joint = vgm(var(sim)*0.9,"Exp", 1, var(sim)*0.1), stAni=0.02) #
vgm.start.7 <- vgmST("metric", joint = vgm(var(sim)*0.9,"Exp", 1, var(sim)*0.1), stAni=0.2) #
vgm.start.8 <- vgmST("metric", joint = vgm(var(sim)*0.9,"Exp", 0.01, var(sim)*0.1), stAni=0.02) #


#extractParNames(metricModel)

## 1
v.fitted.1 <- fit.StVariogram(v.exp.2, vgm.start.1, method="L-BFGS-B", lower=lower, upper=upper)
v.fitted.1
plot(v.exp.2, v.fitted.1)


## 2
v.fitted.2 <- fit.StVariogram(v.exp.2, vgm.start.2, method="L-BFGS-B", lower=lower, upper=upper)
v.fitted.2
plot(v.exp.2, v.fitted.2)


## 3
v.fitted.3 <- fit.StVariogram(v.exp.2, vgm.start.3, method="L-BFGS-B", lower=lower, upper=upper)
v.fitted.3
plot(v.exp.2, v.fitted.3)

## 4
v.fitted.4 <- fit.StVariogram(v.exp.2, vgm.start.4, method="L-BFGS-B", lower=lower, upper=upper)
v.fitted.4
plot(v.exp.2, v.fitted.4)

## 5
v.fitted.5 <- fit.StVariogram(v.exp.2, vgm.start.5, method="L-BFGS-B", lower=lower, upper=upper)
v.fitted.5
plot(v.exp.2, v.fitted.5)

## 6
v.fitted.6 <- fit.StVariogram(v.exp.2, vgm.start.6, method="L-BFGS-B", lower=lower, upper=upper)
v.fitted.6
plot(v.exp.2, v.fitted.6)

## 7
v.fitted.7 <- fit.StVariogram(v.exp.2, vgm.start.7, method="L-BFGS-B", lower=lower, upper=upper)
v.fitted.7
plot(v.exp.2, v.fitted.7)

v.fitted.1
v.fitted.2
v.fitted.3
v.fitted.4
v.fitted.5
v.fitted.6
v.fitted.7

estimates = list(v.fitted.1,
                 v.fitted.2,
                 v.fitted.3,
                 v.fitted.4,
                 v.fitted.5,
                 v.fitted.6,
                 v.fitted.7)







# systematic
test.pars = expand.grid(range  = c(0.01, 0.05, 0.2, 0.5, 1),
            psill  = c(0.01, 0.1, 0.5, var(sim), 1, 2, 2*var(sim)),
            nugget = c(0.0001, 0.01, 0.02, 0.05, 0.1, 0.1*var(sim), 0.2, 1),
            anis   = c(0.005, 0.01, 0.02, 0.05, 0.1, 0.5, 1, 2, 5, 10, 50))
  
vgm.estimates = data.frame()
for (i in 1:nrow(test.pars)) {
  vgm.start <- vgmST("metric", joint = vgm(test.pars$psill[i],"Exp", test.pars$range[i], test.pars$nugget[i]), stAni=test.pars$anis[i]) 
  v.fitted = fit.StVariogram(v.exp.2, vgm.start, method="L-BFGS-B", lower=lower, upper=upper)
  r = extractPar(v.fitted)
  vgm.estimates = rbind(vgm.estimates, data.frame(psill = r["sill"], range = r["range"], 
                                                    nugget = r["nugget"], anis = r["anis"],
                                                    psill_start = test.pars$psill[i],
                                                    range_start = test.pars$range[i],
                                                    nugget_start = test.pars$nugget[i],
                                                    anis_start = test.pars$anis[i]) )
  if (i %% (round(0.01*nrow(test.pars))) == 0) {
    cat(format(Sys.time()), " (", i, "): ", 100 * i/nrow(test.pars), "%", "\n", sep= "")
    save(vgm.estimates, file = "exp_A_1_1/EXP_A_1_1_EXPVGMFIT.RData")
  }
}
save(vgm.estimates, file = "exp_A_1_1/EXP_A_1_1_EXPVGMFIT.RData")

#######################################################################

load("exp_A_1_1/EXP_A_1_1_EXPVGMFIT.RData")

rownames(vgm.estimates) = NULL

hist(vgm.estimates$psill)
hist(vgm.estimates$range)
hist(vgm.estimates$nugget)
hist(log(vgm.estimates$anis))

plot(density(vgm.estimates$psill)) 
plot(density(vgm.estimates$range)) 
plot(density(vgm.estimates$nugget)) 
plot(density(log(vgm.estimates$anis))) 
plot(vgm.estimates$psill, vgm.estimates$range)

# cl.fit = kmeans(as.matrix(vgm.estimates[,1:4]),3)
# library(cluster)
# clusplot(as.matrix(vgm.estimates[,1:4]), cl.fit$cluster, color=TRUE, shade=TRUE,
#          labels=1, lines=0)





