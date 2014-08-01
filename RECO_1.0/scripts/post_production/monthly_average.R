library(sp)
library(rgdal)
library(raster)

#################################
### calculate monthly average ###
#################################

workd<- "/output/"

dates<- list.files(workd,pattern="2003.") # files are listed by dates on harddrive

months<- unique(substr(dates,6,7))

datefiles<- list.files(paste(workd,"/",dates[2],sep=""))
tiles<-substr(datefiles,17,22)

###
if(length(grep("index=",commandArgs(T)))==1) {
	pos <- grep("index=",commandArgs(T))
	index <- as.integer(strsplit(commandArgs(T)[pos],"index=")[[1]][2])
} else {
index<- 1
print("warning: just test run without index loop")
}
print(index)

tiles <- tiles[index]
###

#####################################################################
for (month in months) {
print(paste("### ",month," ###"))

  if (file.exists(paste(workd,"monthly_average/",month,sep=""))==FALSE) {
  dir.create(paste(workd,"monthly_average/",month,sep=""))
  }
  monthdates<- dates[substr(dates,6,7)==month]

  for (tile in tiles) {

      grid<- readGDAL(paste(workd,dates[2],"/Reco.2003.01.09.",tile,".1km.tif",sep=""),silent=TRUE)
      grid$band1[1:length(grid$band1)]<- NA

      mon.array<- array(NA,dim=c(summary(grid)$grid[2,"cells.dim"],summary(grid)$grid[1,"cells.dim"],length(monthdates)))
      dimnames(mon.array)[[3]]<- monthdates

      for (monthdate in monthdates) { 
      	if (file.exists(paste(workd,monthdate,"/Reco.",monthdate,".",tile,".1km.tif",sep=""))==TRUE) {
      	  Reco<- readGDAL(paste(workd,monthdate,"/Reco.",monthdate,".",tile,".1km.tif",sep=""),silent=TRUE)
      	  mon.array[,,monthdate]<- Reco$band1 
      	  rm(Reco)
      	  gc()
      	} else {
      	  mon.array[,,monthdate]<- NA
      	}
      } # date loop

      reco.mean<- apply(mon.array,MARGIN=c(1,2),FUN=mean,na.rm=TRUE)
      reco.mean[is.nan(reco.mean)]<- NA

      Reco.mean<- grid
      Reco.mean$band1<- array(reco.mean,dim=c((summary(grid)$grid[2,"cells.dim"]*summary(grid)$grid[1,"cells.dim"]),1))

      writeGDAL(Reco.mean,paste(workd,"monthly_average/",month,"/Reco_mon.2003.",tile,".",month,".tif",sep=""))
      rm(Reco.mean,grid,reco.mean,mon.array)
      gc()

  } # tile loop
} # month loop

print("Done!!!")