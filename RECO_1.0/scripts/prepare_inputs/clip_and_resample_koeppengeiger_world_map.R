
library(sp)
library(rgdal)
library(raster)

### clip tiles from Koppen-Geiger world map ###

# get list of tiles
dates<- list.files("/input/MODIS/")
datefiles<- list.files(paste("/input/MODIS/",dates[1],sep=""))
tif<- datefiles[grep(datefiles, pattern=paste(product,".","*.tif",sep=""))] # select tifs 
tiles<- levels(factor(substr(tif,19,24)))

for (tile in tiles) {
  print(tile)
  # load climate classification
  clim<- readGDAL("/input/koppen-geiger/Koppen_geiger_kottek_aggregated_world.tif",silent=TRUE)
  # load tile to clip 
  clip<- readGDAL(paste("/input/MODIS/",tile,".tif",sep=""),silent=TRUE) 

  # clip
  clim_crop<- crop(raster(clim),clip)
  # resample to same reference resolution
  clim_resa<- resample(clim_crop,raster(clip),method="ngb")

  kg<- as(clim_resa,"SpatialGridDataFrame")
  kg$band1<- round(kg$band1)

  if (!file.exists("/input/koppen-geiger/tiles/")) dir.create("/input/koppen-geiger/tiles/")   

  writeGDAL(kg,paste("/input/koppen-geiger/tiles/koppen_geiger_kottek_aggregated_resample_",tile,".tif",sep=""))
  rm(clim,LST,clim_crop,clim_resa,kg)
  gc()

}