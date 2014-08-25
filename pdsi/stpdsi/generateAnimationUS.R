#-------------------------------------------------------------------
# Script create png files for video of PDSI raster from 2000 to 2014
# August, 2014
# NCEAS Group OSS2014 
# @ajpelu (Antonio J. Perez-Luque)
# v1.0 
# Spatial coverage = US
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
di <- '/Users/ajpeluLap/myrepos/stpdsi'
setwd(paste(di,'/data/raster/2000/', sep=''))
pdsi<- list.files()
#-------------------------------------------------------------------

#-------------------------------------------------------------------
# Loop to create Stack of pdsi
# Create a empty stak 
mapas <- stack()

# Define a matrix of clasification for reclass 
from=c(-50,-4.99,-3.99,-2.99,-1.99,-0.99,-0.49, 0.5,1,2,3,4,5)
to=c(-5,-4,-3,-2,-1,-0.5,0.49,.99,1.99,2.99,3.99,4.99,50)
nv=c(-5,-4,-3,-2,-1,-0.5,0,0.5,1,2,3,4,5) 

cla <- as.matrix(cbind(from,to,nv))

for (i in 1:length(pdsi)){
  # Create raster from .nc   
  ras<- raster (pdsi[i])
  
  # Reclassify according  to PalmerDrought categories
  rc <- reclassify(ras, cla)
  
  # Assing name of file to layer of raster
  names(rc) <- pdsi[i]
  mapas <- stack (mapas, rc)
}
#-------------------------------------------------------------------

#-------------------------------------------------------------------
# Plots to create png files
# Boundaries 
projLL <- CRS('+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0')
cftLL <- projectExtent(mapas, projLL)
cftExt <- as.vector(bbox(cftLL))
boundaries <- map('worldHires',
                  xlim=cftExt[c(1,3)], ylim=cftExt[c(2,4)],
                  plot=FALSE)
boundaries <- map2SpatialLines(boundaries, proj4string=projLL)

# Set custom palette
mitema4 <- rasterTheme(region=c('#a50026','#BE1827','#d73027','#f46d43','#fdae61','#fee08b',
                                '#ffffbf','#d9ef8b','#a6d96a','#66bd63','#1a9850','#0D8044',
                                '#006837'))

# Plot 
trellis.device(png, file=paste(di, '/animation/png/us/%03d.png', sep=''),
               res=300, width=1500, height=1500)
levelplot(mapas, layout=c(1, 1),
          par.settings=mitema4)+ 
  # at=seq(-7, 7, 1)) +
  layer(sp.lines(boundaries, lwd=0.6))
dev.off()
#-------------------------------------------------------------------