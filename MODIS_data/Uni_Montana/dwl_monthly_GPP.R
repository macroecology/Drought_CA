#Author: Mirela Tulbure(Mirela.Tulbure@gmail.com)
#Date:July 2014
#Purpose: Dwl the annual global GPP product from
#Uni of Montana

#Install the packages we need 
install.packages ("raster")
install.packages ("rgdal")

install.packages ("RCurl", dependencies=TRUE)

install.packages ("stringr")
install.packages ("rgeos")

# load the packages we need 
library (raster)
library (RCurl)

library (rgdal)

library (stringr)
library (maptools)

# set the working directory
# get a list of the files we should download from prism ftp

setwd("C:/drought_project/GPP_Montana")


for (year in 2000:2013){
  for (month in 1:12){    
    month  <- sprintf(sprintf("%02d", month))
    print (year)
    print (month)
    destfile <- paste(getwd(), "/MOD17A2_GPP.", year, ".M", month, ".tif", sep="") 
    #print (destfile)
    url  <- 'ftp://ftp.ntsg.umt.edu/pub/MODIS/NTSG_Products/MOD17/GeoTIFF/Monthly_MOD17A2/GeoTIFF_0.05degree/'
    #print (url)
    #filename <- paste("MOD17A2_GPP.",year, ".M", month,".tif",sep="")
    filenames <- strsplit(getURL(url, .opts=curlOptions(ftplistonly=TRUE)), "\r\n")[[1]]
    #print (filenames)
    filename<- filenames [grep(paste ("MOD17A2_GPP.",year, ".M", month, sep=""), filenames)]
    #print (filename)
    #filename<- filenames [grep(paste (year, month, sep=""), filenames)]
    sourcefile <- paste (url, filename, sep ="")
    #print (sourcefile)
    download.file(sourcefile, filename, method="wget")        
  }
}    


# mask the usa maps with california to obtain a map of california
cali<- readShapeSpatial ("C:/drought_project/USA_adm/USA_adm1.shp")
california<- cali [cali$NAME_1 == "California", ]

#list all the tifs files in the folder
name<- list.files(pattern='tif')
name

#loop thu all the files in name and clip them to CA and write out the clipped rasters
# rasters will have the same name as the original rasters but with "CA_" in front

for (a in name){
  ras <- raster(a)  
  print(a)
  out_name <- paste('CA_',a,sep="")
  print(out_name)
  ras_masked <- mask (ras, california)
  writeRaster(ras_masked, out_name, format = "GTiff")
}
