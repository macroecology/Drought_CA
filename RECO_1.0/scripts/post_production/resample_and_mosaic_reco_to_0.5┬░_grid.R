
rm(list=ls(all=TRUE))
gc()

library(raster)

workd<- paste(dir,"/ouput/annual_mosaic/resampled/",sep="")
tiles<- list.files(workd)

### --------- ###
### mosaic...
### --------- ###
raster.mosaic<- raster(paste(workd,tiles[1],sep=""))

for(i in 2:length(tiles)) {
  print(i)

  reco<- raster(paste(workd,tiles[i],sep=""))
  raster.mosaic <- mosaic(raster.mosaic,reco,fun=mean,na.rm=TRUE)

}

rm(reco)

### ------------------------------------------###

print("writing 1km file...")

raster.mosaic_sg<- as(raster.mosaic,"SpatialGridDataFrame")
writeGDAL(raster.mosaic_sg,paste(dir,"/output/annual_mosaic/Reco_2003_mosaic.tif",sep=""))
rm(raster.mosaic_sg)

### ------------------------------------------###

print("resampling...")
# create 0.5° grid to resample mosaic
lpj.raster <- raster(extent(-150, 45, 20, 80),crs=projection(raster.mosaic))
res(lpj.raster) <- 0.5 #res(input.rasters[[5]])

lpj.raster<- resample(raster.mosaic,lpj.raster,method="bilinear")
lpj.raster[is.na(lpj.raster)]<- -99999

### ------------------------------------------###
print("writing 0.5 grid to file... ")

writeRaster(lpj.raster, 
    filename=paste(dir,"/output/annual_mosaic/Reco_2003_mosaic_0.5degree.tif",sep=""),overwrite=TRUE)

rm(lpj.raster,raster.mosaic)

### ------------------------------------------###

