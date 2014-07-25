# GO TO: http://r-gis.net/?q=ModisDownload 

# setting the working directory:

setwd('c:/download_modis')

# loading the source of function (the script file should be copied in the working directory):

source('http://r-gis.net/ModisDownload/ModisDownload.R')

library(raster)

library(RCurl)

# product list:

modisProducts( )

x="MOD11A2"

# download 3 tiles (h09v04, h08v04, h08v05)

# Following command only downloads the source HDF images, no mosaic and no projection

#ModisDownload(x=x,h=c(8,9),v=c(4,5),dates=c('2014.07.01','2014.07.12'),mosaic=F,proj=F)

#OR

# Downloads selected tiles, and mosaic them, but no projections:

#ModisDownload(x=x,h=c(8,9),v=c(4,5),dates=c('2014.07.01','2014.07.12'),MRTpath='C:/MRT/bin',mosaic=T,proj=F)

#C:\MRT\bin

#--- alternatively, you can first download the HDF images using getMODIS, and then mosaic them using mosaicHDF!

# Downloads selected tiles, and mosaic, reproject them in UTM_WGS84, zone 30 projection and convert all bands into Geotif format (the original HDF will be deleted!):

##ModisDownload(x=x,h=c(17,18),v=c(4,5),dates=c('2011.05.01','2011.05.31'),MRTpath='d:/MRT/bin', mosaic=T,proj=T,proj_type="UTM",utm_zone=30,datum="WGS84",pixel_size=1000)

ModisDownload(x=x,h=c(8,9),v=c(4,5),dates=c('2014.07.01','2014.07.12'),MRTpath='C:/MRT/bin', mosaic=T,proj=T,proj_type="UTM",utm_zone=11,datum="WGS84",pixel_size=1000)


# Same as above command, but only second band out of 6 bands will be kept. (You do not need to specify proj_params when "UTM" is selected as proj_type and the zone also is specified, but for other types of projections you do).

#ModisDownload(x=x,h=c(17,18),v=c(4,5),dates=c('2011.05.01','2011.05.31'),MRTpath='d:/MRT/bin',mosaic=T,proj=T, bands_subset="0 1 0 0 0 0", proj_type="UTM",proj_params="-3 0 0 0 0 0 0 0 0 0 0 0 0 0 0",utm_zone=30,datum="WGS84",pixel_size=1000)



# Same as above command, but it spatially subsets the images into the specified box (UL and LR):

#ModisDownload(x=x,h=c(17,18),v=c(4,5),dates=c('2011.07.01','2011.07.31'),MRTpath='d:/MRT/bin',mosaic=T,proj=T,UL=c(-42841.0,4871530.0),LR=c(1026104,3983860), bands_subset="0 1 0 0 0 0", proj_type="UTM",proj_params="-3 0 0 0 0 0 0 0 0 0 0 0 0 0 0",utm_zone=30,datum="WGS84",pixel_size=1000)



In order to load, work, and visualize the downloaded images, the raster and rgdal packages can be used. Following, a simple example is provided that show you how to read and plot the images: You can also use rts package to create an raster time series object. Very soon, these functions will be included to rts package.



# setting the working directory:

setwd('C:/download_modis')

library(raster)

# A function to list the files, ended with '.tif', in the working directory

listfiles <- list.files(pattern='.tif$')

listfiles

# function to read an image or images

lst <- raster("MOD11A2_2014-07-04.LST_Day_1km.tif")
lst
plot(lst)