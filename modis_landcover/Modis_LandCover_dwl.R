# Title:  ModisLandCover_dwl.R
# 4 Aug. 2014
# Author: Tim Assal
#code adapted from Babak Naimi (naimi@r-gis.net)

# GO TO: http://r-gis.net/?q=ModisDownload 
#Ensure the file ModisLP.RData is in your working directory
#alternatively, download it from above link (right click save link as)

#!!IMPORTANT
##!!! change x below to the proper MODIS product
##!! ensure the proper 3 digit code (eg. 005 or 051 in the ModisDownload.R file)
  # do a search and replace to ensure all ~5 instances of the 3 digit code is changed)
  # in the ModisDownload.R file
##!!You must download the MODIS MRT tool and set the MRTPath below

# setting the working directory:
setwd('C:/Assal_working/download_modis_lc')
#check working directory
getwd()

# loading the source of function (the script file should be copied in the working directory):
#source('http://r-gis.net/ModisDownload/ModisDownload.R')
source("ModisDownload.R")

library(raster)
library(RCurl)
library(bitops)
# product list:

modisProducts( ) 
#landcover 
x="MCD12Q1" #change between Q1 and Q2
#test<-.modisHTTP (x,v='051') #change between 051 and 005 dependent upon MODIS project
x

# download 3 tiles (h09v04, h08v04, h08v05) for the state of CA

# Following command only downloads the source HDF images, no mosaic and no projection
#ModisDownload(x=x,h=c(8,9),v=c(4,5),dates=c('2012.01.01'),mosaic=F,proj=F)

#OR

# Downloads selected tiles, and mosaic them, but no projections:
#ModisDownload(x=x,h=c(8,9),v=c(4,5),dates=c('2014.07.01','2014.07.12'),MRTpath='C:/MRT/bin',mosaic=T,proj=F)

#--- alternatively, you can first download the HDF images using getMODIS, and then mosaic them using mosaicHDF!

# Downloads selected tiles, and mosaic, reproject them in UTM_WGS84, zone 30 projection and convert all bands into Geotif format (the original HDF will be deleted!):
##ModisDownload(x=x,h=c(17,18),v=c(4,5),dates=c('2011.05.01','2011.05.31'),MRTpath='d:/MRT/bin', mosaic=T,proj=T,proj_type="UTM",utm_zone=30,datum="WGS84",pixel_size=1000)

ModisDownload(x=x,h=c(8,9),v=c(4,5),dates=c('2012.01.01'),MRTpath='C:/MRT_download_win/bin', mosaic=T,proj=T,
               proj_type="UTM",utm_zone=11,datum="WGS84",pixel_size=500)


# Same as above command, but only second band out of 6 bands will be kept. (You do not need to specify proj_params when "UTM" is selected as proj_type and the zone also is specified, but for other types of projections you do).
#ModisDownload(x=x,h=c(17,18),v=c(4,5),dates=c('2011.05.01','2011.05.31'),MRTpath='d:/MRT/bin',mosaic=T,proj=T, bands_subset="0 1 0 0 0 0", proj_type="UTM",proj_params="-3 0 0 0 0 0 0 0 0 0 0 0 0 0 0",utm_zone=30,datum="WGS84",pixel_size=1000)

# Same as above command, but it spatially subsets the images into the specified box (UL and LR):
#ModisDownload(x=x,h=c(17,18),v=c(4,5),dates=c('2011.07.01','2011.07.31'),MRTpath='d:/MRT/bin',mosaic=T,proj=T,UL=c(-42841.0,4871530.0),LR=c(1026104,3983860), bands_subset="0 1 0 0 0 0", proj_type="UTM",proj_params="-3 0 0 0 0 0 0 0 0 0 0 0 0 0 0",utm_zone=30,datum="WGS84",pixel_size=1000)

#In order to load, work, and visualize the downloaded images, the raster and rgdal packages can be used. Following, a simple example is provided that show you how to read and plot the images: You can also use rts package to create an raster time series object. Very soon, these functions will be included to rts package.

library(raster)

# A function to list the files, ended with '.tif', in the working directory
listfiles <- list.files(pattern='.tif$')
listfiles

# function to read an image or images
ca_lc <- raster("MCD12Q1_2012-01-01.Land_Cover_Type_1.tif")
ca_lc
plot(ca_lc)

#look up table for land use codes
#https://lpdaac.usgs.gov/products/modis_products_table/mcd12q1


