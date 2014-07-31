
rm(list=ls(all=TRUE))
gc()

library(sp)
library(rgdal)
library(raster)

countna<- function(x) {sum(is.na(x))}

##########################
### calculate mean EVI ###
##########################


workd<- paste(dir,"/input/MODIS/",sep="")
product<- c("EVI")

dates<- list.files(paste(workd,"/SR/",sep="")) # files are listed by dates on harddrive
dates<- dates[grep(dates,pattern="2003")]

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

sum<- array(0,dim=length(grid$band1))
count<- array(0,dim=length(grid$band1))

for (i in 1:length(dates)) { 
  if (file.exists(paste(workd,"/SR/",dates[i],"/EVI.",dates[i],".",tile,".resample.gapfilled.tif",sep=""))==TRUE) {
    EVI<- readGDAL(paste(workd,"/SR/",dates[i],"/EVI.",dates[i],".",tile,".resample.gapfilled.tif",sep=""),silent=TRUE)

    EVI$band1[EVI$band1>1 | EVI$band1<0] <- NA

    sum<- sum + ifelse(!is.na(EVI$band1),EVI$band1,0)
    count<- count + ifelse(!is.na(EVI$band1),1,0)
                  
    rm(EVI)
    gc()  
    print(paste(dates[i],"used ###"))

  }
} # date loop
gc()

evi.mean<- ifelse(count>0,sum / count,0)
rm(sum,count)

EVI.mean<- grid
EVI.mean$band1<- array(evi.mean,dim=c((summary(grid)$grid[2,"cells.dim"]*summary(grid)$grid[1,"cells.dim"]),1))
rm(grid)
gc()

print("write to file")
writeGDAL(EVI.mean,paste(workd,"/SR/meanEVI/EVImean.2003.",tile,".tif",sep=""))
rm(EVI.mean,evi.mean)
gc()

## --------------------------------------------------------------- ##

print("done!!!")


