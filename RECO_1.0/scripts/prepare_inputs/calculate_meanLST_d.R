
library(sp)
library(rgdal)
library(raster)


##########################
### calculate mean LST ###
##########################

workd<- "input/MODIS/"
product<- c("LSTday")

dates<- list.files(workd) # files are listed by dates on harddrive
dates<- dates[grep(dates,pattern="2003")]

datefiles<- list.files(paste(workd,"/",dates[1],sep=""))
tif<- datefiles[grep(datefiles, pattern=paste(product,".","*.tif",sep=""))] # select tifs 
tiles<- levels(factor(substr(tif,19,24)))

tiles<- c("h21v03","h21v04","h21v05","h21v06")

for (tile in tiles) {

  print(tile)

  grid<- readGDAL(paste(workd,dates[1],"/LSTday.2003.01.01.",tile,".gapfilled.tif",sep=""),silent=TRUE)
  grid$band1[1:length(grid$band1)]<- NA

  LST.array<- array(NA,dim=c(summary(grid)$grid[2,"cells.dim"],summary(grid)$grid[1,"cells.dim"],length(dates)))
  dimnames(LST.array)[[3]]<- dates

  for (date in dates) { 
    if (file.exists(paste(workd,date,"/LSTday.",date,".",tile,".gapfilled.tif",sep=""))==TRUE) {
      LSTd<- readGDAL(paste(workd,date,"/LSTday.",date,".",tile,".gapfilled.tif",sep=""),silent=TRUE)
      LST.array[,,date]<- LSTd$band1 
      rm(LSTd)
      gc()
    } else {
      LST.array[,,date]<- NA
    }
  } # date loop

  lst.mean<- apply(LST.array,MARGIN=c(1,2),FUN=mean,na.rm=TRUE)
  lst.mean[is.nan(lst.mean)]<- NA

  countna<- function(x) {sum(is.na(x))}
  lst.count<- apply(LST.array,MARGIN=c(1,2),FUN=countna)

  LST.mean<- grid
  LST.mean$band1<- array(lst.mean,dim=c((summary(grid)$grid[2,"cells.dim"]*summary(grid)$grid[1,"cells.dim"]),1))
  LST.count<- grid
  LST.count$band1<- array(lst.count,dim=c((summary(grid)$grid[2,"cells.dim"]*summary(grid)$grid[1,"cells.dim"]),1))

  writeGDAL(LST.mean,paste(workd,"meanLST/LSTmean.2003.",tile,".tif",sep=""))
  writeGDAL(LST.count,paste(workd,"meanLST/LST.na.count.2003.",tile,".tif",sep=""))
  rm(LST.mean,grid,lst.mean,LST.array,lst.count,LST.count)
  gc()

} # tile loop
