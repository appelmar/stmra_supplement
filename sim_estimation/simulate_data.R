############# SIMULATE DATA ##########################

library(raster)
library(RandomFields)
library(sp)

set.seed(98362)
nx = 50
ny = 50
nz = 50
n = nx*nz*ny
n

x.seq = seq(0, 1,length.out = nx)
y.seq = seq(0, 1,length.out = ny)
z.seq = seq(0, 1,length.out = nz)

coords = as.matrix(expand.grid(x.seq, y.seq, z.seq))

# covariance function

#model <- RMexp(var=1, scale=0.3, Aniso=RMangle(angle=pi/4, lat.angle=pi/8, diag=c(1,1,2))) + RMnugget(var=.05) # exponential 
model <- RMexp(var=1, scale=0.2) + RMnugget(var=.05) # exponential 

sim = RFsimulate(model,x = x.seq, y = y.seq, z=z.seq, grid=TRUE, spConform=FALSE)

br = raster::brick(sim)
set.seed(11027)
validation_set = sort(sample(1:length(br), 0.9*length(br), replace = FALSE)) # must be sorted for spacetime
theta = c(0.2, 1, 0.05, 1/nz)



save(sim, validation_set, theta, file = "sim_spacetime.RData")


set.seed(NULL)


