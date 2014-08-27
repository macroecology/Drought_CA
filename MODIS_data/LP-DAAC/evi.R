##Author: Mirela Tulbure (mirela.tulbure@gmail.com)
##Email: mirela.tulbure@gmail.com
##Purpose: Generate evi per date using modis surface reflectance data 
## This script needs to run after you've dwl Modis
## surface reflectance data and converted the data to tif's

setwd('C:/download_modis')
#setwd("/Users/mgt/Documents/Work/NCEAS/Group_proj_CA_drought/Drought_CA/MODIS_data/LP-DAAC")

install.packages("rgdal")
library("rgdal")
install.packages("raster")
library(raster)

#need to be in the folder where the surface reflectance data are
tifs <- list.files(pattern='.tif$')

tifs

length(tifs)
list_tifs <- as.list(tifs)


### get_date function #############################
get_date <- function(MOD_filename){
  strsplit(MOD_filename, ".", fixed=TRUE)
  a <- strsplit(MOD_filename, ".", fixed=TRUE)
  b <- a[[1]]
  c <- b[[1]]
  d <- strsplit(c, "_", fixed=TRUE)
  prod_name  <- d[[1]][1]
  date <- d[[1]][2]
  year <- (strsplit(date, "-", fixed=TRUE))[[1]][1]
  month <- (strsplit(date, "-", fixed=TRUE))[[1]][2]
  day  <- (strsplit(date, "-", fixed=TRUE))[[1]][3]
  return(date)
}
#####################################################
dates <- sapply(list_tifs, get_date)
unique_dates <- as.list(unique(dates))  
  
b01s  <-  as.list(list.files(pattern='.sur_refl_b01.tif$'))
#class(b01s)
b01s_dates <- sapply(b01s, get_date)

b02s  <-  as.list(list.files(pattern='.sur_refl_b02.tif$'))
b02s_dates <- sapply(b02s, get_date)

b03s  <-  as.list(list.files(pattern='.sur_refl_b03.tif$'))
b03s_dates <- sapply(b03s, get_date)
##########################################################
# MODIS has 7 spectral bands:
# band 1 -- red    (620 - 670nm)
# band 2 -- nir1	(841 - 875 nm)
# band 3 -- blue	(459 - 479 nm)
# band 4 -- green	(620 - 670 nm)
# band 5 -- nir2	(1230 - 1250 nm)
# band 6 -- swir1	(1628 - 1652 nm)
# band 7 -- swir2	(2105 - 2155 nm)

# evi = G * (NIR1 - RED)/(NIR1 + C1*RED - C2*BLUE + L), 

# where L is the canopy background correction and sonw correction that addresses
# differential NIR and RED radiant transfer (transmittance) through a canopy,
# and C1 and C2 are the coefficient of the aerosol term, which uses BLUE band
# to correct for aerosol effects in the red band.


#Currently use G = 2.5, C1 = 6, C2 = 7.5, L = 1.0
L = 1
C1 = 6
C2 = 7.5
G = 2.5

####################################################

unlist (unique_dates)
# need to multiply all Modis by scaling factr of 0.0001
# as described in user guide

for (i in unique_dates){
  kk <- tifs[ grep (i, tifs)]
  kkk_b01 <- kk[grep ("b01", kk)]
  kkk_b01 <- raster(kkk_b01)
  kkk_b01 <- kkk_b01*0.0001
  kkk_b02 <- kk[grep ("b02", kk)]
  kkk_b02 <- raster(kkk_b02)
  kkk_b02 <- kkk_b02*0.0001
  kkk_b03 <- kk[grep ("b03", kk)]
  kkk_b03 <- raster(kkk_b03)
  kkk_b03 <- kkk_b03*0.0001
  kk_denom_evi <- kkk_b02 + C1*(kkk_b01) - C2*(kkk_b03) + L 
  kk_evi <- (G * (kkk_b02 - kkk_b01))/ (kk_denom_evi)
  evi_name <- paste("EVI_",i,".tif", sep="")
  writeRaster(kk_evi,filename=evi_name, format="GTiff", overwrite=TRUE)
}

#plot one of the evi layers, for example EVI_2014-07-04.tif
evi <- raster("EVI_2014-07-04.tif")
plot(evi)
plot(evi, zlim=c(0,0.8))
evi
v <- getValues(evi)

summary(v)
hist(v)