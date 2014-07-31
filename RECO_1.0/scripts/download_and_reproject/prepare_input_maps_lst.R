
library(sp)
library(rgdal)
library(raster)
library(bitops)

### ---------------------------------------------

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
#####################

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

###############################
### generate LST input maps ###
###############################
#quality check, Aqua gap-filling and LST_dif calculation

workd<- "path_to_MODIS_LST_files"
workdest<- "destination_path"
products<- c("MOD11A2","MYD11A2")
tmp<- "define_tmp_path_for_temporary_MPI_outsourcing"

dates<- list.files(workd) # files are listed by dates

if(length(grep("index=",commandArgs(T)))==1) {
	pos <- grep("index=",commandArgs(T))
	index <- as.integer(strsplit(commandArgs(T)[pos],"index=")[[1]][2])
} else {
index<- 1
print("warning: just test run without index loop")
}
print(index)

dates <- dates[index]
date<- dates

#########################################

datefiles<- list.files(paste(workd,"/",date,sep=""))
if (file.exists(paste(workdest,date,sep=""))==FALSE) { 
  dir.create(paste(workdest,date,sep=""))
}

### ---------------------------------------------

tif<- datefiles[grep(datefiles, pattern=paste(products[1],".","*.tif",sep=""))] # select tifs 
tiles<- levels(factor(substr(tif,22,27)))

###
cluter.jobs<- foreach(tile=tiles, .inorder=FALSE, .options.mpi=list(info=TRUE), .verbose=TRUE) %dopar%  { 
###
  if (parallel==TRUE) {
      sinkWorkerOutput(paste("/output_error_file_path/prepare_input_maps_lst_",index,".",tile,"_output.txt",sep=""))
    }

  #if (file.exists(paste(workdest,date,"/LSTday.",date,".",tile,".gapfilled.tif",sep=""))==FALSE | file.exists(paste(workdest,date,"/LSTnight.",date,".",tile,".gapfilled.tif",sep=""))==FALSE | file.exists(paste(workdest,date,"/LSTdif.",date,".",tile,".gapfilled.tif",sep=""))==FALSE | as.integer(substr(file.info(paste(workdest,date,"/LSTday.",date,".",tile,".gapfilled.tif",sep=""))$mtime,9,10))<9 | as.integer(substr(file.info(paste(workdest,date,"/LSTnight.",date,".",tile,".gapfilled.tif",sep=""))$mtime,9,10))<9 | as.integer(substr(file.info(paste(workdest,date,"/LSTdif.",date,".",tile,".gapfilled.tif",sep=""))$mtime,9,10))<9) {
    print(tile)
    return1<- 1
    return2<- 1

    product<- products[1] ### MOD data
    print(product)

    load1<- paste(workd,date,"/",product,".A.",date,".",tile,".005.LST_Day_1km.tif",sep="")
    load2<- paste(workd,date,"/",product,".A.",date,".",tile,".005.LST_Night_1km.tif",sep="")
    load3<- paste(workd,date,"/",product,".A.",date,".",tile,".005.QC_Day.tif",sep="")
    load4<- paste(workd,date,"/",product,".A.",date,".",tile,".005.QC_Night.tif",sep="")

    if (sum(file.exists(load1,load2,load3,load4))==4) {

      LSTd<- readGDAL(load1,silent=TRUE)
      LSTn<- readGDAL(load2,silent=TRUE)
      
      LSTdqc<- readGDAL(load3,silent=TRUE)
      LSTnqc<- readGDAL(load4,silent=TRUE)
      
      dqc<- c(int2bin(LSTdqc$band1)) 
      nqc<- c(int2bin(LSTnqc$band1))
      rm(LSTdqc,LSTnqc)
      
      ### set bad qc to NA
      # 			mandatory QA flag		data quality: only good		LST error: <1K
      LSTd$band1[substr(dqc,7,8)%in%c("10","11") | substr(dqc,5,6)%in%c("01","10","11") | substr(dqc,1,2)!="00"]<- NA # Quality Check LST Day

      LSTd$band1[LSTd$band1== 0] <- NA
      LSTd$band1<- (LSTd$band1*0.02)-273.15
      
      LSTn$band1[substr(nqc,7,8)%in%c("10","11") | substr(nqc,5,6)%in%c("01","10","11") | substr(nqc,1,2)!="00"]<- NA # Quality Check LST Night

      LSTn$band1[LSTn$band1== 0] <- NA
      LSTn$band1<- (LSTn$band1*0.02)-273.15
      rm(dqc,nqc)
      gc()

      ### gliding window means
 
      LSTd.array.mean <- focal(raster(LSTd), w=matrix(1/9,nrow=3,ncol=3),na.rm=TRUE)  # or similarly: focal(LSTd.array,w=3,fun=mean,na.rm=TRUE)
      LSTn.array.mean <- focal(raster(LSTn), w=matrix(1/9,nrow=3,ncol=3),na.rm=TRUE)
    
      LSTd$band1<- LSTd.array.mean[]
      LSTn$band1<- LSTn.array.mean[]
      print("gc after focal:")
      print(gc(verbose=getOption("verbose")))

      rm(LSTd.array.mean,LSTn.array.mean)
      gc()

      return1<- 0
    } # if file exist loop 
    else {
    # missing<- rbind(missing,load1)
    print(paste(load1,"is missing"))

    }

### -------------------------------------------

  product<- products[2] ### MYD data
    print(product)

    load5<- paste(workd,date,"/",product,".A.",date,".",tile,".005.LST_Day_1km.tif",sep="")
    load6<- paste(workd,date,"/",product,".A.",date,".",tile,".005.LST_Night_1km.tif",sep="")
    load7<- paste(workd,date,"/",product,".A.",date,".",tile,".005.QC_Day.tif",sep="")
    load8<- paste(workd,date,"/",product,".A.",date,".",tile,".005.QC_Night.tif",sep="")

    if (sum(file.exists(load5,load6,load7,load8))==4) {

      LSTdmyd<- readGDAL(load5,silent=TRUE)
      LSTnmyd<- readGDAL(load6,silent=TRUE)
      
      LSTdqc<- readGDAL(load7,silent=TRUE)
      LSTnqc<- readGDAL(load8,silent=TRUE)
	      
      dqc<- c(int2bin(LSTdqc$band1)) 
      nqc<- c(int2bin(LSTnqc$band1))
      rm(LSTdqc,LSTnqc)

      
      ### set bad qc to NA
      LSTdmyd$band1[substr(dqc,7,8)%in%c("10","11") | substr(dqc,5,6)%in%c("01","10","11") | substr(dqc,1,2)!="00"]<- NA # Quality Check LST Day
      
      LSTdmyd$band1<- (LSTdmyd$band1*0.02)-273.15
      LSTdmyd$band1[LSTdmyd$band1== -273.15]<- NA
      
      LSTnmyd$band1[substr(nqc,7,8)%in%c("10","11") | substr(nqc,5,6)%in%c("01","10","11") | substr(nqc,1,2)!="00"]<- NA # Quality Check LST Night

      LSTnmyd$band1<- (LSTnmyd$band1*0.02)-273.15
      LSTnmyd$band1[LSTnmyd$band1== -273.15]<- NA
      rm(dqc,nqc)
      gc()
      
      ### gliding window means
      LSTdmyd.array.mean <- focal(raster(LSTdmyd), w=matrix(1/9,nrow=3,ncol=3),na.rm=TRUE)
      LSTnmyd.array.mean <- focal(raster(LSTnmyd), w=matrix(1/9,nrow=3,ncol=3),na.rm=TRUE)

      LSTdmyd$band1<- LSTdmyd.array.mean[]
      LSTnmyd$band1<- LSTnmyd.array.mean[]

      rm(LSTdmyd.array.mean,LSTnmyd.array.mean)
      gc()
      print("gc after MYD processing:")
      print(gc(verbose=getOption("verbose")))

      return2<- 0
      } # if file exist loop 
      else {
      #missing<- rbind(missing,load5)
      print(paste(load5,"is missing"))

    }

### --------------------------------

    if (return1 == 0 & return2 == 0) {

      ### gap-filling
      
      LSTd$band1[is.na(LSTd$band1)]<- LSTdmyd$band1[is.na(LSTd$band1)]
      LSTn$band1[is.na(LSTn$band1)]<- LSTnmyd$band1[is.na(LSTn$band1)]
      writeGDAL(LSTn,paste(tmp,date,"/LSTn",date,".",tile,".tif",sep=""))
      rm(LSTdmyd,LSTnmyd,LSTn)
      gc()

      ### focal
      print("LSTd focal after gap-filling")
      focal(raster(LSTd), w=matrix(1/9,nrow=3,ncol=3),filename= paste(tmp,date,"/LSTd",date,".",tile,".tif",sep=""),na.rm=TRUE,NAonly=TRUE,overwrite=TRUE)
      #LSTd<- as(LSTd,"SpatialGridDataFrame")
      #writeGDAL(LSTd,paste(tmp,date,"/LSTd",date,".",tile,".tif",sep=""))
      rm(LSTd)
      gc()

      print("LSTn focal after gap-filling")
      LSTn<- raster(readGDAL(paste(tmp,date,"/LSTn",date,".",tile,".tif",sep=""),silent=TRUE))
      focal(LSTn, w=matrix(1/9,nrow=3,ncol=3),filename= paste(tmp,date,"/LSTn",date,".",tile,".tif",sep=""),na.rm=TRUE,NAonly=TRUE,overwrite=TRUE)      
      rm(LSTn)
      gc()
       
      ### LST_dif
      print("read from tmp")
      LSTd<- readGDAL(paste(tmp,date,"/LSTd",date,".",tile,".tif",sep=""),silent=TRUE)
      LSTn<- readGDAL(paste(tmp,date,"/LSTn",date,".",tile,".tif",sep=""),silent=TRUE)
      LSTdif<- LSTd
      LSTdif$band1<- LSTd$band1-LSTn$band1
      
      print("write to file")
      writeGDAL(LSTdif,paste(workdest,date,"/LSTdif.",date,".",tile,".gapfilled.tif",sep=""))
      writeGDAL(LSTd,paste(workdest,date,"/LSTday.",date,".",tile,".gapfilled.tif",sep=""))
      writeGDAL(LSTn,paste(workdest,date,"/LSTnight.",date,".",tile,".gapfilled.tif",sep=""))
      rm(LSTd,LSTn,LSTdif)
      gc()
      print("gc after all:")
      print(gc(verbose=getOption("verbose")))

      unlink(paste(tmp,date,"/*",date,".",tile,".tif",sep=""))

      } # if all loads exist
  
    } # if dest file exists
    else {
  print(paste(tile,"already exists"))}

#} # tile loop


if (length(list.files(paste(workdest,date,sep=""),patter="LSTday.*.gapfilled.tif"))==length(tiles)) {
  print("READY! All LST maps produced.")
}

end<- "end of date loop"
end

if (parallel==TRUE) {
  closeCluster(cl)
}
print("Done!!!")