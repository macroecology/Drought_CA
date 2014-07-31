
### run from local machine (RCUrl is not installed on the cluster's R)

library(rgdal)
library(RCurl)

options(download.file.method="auto")

tiles<- c("h12v01","h13v01","h14v01","h15v01","h16v01","h17v01","h18v01","h19v01","h20v01","h09v02","h10v02","h11v02","h12v02","h13v02","h14v02","h15v02","h16v02","h17v02","h18v02","h19v02","h20v02","h07v03","h08v03","h09v03","h10v03","h11v03","h12v03","h13v03","h14v03","h15v03","h17v03","h18v03","h19v03","h20v03","h08v04","h09v04","h10v04","h11v04","h12v04","h13v04","h14v04","h17v04","h18v04","h19v04","h20v04","h07v05","h08v05","h09v05","h10v05","h11v05","h12v05","h15v05","h16v05","h17v05","h18v05","h19v05","h20v05","h07v06","h08v06","h09v06","h10v06","h11v06","h16v06","h17v06","h18v06","h19v06","h20v06")
# tiles that are plain ocean or fill c("h07v04","h08v02","h12v06","h13v05","h13v06","h14v05","h14v06","h15v04","h15v06","h16v03","h16v04")

################################################
### Download MODIS LST (Terra) (MOD11A2.005) ###
################################################

# product<- "MOD11A2"
# workd<- "/scratch/01/jonasjae/MODIS/LST"
# 
# dates<- list.files(workd)
# 
# for (date in dates){ 
#   print(date)
#   down<- read.table(paste(workd,"/",date,"/downfiles_",product,".txt",sep=""))
#   down<- down[,1]
#   dest<- read.table(paste(workd,"/",date,"/destfiles_",product,".txt",sep=""))
#   dest<- dest[,1]
# 
#   for (i in length(down)) {
#     print(dest[i])
# 
#     if (file.exists(paste(dest[i]))==FALSE | file.info(paste(dest[i]))$size==0){
#       
#       #download files
#       download.file(url=paste(down[i]), destfile=paste(dest[i]), mode='wb', method='wget', quiet=T, cacheOK=FALSE)
#     } # if existing or zero
#   } # tiles loop
# } # i loop  
# 
# print("LST Terra is done!")


################################################
### Download MODIS LST (Aqua) (MYD11A2.005) ###
################################################

product<- "MYD11A2"
workd<- "/input/MODIS/LST"

dates<- list.files(workd)

for (date in dates){ 
  print(date)
  down<- read.table(paste(workd,"/",date,"/downfiles_",product,".txt",sep=""))
  down<- down[,1]
  dest<- read.table(paste(workd,"/",date,"/destfiles_",product,".txt",sep=""))
  dest<- dest[,1]

  for (i in length(down)) {
    print(dest[i])

    if (file.exists(paste(dest[i]))==FALSE | file.info(paste(dest[i]))$size==0){
      
      #download files
      download.file(url=paste(down[i]), destfile=paste(dest[i]), mode='wb', method='wget', quiet=T, cacheOK=FALSE)
    } # if existing or zero
  } # tiles loop
} # i loop  
 
print("LST Aqua is done!")

################################################
### Download MODIS EVI (Terra) (MOD09A1.005) ###
################################################

# product<- "MOD09A1"
# workd<- "/input/MODIS/SR" # for the wget command on clutser terminal...
# dates<- list.files(workd)
# 
# for (date in dates){ 
#   print(date)
#   down<- read.table(paste(workd,"/",date,"/downfiles_",product,".txt",sep=""))
#   down<- down[,1]
#   dest<- read.table(paste(workd,"/",date,"/destfiles_",product,".txt",sep=""))
#   dest<- dest[,1]
# 
#   for (i in length(down)) {
#     print(dest[i])
# 
#     if (file.exists(paste(dest[i]))==FALSE | file.info(paste(dest[i]))$size==0){
#       
#       #download files
#       download.file(url=paste(down[i]),destfile=paste(dest[i]), mode='wb', method='wget', quiet=T, cacheOK=FALSE)
#     } # if existing or zero
#   } # tiles loop
# } # i loop  
# 
# 
# print("EVI Terra is done!")

################################################
### Download MODIS EVI (Aqua) (MYD09A1.005) ###
################################################

# product<- "MYD09A1"
# workd<- "/input/MODIS/SR"
# dates<- list.files(workd)
# 
# for (date in dates){ 
#   print(date)
#   down<- read.table(paste(workd,"/",date,"/downfiles_",product,".txt",sep=""))
#   down<- down[,1]
#   dest<- read.table(paste(workd,"/",date,"/destfiles_",product,".txt",sep=""))
#   dest<- dest[,1]
# 
#   for (i in length(down)) {
#     print(dest[i])
# 
#     if (file.exists(paste(dest[i]))==FALSE | file.info(paste(dest[i]))$size==0){
#       
#       #download files
#       download.file(url=paste(down[i]), destfile=paste(dest[i]), mode='wb', method='wget', quiet=T, cacheOK=FALSE)
#     } # if existing or zero
#   } # tiles loop
# } # i loop  
#  
# 
# print("EVI Aqua is done!")


################################################
### Download MODIS Landcover (MCD12Q1.005)   ###
################################################

# product<- "MCD12Q1"
# workd<- "/input/MODIS/landcover"
# dates<- list.files(workd)
# 
# for (date in dates){ 
#   print(date)
#   down<- read.table(paste(workd,"/",date,"/downfiles_",product,".txt",sep=""))
#   down<- down[,1]
#   dest<- read.table(paste(workd,"/",date,"/destfiles_",product,".txt",sep=""))
#   dest<- dest[,1]
# 
#   for (i in length(down)) {
#     print(dest[i])
# 
#     if (file.exists(paste(dest[i]))==FALSE | file.info(paste(dest[i]))$size==0){
#       
#       #download files
#       download.file(url=paste(down[i]), destfile=paste(dest[i]), mode='wb', method='wget', quiet=T, cacheOK=FALSE)
#     } # if existing or zero
#   } # tiles loop
# } # i loop  
# 
# 
# print("Landcover is done!")
