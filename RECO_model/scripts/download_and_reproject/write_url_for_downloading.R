
### run from local machine (RCUrl is not installed on the cluster's R)

library(rgdal)
library(RCurl)

tiles<- c("h12v01","h13v01","h14v01","h15v01","h16v01","h17v01","h18v01","h19v01","h20v01","h09v02","h10v02","h11v02","h12v02","h13v02","h14v02","h15v02","h16v02","h17v02","h18v02","h19v02","h20v02","h07v03","h08v03","h09v03","h10v03","h11v03","h12v03","h13v03","h14v03","h15v03","h17v03","h18v03","h19v03","h20v03","h08v04","h09v04","h10v04","h11v04","h12v04","h13v04","h14v04","h17v04","h18v04","h19v04","h20v04","h07v05","h08v05","h09v05","h10v05","h11v05","h12v05","h15v05","h16v05","h17v05","h18v05","h19v05","h20v05","h07v06","h08v06","h09v06","h10v06","h11v06","h16v06","h17v06","h18v06","h19v06","h20v06")
# tiles that are plain ocean or fill c("h07v04","h08v02","h12v06","h13v05","h13v06","h14v05","h14v06","h15v04","h15v06","h16v03","h16v04")

################################################
### Download MODIS LST (Terra) (MOD11A2.005) ###
################################################

# product<- "MOD11A2"
# print(product)
# workd<- "/input/MODIS/LST"
# ftp<- "ftp://e4ftl01.cr.usgs.gov/MOLT/MOD11A2.005/" # NASA ftp server
# 
# items <- strsplit(getURL(ftp), "\n")[[1]] # get the list of ftp directories
# 
# folderLines <- items[substr(items, 1, 1)=='d'] # kick out first line, only drwxr..
# 
# dirs <- unlist(lapply(strsplit(folderLines, " "), function(x){x[length(x)]})) # get names of date directories
# dates<- dirs[substr(dirs,1,4)==2003] # pick only data for 2003
# 
# for (date in dates){ 
#   print(date)
#   dir.create(paste(workd, "/", date,"/",sep=""))
# 
# 
#   files<- strsplit(getURL(paste(ftp,date,"/",sep="")),"\n")[1]
#   files<- files[[1]]    
#   hdf.lines<- files[substr(files,(nchar(files)-3),nchar(files))==".hdf"]
#   hdf.files<- unlist(lapply(strsplit(hdf.lines, " "), function(x){x[length(x)]})) 
#   sizes.lines<- unlist(lapply(hdf.lines,function(x){substr(x,1,25)})) 
#   sizes<- unlist(lapply(strsplit(sizes.lines, " "),function(x){x[length(x)]}))
# 
#   hdf.files<- cbind(hdf.files,sizes)
# 
#   downdest<- NULL
#   for (tile in tiles) {
#     #print(tile)
# 
#     tilename<- hdf.files[grep(pattern=tile,hdf.files),1]
#     size<- hdf.files[grep(pattern=tile,hdf.files),2]
#     url<- paste(ftp, date, "/", tilename,sep="")
#     destfile<- paste(workd, "/", date,"/",product,".A.",date,".",tile,".005.hdf",sep="")
#     
#     if (length(tilename)!=0) {
#     downdest<- rbind(downdest,c(url,destfile,size))
#     }
#   } # tiles loop
# 
#   write.table(downdest,paste(workd,"/",date,"/downdest_",product,".txt",sep=""),row.names=FALSE,col.names=FALSE,quote=FALSE)
#   #Sys.sleep(60)
# 
# } # date loop 
# 
# print("done!")


################################################
### Download MODIS LST (Aqua) (MYD11A2.005) ###
################################################

# product<- "MYD11A2"
# print(product)
# workd<- "/input/MODIS/LST"
# ftp<- "ftp://e4ftl01.cr.usgs.gov/MOLA/MYD11A2.005/" # NASA ftp server
# 
# items <- strsplit(getURL(ftp), "\n")[[1]] # get the list of ftp directories
# 
# folderLines <- items[substr(items, 1, 1)=='d'] # kick out first line, only drwxr..
# 
# dirs <- unlist(lapply(strsplit(folderLines, " "), function(x){x[length(x)]})) # get names of date directories
# dates<- dirs[substr(dirs,1,4)==2003] # pick only data for 2003
# 
# for (date in dates){ 
#   print(date)
#   dir.create(paste(workd, "/", date,"/",sep=""))
# 
# 
#   files<- strsplit(getURL(paste(ftp,date,"/",sep="")),"\n")[1]
#   files<- files[[1]]    
#   hdf.lines<- files[substr(files,(nchar(files)-3),nchar(files))==".hdf"]
#   hdf.files<- unlist(lapply(strsplit(hdf.lines, " "), function(x){x[length(x)]})) 
#   sizes.lines<- unlist(lapply(hdf.lines,function(x){substr(x,1,25)})) 
#   sizes<- unlist(lapply(strsplit(sizes.lines, " "),function(x){x[length(x)]}))
# 
#   hdf.files<- cbind(hdf.files,sizes)
# 
#   downdest<- NULL
#   for (tile in tiles) {
#     #print(tile)
# 
#     tilename<- hdf.files[grep(pattern=tile,hdf.files),1]
#     size<- hdf.files[grep(pattern=tile,hdf.files),2]
#     url<- paste(ftp, date, "/", tilename,sep="")
#     destfile<- paste(workd, "/", date,"/",product,".A.",date,".",tile,".005.hdf",sep="")
#     
#     if (length(tilename)!=0) {
#     downdest<- rbind(downdest,c(url,destfile,size))
#     }
#   } # tiles loop
# 
#   write.table(downdest,paste(workd,"/",date,"/downdest_",product,".txt",sep=""),row.names=FALSE,col.names=FALSE,quote=FALSE)
#   #Sys.sleep(60)
# 
# } # date loop  
# 
# print("done!")

################################################
### Download MODIS EVI (Terra) (MOD09A1.005) ###
################################################

product<- "MOD09A1"
print(product)
workd<- "/input/MODIS/SR" # for the wget command on clutser terminal...
ftp<- "ftp://e4ftl01.cr.usgs.gov/MOLT/MOD09A1.005/" # NASA ftp server

items <- strsplit(getURL(ftp), "\n")[[1]] # get the list of ftp directories

folderLines <- items[substr(items, 1, 1)=='d'] # kick out first line, only drwxr..

dirs <- unlist(lapply(strsplit(folderLines, " "), function(x){x[length(x)]})) # get names of date directories
dates<- dirs[substr(dirs,1,4)==2003] # pick only data for 2003

for (date in dates){ 
  print(date)
  dir.create(paste(workd, "/", date,"/",sep=""))


  files<- strsplit(getURL(paste(ftp,date,"/",sep="")),"\n")[1]
  files<- files[[1]]    
  hdf.lines<- files[substr(files,(nchar(files)-3),nchar(files))==".hdf"]
  hdf.files<- unlist(lapply(strsplit(hdf.lines, " "), function(x){x[length(x)]})) 
  sizes.lines<- unlist(lapply(hdf.lines,function(x){substr(x,1,25)})) 
  sizes<- unlist(lapply(strsplit(sizes.lines, " "),function(x){x[length(x)]}))

  hdf.files<- cbind(hdf.files,sizes)

  downdest<- NULL
  for (tile in tiles) {
    #print(tile)

    tilename<- hdf.files[grep(pattern=tile,hdf.files),1]
    size<- hdf.files[grep(pattern=tile,hdf.files),2]
    url<- paste(ftp, date, "/", tilename,sep="")
    destfile<- paste(workd, "/", date,"/",product,".A.",date,".",tile,".005.hdf",sep="")
    
    if (length(tilename)!=0) {
    downdest<- rbind(downdest,c(url,destfile,size))
    }
  } # tiles loop

  write.table(downdest,paste(workd,"/",date,"/downdest_",product,".txt",sep=""),row.names=FALSE,col.names=FALSE,quote=FALSE)
  #Sys.sleep(60)

} # date loop  

print("done!")

################################################
### Download MODIS EVI (Aqua) (MYD09A1.005) ###
################################################

product<- "MYD09A1"
print(product)
workd<- "/input/MODIS/SR"
ftp<- "ftp://e4ftl01.cr.usgs.gov/MOLA/MYD09A1.005/" # NASA ftp server

items <- strsplit(getURL(ftp), "\n")[[1]] # get the list of ftp directories

folderLines <- items[substr(items, 1, 1)=='d'] # kick out first line, only drwxr..

dirs <- unlist(lapply(strsplit(folderLines, " "), function(x){x[length(x)]})) # get names of date directories
dates<- dirs[substr(dirs,1,4)==2003] # pick only data for 2003

for (date in dates){ 
  print(date)
  dir.create(paste(workd, "/", date,"/",sep=""))


  files<- strsplit(getURL(paste(ftp,date,"/",sep="")),"\n")[1]
  files<- files[[1]]    
  hdf.lines<- files[substr(files,(nchar(files)-3),nchar(files))==".hdf"]
  hdf.files<- unlist(lapply(strsplit(hdf.lines, " "), function(x){x[length(x)]})) 
  sizes.lines<- unlist(lapply(hdf.lines,function(x){substr(x,1,25)})) 
  sizes<- unlist(lapply(strsplit(sizes.lines, " "),function(x){x[length(x)]}))

  hdf.files<- cbind(hdf.files,sizes)

  downdest<- NULL
  for (tile in tiles) {
    #print(tile)

    tilename<- hdf.files[grep(pattern=tile,hdf.files),1]
    size<- hdf.files[grep(pattern=tile,hdf.files),2]
    url<- paste(ftp, date, "/", tilename,sep="")
    destfile<- paste(workd, "/", date,"/",product,".A.",date,".",tile,".005.hdf",sep="")
    
    if (length(tilename)!=0) {
    downdest<- rbind(downdest,c(url,destfile,size))
    }
  } # tiles loop

  write.table(downdest,paste(workd,"/",date,"/downdest_",product,".txt",sep=""),row.names=FALSE,col.names=FALSE,quote=FALSE)
  #Sys.sleep(60)

} # date loop   

print("done!")


################################################
### Download MODIS Landcover (MCD12Q1.005)   ###
################################################

# product<- "MCD12Q1"
# workdown<- "/input/MODIS/landcover"
# ftp<- "ftp://e4ftl01.cr.usgs.gov/MOTA/MCD12Q1.005/" # NASA ftp server
# 
# date<- "2003.01.01"
# 
# dir.create(paste(workd, "/", date,"/",sep=""))
# 
# down<- NULL
# dest<- NULL    
# 
# files<- strsplit(getURL(paste(ftp,date,"/",sep="")),"\n")[1]
# files<- files[[1]]    
# hdf.files<- files[substr(files,(nchar(files)-3),nchar(files))==".hdf"]
# hdf.files<- unlist(lapply(strsplit(hdf.files, " "), function(x){x[length(x)]})) 
# 
# for (tile in tiles) {
#   print(tile)
# 
#   tilename<- hdf.files[grep(pattern=tile,hdf.files)]
#   url<- paste(ftp, date, "/", tilename,sep="")
#   destfile<- paste(workdown, "/", date,"/",product,".A.",date,".",tile,".005.hdf",sep="")
#   #if (file.exists(destfile)==FALSE | file.info(destfile)$size==0){
#     
#     #download files
#     down<- c(down,url)
#     dest<- c(dest,destfile)
#     #download.file(url=url, destfile=destfile, mode='wb', method='wget', quiet=T, cacheOK=FALSE)
# 
#   #}
# 
# } # tiles loop
# 
# write.table(down,paste(workd,"/",date,"/downfiles_",product,".txt",sep=""),row.names=FALSE,col.names=FALSE,quote=FALSE)
# write.table(dest,paste(workd,"/",date,"/destfiles_",product,".txt",sep=""),row.names=FALSE,col.names=FALSE,quote=FALSE)
# 
# print("done!")
