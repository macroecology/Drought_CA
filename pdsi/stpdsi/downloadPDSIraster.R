### Script to download data of PDSI raster from 1896 to 2014 
# August, 2014
# NCEAS Group OSS2014 
# @ajpelu 
# v1.0 

# Load packages 
library(RCurl)

# Set the directory 
di <- '/Users/ajpeluLap/myrepos/Drought_CA/pdsi/stpdsi/data/raster/2000'
setwd(di)


#### run only a time!!!!! ########
# Raster data about scPDSI 
# http://www.wrcc.dri.edu/wwdt/archive.php?folder=scpdsi
# Loop to download the raster data 

for (y in 2000:2014) { 
# Get the url
  url.aux <- paste('http://www.wrcc.dri.edu/monitor/WWDT/data/PRISM/scpdsi/scpdsi_',y,'_', sep='')
  for (m in 1:12){
  url <- paste(url.aux,m,'_PRISM.nc', sep='') 
  filenamedest <- strsplit(url, split='http://www.wrcc.dri.edu/monitor/WWDT/data/PRISM/scpdsi/')[[1]][2]
  dest <- paste(y,sprintf("%02d",m),'.nc', sep='')
  download.file(url,dest)
}}



