
rm(list=ls(all=TRUE))
gc()

library(sp)
library(rgdal)
library(raster)

workd<- "working_directory_path"

countna<- function(x) {sum(is.na(x))}

##########################
### calculate mean EVI ###
##########################

# translated Tref into LSTnight
LSTn_ref<- read.table(paste(workd,"/par/LSTn_ref.txt",sep=""),header=TRUE,
                       sep=",",na.strings = "-9999")

product<- c("EVI")

dates<- list.files(paste(workd,"/SR/",sep="")) # files are listed by dates on harddrive
dates<- dates[grep(dates,pattern="2003")]
dates<- dates[1:23]

datefiles<- list.files(paste(workd,"/SR/",dates[2],sep=""))
tif<- datefiles[grep(datefiles, pattern=paste(product,".","*.tif",sep=""))] # select tifs 
tiles<- levels(factor(substr(tif,16,21)))

if(length(grep("index=",commandArgs(T)))==1) {
	pos <- grep("index=",commandArgs(T))
	index <- as.integer(strsplit(commandArgs(T)[pos],"index=")[[1]][2])
} else {
index<- 1
print("warning: just test run without index loop")
}
print(index)

tile <- tiles[index]

print(tile)

grid<- readGDAL(paste(workd,"/SR/",dates[2],"/EVI.",dates[2],".",tile,".resample.gapfilled.tif",sep=""),silent=TRUE)
grid$band1[1:length(grid$band1)]<- NA
clim<- readGDAL(paste(dir,"/input/koppen-geiger/tiles/Koppen_geiger_kottek_aggregated_resample_",tile,".tif",sep=""),silent=TRUE)
clim<- clim$band1
clim[is.na(clim)]<- 0 # climate class code: 1 = Temperature limited, 2 = Temperate/Humid, 3 = Mediterranean
lc<- readGDAL(paste(dir,"/input/MODIS/landcover/landcover.2003.01.01.",tile,".aggregated.tif",sep=""),silent=TRUE)
lc<- lc$band1 # land cover code: 1 = grass/shrub/savanna 2 = forest, 3 = cropland

EVI.array<- array(NA,dim=c(summary(grid)$grid[2,"cells.dim"],summary(grid)$grid[1,"cells.dim"],length(dates)))
dimnames(EVI.array)[[3]]<- dates

for (i in 1:length(dates)) { 
  if (file.exists(paste(workd,"/SR/",dates[i],"/EVI.",dates[i],".",tile,".resample.gapfilled.tif",sep=""))==TRUE) {
    EVI<- readGDAL(paste(workd,"/SR/",dates[i],"/EVI.",dates[i],".",tile,".resample.gapfilled.tif",sep=""),silent=TRUE)
    NDSI<- readGDAL(paste(workd,"/SR/",dates[i],"/NDSI.",dates[i],".",tile,".resample.gapfilled.tif",sep=""),silent=TRUE)
    if (file.exists(paste(workd,"/LST/",dates[i],"/LSTnight.",dates[i],".",tile,".gapfilled.tif",sep=""))==TRUE) {
      LST<- readGDAL(paste(workd,"/LST/",dates[i],"/LSTnight.",dates[i],".",tile,".gapfilled.tif",sep=""),silent=TRUE)
    
      EVI$band1[EVI$band1>1 | EVI$band1<0] <- NA
      LST<- LST$band1
      NDSI<- NDSI$band1

      ### -------------------------------------------------------------- ###
      ## erase EVi obs that are not within the right LST range (LSTn_ref)
      # TL
      EVI$band1[clim==1 & (LST< LSTn_ref["lwr","TL"]-2 | LST > LSTn_ref["upr","TL"]+5)]<- NA
      # TH
      EVI$band1[clim==2 & (LST< LSTn_ref["lwr","TH"]-2 | LST > LSTn_ref["upr","TH"]+5)]<- NA
      # ST
      EVI$band1[clim==3 & (LST< LSTn_ref["lwr","ST"]-2 | LST > LSTn_ref["upr","ST"]+5)]<- NA

      EVI$band1[NDSI > -0.1] <- NA
          
      EVI.array[,,dates[i]]<- EVI$band1 
  
      rm(EVI,LST)
      gc()  
      print(paste(dates[i],"used ###"))
    } # LST if loop
  } else {
    EVI.array[,,dates[i]]<- NA
    print(paste(dates[i]," missing!!!"))
    }

} # date loop
rm(lc,clim)
gc()

print("calc. mean EVI")
evi.mean<- apply(EVI.array,MARGIN=c(1,2),FUN=mean,na.rm=TRUE)
evi.mean[is.nan(evi.mean)]<- NA
rm(EVI.array)
gc()

EVI.mean<- grid
EVI.mean$band1<- array(evi.mean,dim=c((summary(grid)$grid[2,"cells.dim"]*summary(grid)$grid[1,"cells.dim"]),1))
rm(grid)
gc()

print("write to file")
writeGDAL(EVI.mean,paste(workd,"/SR/meanEVI_Tref/EVImean_Tref.2003.",tile,".tif",sep=""))
rm(EVI.mean,evi.mean)
gc()

## --------------------------------------------------------------- ##

print("done!!!")


