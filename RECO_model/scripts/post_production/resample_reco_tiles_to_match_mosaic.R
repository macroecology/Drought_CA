
rm(list=ls(all=TRUE))
gc()

library(raster)
library(rgdal)

### Parallelization 
library(Rmpi)
library(doMPI)
library(foreach)
if(length(grep("parallel=",commandArgs(T)))==1) {
  pos <- grep("parallel=",commandArgs(T))
  parallel <- as.logical(strsplit(commandArgs(T)[pos],"parallel=")[[1]][2])
  if(is.na(parallel)==T) stop("Error: command line argument parallel mustbe either true or false")
} else parallel <- FALSE # try to parallelize some loops (may also be set by command line argument)

if(parallel==T) {
  cl <- startMPIcluster()
  num.cluster <- clusterSize(cl)
  if (num.cluster > 1) {
    registerDoMPI(cl)
    print("********************")
    print(paste("Running in parallel mode on",num.cluster,"worker nodes."))
  } else {
    registerDoSEQ()
    print("********************")
    print("Running in sequential mode.")
  }
} else {
  registerDoSEQ()
  print("********************")
  print("Running in sequential mode.")
  num.cluster <- 0
}

workd<- paste(dir,"/output/annual_sum/",sep="")
tiles<- list.files(workd) # files are listed by dates on harddrive
tiles<- tiles[grep(tiles,pattern=c("Reco_sum.2003"))]

#####################################################################

cluter.jobs<- foreach(tile=tiles, .inorder=FALSE, .options.mpi=list(info=TRUE), .verbose=TRUE) %dopar%  { 
  ###
  
  if (parallel==TRUE) {
    sinkWorkerOutput(paste(dir,"/path_to_output_error_file/resample_and_mosaic_",substr(tile,15,20),"_output.txt",sep=""))
  }
  
  # read the individual tiles
  print(tile)
  reco <- raster(paste(workd,tile,sep=""))
  
  # create an empty output raster that spans the full extent of all input
  # rasters, and uses the same coordinate reference system; in this case
  # we know that all input rasters share the same CRS, so we can
  # arbitrarily extract CRS information from the first one
  
  e <- extent(-150, 45, 20, 80)
   
  # crop input ratsers to max extent e
  reco<- crop(reco,e)
  
  # set the output resolution to match the center tile (somewhat
  # arbitrarily); this can also be specified manually if preferred
  bounding.raster <- raster(e,crs=projection(reco))
  res(bounding.raster) <- 0.01
 
  # for each input raster, extract the corresponding sub-extent of the
  # empty output raster, and use this as the basis for resampling
  
  target.raster <- crop(bounding.raster,reco)
  reco.res<- resample(reco,target.raster, method="bilinear")

  rm(target.raster,bounding.raster,reco)

  if(sum(!is.na(reco.res[]))>0) {
  writeGDAL(as(reco.res,"SpatialGridDataFrame"),paste(dir,"/output/annual_mosaic/resampled/Reco_sum_2003.",tile,".resampled_to_mosaic.tif",sep=""),drivername = "GTiff")
  }
  
} # tile loop

if (parallel==TRUE) {
  closeCluster(cl)
}

print("Done!!!")

### ------------------------------------------###
