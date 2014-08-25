#-------------------------------------------------------------------
# Script create png files for video of PDSI raster from 2000 to 2014 for California
# August, 2014
# NCEAS Group OSS2014 
# @ajpelu (Antonio J. Perez-Luque)
# v1.0 
# Spatial coverage = California (US)
# Temporal coverage = 2000 - 2014, monthly
# Note: If you want to expand the temporal resolution, download the data first (raster). 
#       see the downloadPDSIraster.R script. 

#-------------------------------------------------------------------
# Load packages 
library(RCurl)
library(raster)
library(rgdal)
library(maptools)
library(rasterVis)
library(maps)
library(mapdata)
library(RColorBrewer)
#-------------------------------------------------------------------

#-------------------------------------------------------------------
# Set the directory and list the files (.nc) within the directory
di <- '/Users/ajpeluLap/myrepos/Drought_CA/pdsi/stpdsi'
setwd(paste(di,'/data/raster/2000/', sep=''))
pdsi<- list.files()
#-------------------------------------------------------------------

#--------------------------------------------------------------------
# Boundary of US states from Global Administrative Areas, http://www.gadm.org/
# Donwload shapefile and unzip 
# url <- 'http://biogeo.ucdavis.edu/data/gadm2/shp/USA_adm.zip'
# download.file(url, destfile=paste(di,'/data/shapefiles/USA_adm.zip', sep=''))
# unzip(paste(di,'/data/shapefiles/USA_adm.zip',sep=''))

# or Get data directly; shapefile("USA_adm1.shp")
setwd(paste(di,'/data/shapefiles', sep=''))
us <- getData("GADM", country="USA", level=1)
ca = us[us$NAME_1=='California',]

#-------------------------------------------------------------------
# Loop to create Stack of pdsi
# Create a empty stak 
setwd(paste(di,'/data/raster/2000/', sep=''))
mapas <- stack()

# Define a matrix of clasification for reclass 
from=c(-50,-4.99,-3.99,-2.99,-1.99,-0.99,-0.49, 0.5,1,2,3,4,5)
to=c(-5,-4,-3,-2,-1,-0.5,0.49,.99,1.99,2.99,3.99,4.99,50)
nv=c(-5,-4,-3,-2,-1,-0.5,0,0.5,1,2,3,4,5) 

cla <- as.matrix(cbind(from,to,nv))

# Extension of map 
extCA <- extent(c(xmin=-125, xmax=-113, ymin=31, ymax=43))

for (i in 1:length(pdsi)){
  # Create raster from .nc   
  ras<- raster (pdsi[i])
  
  # Mask of the raster
  mr <- mask(ras, ca)
  
  # Reclassify according  to PalmerDrought categories
  rc <- reclassify(mr, cla)
  
  # Crop raster
  rcc <- crop(rc, extCA)
  
  # Assing name of file to layer of raster
  names(rcc) <- pdsi[i]
  mapas <- stack (mapas, rcc)
  mapas <- crop(mapas, extCA)
}
#-------------------------------------------------------------------

#-------------------------------------------------------------------
# Plots to create png files
# Boundaries 
boundaries <- map('state', region='california', plot=FALSE) 
boundaries <- map2SpatialLines(boundaries)

# Set custom palette
mitema4 <- rasterTheme(region=c('#a50026','#BE1827','#d73027','#f46d43','#fdae61','#fee08b',
                                '#ffffbf','#d9ef8b','#a6d96a','#66bd63','#1a9850','#0D8044',
                                '#006837'))

# Plot 
trellis.device(png, file=paste(di, '/animation/png/ca/%03d.png', sep=''),
               res=300, width=1500, height=1500)

levelplot(mapas, layout=c(1, 1),
          par.settings=mitema4) +
  # at=seq(-7, 7, 1)) 
  layer(sp.lines(boundaries, lwd=0.6))
  
dev.off()
#-------------------------------------------------------------------