
library(sp)
library(rgdal)
library(raster)
library(bitops)

### ---------------------------------------------

b2c <- character(256)
for (i in 0:255){
    b2c[i + 1] <- sprintf("%1d%1d%1d%1d%1d%1d%1d%1d"
         , bitAnd(i, 0x80) != 0
         , bitAnd(i, 0x40) != 0
         , bitAnd(i, 0x20) != 0
         , bitAnd(i, 0x10) != 0
         , bitAnd(i, 0x8) != 0
         , bitAnd(i, 0x4) != 0
         , bitAnd(i, 0x2) != 0
         , bitAnd(i, 0x1) != 0
         )
 }

int2bin<- function(val){
     b2c[bitAnd(val, 0xff) + 1]
 }

int2bin16<- function(val) {
    paste(int2bin(val%/%256),int2bin(val),sep="")
}

int2bin32<- function(val) {  
    paste(int2bin(val%/%256^3),int2bin(val%/%256^2),int2bin(val%/%256),int2bin(val),sep="")
}

### ---------------------------------------------

######################################
### generate Land Cover input maps ###
######################################
#quality check, aggregate biomes, aggregate to generic 1km resolution, produce water mask to overlay other input maps 

workd<- "path_to_MODIS_landcover_files"
workdest<- "destination_path"
product<- c("MCD12Q1")

date<- list.files(workd) # files are listed by dates

datefiles<- list.files(paste(workd,date,sep=""))
if (file.exists(paste(workdest,date,sep=""))==FALSE) {
  dir.create(paste(workdest,date,sep=""))
}

### ---------------------------------------------

tif<- datefiles[grep(datefiles, pattern=paste(product,".","*.tif",sep=""))] # select tifs 
tiles<- levels(factor(substr(tif,22,27)))

if(length(grep("index=",commandArgs(T)))==1) {
	pos <- grep("index=",commandArgs(T))
	index <- as.integer(strsplit(commandArgs(T)[pos],"index=")[[1]][2])
} else {
index<- 1
print("warning: just test run without index loop")
}
print(index)

tiles <- tiles[index]

for (tile in tiles) {
  print(tile)

  lc<- readGDAL(paste(workd,date,"/",product,".A.",date,".",tile,".005.Land_Cover_Type_1.tif",sep=""),silent=TRUE)  
  lc.ass<- readGDAL(paste(workd,date,"/",product,".A.",date,".",tile,".005.Land_Cover_Type_1_Assessment.tif",sep=""),silent=TRUE)
  print("read GDAL complete")

  ### set bad qc to NA

  lc$band1[lc.ass$band1 < 50] <- 254 # assessment, unclassified, barren land, snow/ice, urban build-up
  rm(lc.ass)
  gc()

  ### aggregate biomes

  biome<- c(rep(NA,length(lc$band1)))
  biome[lc$band1 %in% c(1,2,3,4,5)]<- 2 # Forests
  biome[lc$band1 %in% c(6,7,8,9,10,11)]<- 1 # Shrublands, Savannas, Grasslands, Permanent Wetlands
  biome[lc$band1 %in% c(12,14)]<- 3 # Cropland / crop/natural Vegetation mosaic,
  biome[lc$band1 %in% c(16)]<- 4 # barren land    
  biome[lc$band1 %in% c(15)]<- 5 # snow/ice    
  biome[lc$band1 %in% c(13)]<- 6 # urban build-up    
  biome[lc$band1 == 0]<- 0 # Water
  biome[lc$band1 == 254]<- NA
  biome[lc$band1 == 255]<- 255 # fill value
  
  lc.biome<- lc
  lc.biome$band1<- biome  
  rm(lc,biome)
  gc()

  ### produce 1km aggregation
  print("focal")
  print(is.numeric(lc.biome$band1))
  lc.biome<- focal(raster(lc.biome),w=3,fun=modal,na.rm=TRUE,NAonly=TRUE) # filter out some NA's
  print(is.numeric(lc.biome[]))

  print("aggregation")
  lc.biome.agg<- aggregate(lc.biome,fact=2,fun=modal,expand=FALSE,na.rm=TRUE) # most frequent land cover is used in aggregation, as for ties, random selection
  print(is.numeric(lc.biome.agg[]))
  
  lc.biome.agg[][is.na(lc.biome.agg[])]<- 254
  print(is.numeric(lc.biome.agg[]))

  ### shift cellcentre.offset
  load<- paste("/input/MODIS/LST/",date,"/LSTnight.",date,".",tile,".gapfilled.tif",sep="")
  LST<- readGDAL(load,silent=TRUE)

  xshift<- summary(LST)$grid[1,1]-summary(as(lc.biome.agg,"SpatialGridDataFrame"))$grid[1,1]
  yshift<- summary(LST)$grid[2,1]-summary(as(lc.biome.agg,"SpatialGridDataFrame"))$grid[2,1]

  print("shifting")
  lc.biome.agg<- shift(lc.biome.agg,x= xshift,y= yshift)
  LC<- as(lc.biome.agg,"SpatialGridDataFrame")    
  rm(lc.biome.agg)
  gc()
#   print(paste("LC$band1 : ",is.numeric(LC$band1)))
#   print(paste("LC$V1 : ",is.numeric(LC$V1)))

  ### crop/expand
  if ((summary(LST)$grid[1,3]<summary(LC)$grid[1,3]) | (summary(LST)$grid[2,3]<summary(LC)$grid[2,3])) {

    LCr<- crop(raster(LC),raster(LST))
    LC<- as(LCr,"SpatialGridDataFrame")
    rm(LCr)
    gc()
  }

  if ((summary(LST)$grid[1,3]>summary(LC)$grid[1,3]) | (summary(LST)$grid[2,3]>summary(LC)$grid[2,3])) {

    LCr<- expand(raster(LC),raster(LST))
    
    LCr[,summary(LST)$grid[1,3]]<- LCr[,summary(LC)$grid[1,3]]
    LCr[summary(LST)$grid[2,3],]<- LCr[summary(LC)$grid[2,3],]
    
    LC<- as(LCr,"SpatialGridDataFrame")
    rm(LCr)
    gc()
  }

  print("LST grid")
  print(summary(LST)$grid)
  print("LC grid")
  print(summary(LC)$grid)

  if (sum(summary(LST)$grid[,3]==summary(LC)$grid[,3])!=2) {
    print("!!! Warning: Grid is not equal !!!")
  }

  ### write Geotiff
  print("write GDAL")

  writeGDAL(LC,paste(workdest,date,"/landcover.",date,".",tile,".aggregated.tif",sep=""))
  rm(LC,LST)
  gc()

} # tile loop

print("done!!!")



