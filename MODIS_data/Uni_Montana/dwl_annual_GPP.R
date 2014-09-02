#Author: Mirela Tulbure(Mirela.Tulbure@gmail.com)
#Date:July 2014
#Purpose: Dwl the annual global GPP product from
#Uni of Montana
#Clip to CA, reclassify to get rid of NA values and 
#multiply by 0.1 scaling factor

#Install the packages we need 
install.packages ("raster")
install.packages ("rgdal")

install.packages ("RCurl", dependencies=TRUE)

install.packages ("stringr")
install.packages ("rgeos")
install.packages ("stringr")


# load the packages we need 
library(stringr)
library (raster)
library (RCurl)

library (rgdal)

library (stringr)
library (maptools)

# set the working directory
# get a list of the files we should download from prism ftp

setwd("C:/drought_project/Annual_GPP")

for (year in 2000:2010){
  print (year)
  url  <- 'ftp://ftp.ntsg.umt.edu/pub/MODIS/NTSG_Products/MOD17/GeoTIFF/MOD17A3/GeoTIFF_30arcsec/'
  filenames <- strsplit(getURL(url, .opts=curlOptions(ftplistonly=TRUE)), "\r\n")[[1]]
  filename<- filenames [grep(paste ("MOD17A3_Science_GPP_", year, ".tif", sep=""), filenames)]
  sourcefile <- paste (url, filename, sep ="")
  download.file(sourcefile, filename,  method = "wget")        
}    


# mask the usa maps with california to obtain a map of california
cali<- readShapeSpatial ("C:/drought_project/USA_adm/USA_adm1.shp")
california<- cali [cali$NAME_1 == "California", ]

#list all the tifs files to open, open, crop and make a stack
name<- list.files(pattern='tif')

# clip all rasters to CA and name them the same as before but start with "CA_"
# reclassify to exclude the NA values 
# multiply by 0.1 scaling factor as described on the website
# plot the raster

for (a in name){
  ras <- raster (a)  
  print(a)
  out_name <- paste('CA_',a,sep="")
  print(out_name)
  ras_masked <- mask (ras, california)
  writeRaster(ras_masked, out_name, format = "GTiff")
  kk <- raster(out_name)
  kk_reclas<- reclassify (kk,c(65000, +Inf, NA))
  kk_reclas_01 <- (kk_reclas)*0.1
  plot (kk_reclas_01, xlim =c(-125, -113),ylim =c(30, 43))  
}


## for example just for the 2013 raster:

rast_2013 <- raster(name[18])
mask_2013 <- mask(rast_2013, california)
out_name_2013 <- "CA_MOD17A3_Science_GPP_2013_v2.tif"
writeRaster(mask_2013, out_name_2013, format = "GTiff")
kk_2013 <- raster(out_name_2013)
kk_2013_reclas<- reclassify (kk_2013,c(65000, +Inf, NA))
kk_2013_reclas_01 <- (kk_2013_reclas)*0.1
plot (kk_2013_reclas_01, xlim =c(-125, -113),ylim =c(30, 43))
out_name_2013_reclas <- "CA_MOD17A3_Science_GPP_2013_reclass.tif"

writeRaster(kk_2013_reclas_01, out_name_2013_reclas, format = "GTiff")

###Sara!! thank you
verde<- colorRampPalette (c("darkolivegreen1", 
                            "darkolivegreen", "black"))

par (mar= c(0,0,2,0))
plot (kk_2013_reclas_01, col= verde (100), 
      xlim =c(-125, -113),ylim =c(30, 43),
      axes=F, box=F, 
      main= "Gross Primary Productivity 2013 (g Carbon*m-2)")
plot (california, border="grey50", add=T)

jpeg ("kkk.jpg")