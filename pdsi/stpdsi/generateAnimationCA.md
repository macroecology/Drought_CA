In this script we created a png file with monthly values of scPDSI for California from 2000 to 2014.

``` {.r}
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
```

``` {.r}
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
```

First we need to list the *.nc files* within the directory

``` {.r}
#-------------------------------------------------------------------
# Set the directory and list the files (.nc) within the directory
di <- '/Users/ajpeluLap/myrepos/Drought_CA/pdsi/stpdsi'
setwd(paste(di,'/data/raster/2000/', sep=''))
pdsi<- list.files()
#-------
```

We need to set the boundaries of the California State. For this we used [Global Administratives Areaas](http://www.gadm.org/). You can download the shapefile or upload directly the spatial data into R.

``` {.r}
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
#--------------------------------------------------------------------
```

Now we read the .nc data into R. We convert the .nc into raster, then we reclassify the raster values according to [National Drought Mitigation Center](http://drought.unl.edu/Planning/Monitoring/ComparisonofIndicesIntro/PDSI.aspx). For this we created a classification matrix. Then we mask the raster only with data of california state. The next step is the reclassification of the raster layer. Then we crop the raster with boundaries of california and finally we create a stack with all the raster layers.

``` {.r}
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
```

``` {.r}
#-------------------------------------------------------------------
# Boundaries 
boundaries <- map('state', region='california', plot=FALSE) 
boundaries <- map2SpatialLines(boundaries)
```

Finally we set the customized palette to use in the plot (according to reclassification done, see below). We also set the directory to save the *'png'* files, and plot. Each *'png'* file has a title embeded in the plot. The structure of the title is: 'Xyyyymm.nc', where yyyy is the year and mm is the month.

``` {.r}
#-------------------------------------------------------------------
# Plots to create png files

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
```

Finally, once we created all *'png'* files we convert them into a video. See [Perpinan (2014)](https://github.com/oscarperpinan/spacetime-vis) for an example. In our case we used [FFmpeg](http://ffmpeg.org/). We typed in the shell:

    ffmpeg -f concat -i time_video.txt -vf fps=55 -pix_fmt yuv420p CAdrought2000_2014_scPDSI.mp4

The time\_video.txt is a file with the names of the pngs and the duration of each image. You can find more info about the conversion [here](https://trac.ffmpeg.org/wiki/Create%20a%20video%20slideshow%20from%20images) and [here](http://superuser.com/questions/533695/how-can-i-convert-a-series-of-png-images-to-a-video-for-youtube)

Sources:

-   Raster maps from [West Wide Drought Tracker](http://www.wrcc.dri.edu/wwdt/) [accessed 25 July 2014]
-   [Perpinan (2014)](http://oscarperpinan.github.io/spacetime-vis/). Displaying time series, spatial, and space-time data with R. Chapman & Hall/CRC The R Series. [accessed 25 July 2014]
