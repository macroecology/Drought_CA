
library(sp)
library(rgdal)
library(raster)
library(bitops)

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

########################################
### generate EVI and NDSI input maps ###
########################################
# quality check, Aqua gap-filling, calculation of EVI and NDSI

workd<- "path_to_MODIS_EVI_files"
workdest<- "destination_path"
tmp<- "path_to_tmp_output"
products<- c("MOD09A1","MYD09A1")

dates<- list.files(workd) # files are listed by dates on harddrive

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
  if (file.exists(paste(tmp,date,sep=""))==FALSE) { 
    dir.create(paste(tmp,date,sep=""))
  }

### ---------------------------------------------

  tif<- datefiles[grep(datefiles, pattern=paste(products[1],".","*.tif",sep=""))] # select tifs 
  tiles<- levels(factor(substr(tif,22,27)))

###
cluter.jobs<- foreach(tile=tiles, .inorder=FALSE, .options.mpi=list(info=TRUE), .verbose=TRUE) %dopar%  { 
###
  if (parallel==TRUE) {
      sinkWorkerOutput(paste("/path_to_output_error_files/prepare_input_maps_evi_",index,".",tile,"_output.txt",sep=""))
    }
  print(paste("### ",date," ###"))

  if (as.integer(substr(file.info(paste(workdest,date,"/EVI.",date,".",tile,".resample.gapfilled.tif",sep=""))$mtime,1,4))==2012) {
    print(paste("### ",tile," is to be processed ###"))

    return1<- 1
    return2<- 1

    product <- products[1] ### MOD data
    print(product)

      load1<- paste(workd,date,"/",product,".A.",date,".",tile,".005.geo.sur_refl_b01.tif",sep="")
      load2<- paste(workd,date,"/",product,".A.",date,".",tile,".005.geo.sur_refl_b02.tif",sep="")
      load3<- paste(workd,date,"/",product,".A.",date,".",tile,".005.geo.sur_refl_b03.tif",sep="")
      load4<- paste(workd,date,"/",product,".A.",date,".",tile,".005.geo.sur_refl_b04.tif",sep="")
      load5<- paste(workd,date,"/",product,".A.",date,".",tile,".005.geo.sur_refl_b06.tif",sep="")
      load6<- paste(workd,date,"/",product,".A.",date,".",tile,".005.geo.sur_refl_qc_500m.tif",sep="")
      load7<- paste(workd,date,"/",product,".A.",date,".",tile,".005.geo.sur_refl_state_500m.tif",sep="")

      if (sum(file.exists(load1,load2,load3,load4,load5,load6,load7))==7) {

	QC<- readGDAL(load6,silent=TRUE)
	QC2<- readGDAL(load7,silent=TRUE)

	qc<- int2bin32(QC$band1) 
	qc2<- int2bin16(QC2$band1)
	rm(QC,QC2)
	gc()

	b1<- readGDAL(load1,silent=TRUE) 
	b1$band1[b1$band1== -28672] <- NA
	# cloud: clear & not set, cloud shadow: no, land flag: land, aerosol: not high, cirrus: not high, internal cloud: no cloud, fire: no fire, snow/ice: no ice, BRDF: yes, snow flag: no 
	# consider readjust the BRDF qc to gain more pixels...
 
	# 			band quality		atm correction		cloud				cloud shadow		land				cirrus			int cloud		fire		adjacent to cloud
	b1$band1[substr(qc,27,30)!=c("0000") | substr(qc,2,2)=="0" | substr(qc2,15,16)%in%c("01","10") | substr(qc2,14,14)=="1" | substr(qc2,11,13)!="001" | substr(qc2,9,10)=="11" | substr(qc2,7,8)=="11" | substr(qc2,6,6)=="1" | substr(qc2,5,5)=="1" | substr(qc2,3,3)=="1"] <- NA # Quality Check	
	b1$band1<- b1$band1*0.0001
	b1.w <- focal(raster(b1), w=matrix(1/9,nrow=3,ncol=3),na.rm=TRUE,pad=TRUE) #,filename=paste(tmp,date,"/b1.",product,".",date,".",tile,".test.tif",sep=""),overwrite=TRUE)
	b1$band1<- b1.w[]
	writeGDAL(b1,paste(tmp,date,"/b1.",product,".",date,".",tile,".tif",sep=""))
	rm(b1,b1.w)
	gc()

	print("gc while focal:")
	print(gc(verbose=getOption("verbose")))


	b2<- readGDAL(load2,silent=TRUE)
	b2$band1[b2$band1== -28672] <- NA
	b2$band1[substr(qc,23,26)!=c("0000") | substr(qc,2,2)=="0" | substr(qc2,15,16)%in%c("01","10") | substr(qc2,14,14)=="1" | substr(qc2,11,13)!="001" | substr(qc2,9,10)=="11" | substr(qc2,7,8)=="11" | substr(qc2,6,6)=="1" | substr(qc2,5,5)=="1" | substr(qc2,3,3)=="1"] <- NA
	b2$band1<- b2$band1*0.0001
	b2.w <- focal(raster(b2), w=matrix(1/9,nrow=3,ncol=3),na.rm=TRUE,pad=TRUE)
	b2$band1<- b2.w[]
	writeGDAL(b2,paste(tmp,date,"/b2.",product,".",date,".",tile,".tif",sep=""))
	rm(b2,b2.w)
	gc()

	b3<- readGDAL(load3,silent=TRUE)
	b3$band1[b3$band1== -28672] <- NA
 	b3$band1[substr(qc,19,22)!=c("0000") | substr(qc,2,2)=="0" | substr(qc2,15,16)%in%c("01","10") | substr(qc2,14,14)=="1" | substr(qc2,11,13)!="001" | substr(qc2,9,10)=="11" | substr(qc2,7,8)=="11" | substr(qc2,6,6)=="1" | substr(qc2,5,5)=="1" | substr(qc2,3,3)=="1"] <- NA
	b3$band1<- b3$band1*0.0001
	b3.w <- focal(raster(b3), w=matrix(1/9,nrow=3,ncol=3),na.rm=TRUE,pad=TRUE)
	b3$band1<- b3.w[]
	writeGDAL(b3,paste(tmp,date,"/b3.",product,".",date,".",tile,".tif",sep=""))
	rm(b3,b3.w)
	gc()

	b4<- readGDAL(load4,silent=TRUE)
 	b4$band1[b4$band1== -28672] <- NA
	b4$band1[substr(qc,15,18)!=c("0000") | substr(qc,2,2)=="0" | substr(qc2,15,16)%in%c("01","10") | substr(qc2,14,14)=="1" | substr(qc2,11,13)!="001" | substr(qc2,9,10)=="11" | substr(qc2,7,8)=="11" | substr(qc2,6,6)=="1" | substr(qc2,5,5)=="1" | substr(qc2,3,3)=="1"] <- NA
	b4$band1<- b4$band1*0.0001
	b4.w <- focal(raster(b4), w=matrix(1/9,nrow=3,ncol=3),na.rm=TRUE,pad=TRUE)
	b4$band1<- b4.w[]
	writeGDAL(b4,paste(tmp,date,"/b4.",product,".",date,".",tile,".tif",sep=""))	
	rm(b4,b4.w)
	gc()

	b6<- readGDAL(load5,silent=TRUE) 	
	b6$band1[b6$band1== -28672] <- NA
	b6$band1[substr(qc,7,10)!=c("0000") | substr(qc,2,2)=="0" | substr(qc2,15,16)%in%c("01","10") | substr(qc2,14,14)=="1" | substr(qc2,11,13)!="001" | substr(qc2,9,10)=="11" | substr(qc2,7,8)=="11" | substr(qc2,6,6)=="1" | substr(qc2,5,5)=="1"  | substr(qc2,3,3)=="1"] <- NA
	b6$band1<- b6$band1*0.0001
	b6.w <- focal(raster(b6), w=matrix(1/9,nrow=3,ncol=3),na.rm=TRUE,pad=TRUE)
	b6$band1<- b6.w[]
	writeGDAL(b6,paste(tmp,date,"/b6.",product,".",date,".",tile,".tif",sep=""))
	rm(b6,b6.w,qc,qc2)

	gc()

	print("gc after focal and write:")
	print(gc(verbose=getOption("verbose")))

	return1<- 0

      } # load exists loop


### ---------------------------------------------

product <- products[2] ### MYD data
    print(product)

      load8<- paste(workd,date,"/",product,".A.",date,".",tile,".005.geo.sur_refl_b01.tif",sep="")
      load9<- paste(workd,date,"/",product,".A.",date,".",tile,".005.geo.sur_refl_b02.tif",sep="")
      load10<- paste(workd,date,"/",product,".A.",date,".",tile,".005.geo.sur_refl_b03.tif",sep="")
      load11<- paste(workd,date,"/",product,".A.",date,".",tile,".005.geo.sur_refl_b04.tif",sep="")
      load12<- paste(workd,date,"/",product,".A.",date,".",tile,".005.geo.sur_refl_b06.tif",sep="")
      load13<- paste(workd,date,"/",product,".A.",date,".",tile,".005.geo.sur_refl_qc_500m.tif",sep="")
      load14<- paste(workd,date,"/",product,".A.",date,".",tile,".005.geo.sur_refl_state_500m.tif",sep="")

      if (sum(file.exists(load8,load9,load10,load11,load12,load13,load14))==7) {

	QC<- readGDAL(load13,silent=TRUE)
	QC2<- readGDAL(load14,silent=TRUE)

	qc<- c(int2bin32(QC$band1)) 
	qc2<- c(int2bin16(QC2$band1))
	rm(QC,QC2)
	gc()

	b1myd<- readGDAL(load8,silent=TRUE)
 	b1myd$band1[b1myd$band1== -28672] <- NA
	b1myd$band1[substr(qc,27,30)!=c("0000") | substr(qc,2,2)==0 | substr(qc2,15,16)%in%c("01","10") | substr(qc2,14,14)=="1" | substr(qc2,11,13)!="001" | substr(qc2,9,10)=="11" | substr(qc2,7,8)=="11" | substr(qc2,6,6)=="1" | substr(qc2,5,5)=="1" | substr(qc2,3,3)=="1"] <- NA # Quality Check
	b1myd$band1<- b1myd$band1*0.0001
	b1.w <- focal(raster(b1myd), w=matrix(1/9,nrow=3,ncol=3),na.rm=TRUE,pad=TRUE)
	b1myd$band1<- b1.w[]
	writeGDAL(b1myd,paste(tmp,date,"/b1.",product,".",date,".",tile,".tif",sep=""))
	rm(b1myd,b1.w)
	gc()

	b2myd<- readGDAL(load9,silent=TRUE) 
	b2myd$band1[b2myd$band1== -28672] <- NA
	b2myd$band1[substr(qc,23,26)!=c("0000") | substr(qc,2,2)==0 | substr(qc2,15,16)%in%c("01","10") | substr(qc2,14,14)=="1" | substr(qc2,11,13)!="001" | substr(qc2,9,10)=="11" | substr(qc2,7,8)=="11" | substr(qc2,6,6)=="1" | substr(qc2,5,5)=="1" | substr(qc2,3,3)=="1"] <- NA
	b2myd$band1<- b2myd$band1*0.0001
	b2.w <- focal(raster(b2myd), w=matrix(1/9,nrow=3,ncol=3),na.rm=TRUE,pad=TRUE)
	b2myd$band1<- b2.w[]
	writeGDAL(b2myd,paste(tmp,date,"/b2.",product,".",date,".",tile,".tif",sep=""))
	rm(b2myd,b2.w)
	gc()

	b3myd<- readGDAL(load10,silent=TRUE) 
	b3myd$band1[b3myd$band1== -28672] <- NA
	b3myd$band1[substr(qc,19,22)!=c("0000") | substr(qc,2,2)==0 | substr(qc2,15,16)%in%c("01","10") | substr(qc2,14,14)=="1" | substr(qc2,11,13)!="001" | substr(qc2,9,10)=="11" | substr(qc2,7,8)=="11" | substr(qc2,6,6)=="1" | substr(qc2,5,5)=="1" | substr(qc2,3,3)=="1"] <- NA
	b3myd$band1<- b3myd$band1*0.0001
	b3.w <- focal(raster(b3myd), w=matrix(1/9,nrow=3,ncol=3),na.rm=TRUE,pad=TRUE)
	b3myd$band1<- b3.w[]
	writeGDAL(b3myd,paste(tmp,date,"/b3.",product,".",date,".",tile,".tif",sep=""))
	rm(b3myd,b3.w)
	gc()

	b4myd<- readGDAL(load11,silent=TRUE) 
	b4myd$band1[b4myd$band1== -28672] <- NA
	b4myd$band1[substr(qc,15,18)!=c("0000") | substr(qc,2,2)==0 | substr(qc2,15,16)%in%c("01","10") | substr(qc2,14,14)=="1" | substr(qc2,11,13)!="001" | substr(qc2,9,10)=="11" | substr(qc2,7,8)=="11" | substr(qc2,6,6)=="1" | substr(qc2,5,5)=="1" | substr(qc2,3,3)=="1"] <- NA
	b4myd$band1<- b4myd$band1*0.0001
	b4.w <- focal(raster(b4myd), w=matrix(1/9,nrow=3,ncol=3),na.rm=TRUE,pad=TRUE)
	b4myd$band1<- b4.w[]
	writeGDAL(b4myd,paste(tmp,date,"/b4.",product,".",date,".",tile,".tif",sep=""))
	rm(b4myd,b4.w)

	b6myd<- readGDAL(load12,silent=TRUE) 
	b6myd$band1[b6myd$band1== -28672] <- NA
	b6myd$band1[substr(qc,7,10)!=c("0000") | substr(qc,2,2)==0 | substr(qc2,15,16)%in%c("01","10") | substr(qc2,14,14)=="1" | substr(qc2,11,13)!="001" | substr(qc2,9,10)=="11" | substr(qc2,7,8)=="11" | substr(qc2,6,6)=="1" | substr(qc2,5,5)=="1" | substr(qc2,3,3)=="1"] <- NA	
	b6myd$band1<- b6myd$band1*0.0001
	b6.w <- focal(raster(b6myd), w=matrix(1/9,nrow=3,ncol=3),na.rm=TRUE,pad=TRUE)
	b6myd$band1<- b6.w[]
	writeGDAL(b6myd,paste(tmp,date,"/b6.",product,".",date,".",tile,".tif",sep=""))
	rm(b6myd,b6.w,qc,qc2)
	gc()

	return2<- 0

      } # if load exists loops

### calculate EVI and NDSI
    print("calc. EVI")

      if (return1==0 & return2==0) {
	product<- products[1]
	b1<- readGDAL(paste(tmp,date,"/b1.",product,".",date,".",tile,".tif",sep=""),silent=TRUE)
	b2<- readGDAL(paste(tmp,date,"/b2.",product,".",date,".",tile,".tif",sep=""),silent=TRUE)
	b3<- readGDAL(paste(tmp,date,"/b3.",product,".",date,".",tile,".tif",sep=""),silent=TRUE)

	evi<- 2.5*((b2$band1-b1$band1)/(b2$band1+(6*b1$band1)-(7.5*b3$band1)+1))
	rm(b2,b3)
	gc()

	b4<- readGDAL(paste(tmp,date,"/b4.",product,".",date,".",tile,".tif",sep=""),silent=TRUE)
	b6<- readGDAL(paste(tmp,date,"/b6.",product,".",date,".",tile,".tif",sep=""),silent=TRUE)

	ndsi <- (b4$band1-b6$band1)/(b4$band1+b6$band1)  
	rm(b4,b6)
	gc()

	product<- products[2]
	b1myd<- readGDAL(paste(tmp,date,"/b1.",product,".",date,".",tile,".tif",sep=""),silent=TRUE)
	b2myd<- readGDAL(paste(tmp,date,"/b2.",product,".",date,".",tile,".tif",sep=""),silent=TRUE)
	b3myd<- readGDAL(paste(tmp,date,"/b3.",product,".",date,".",tile,".tif",sep=""),silent=TRUE)

	evi.myd<- 2.5*((b2myd$band1-b1myd$band1)/(b2myd$band1+(6*b1myd$band1)-(7.5*b3myd$band1)+1))
	rm(b1myd,b2myd,b3myd)
	gc()

	b4myd<- readGDAL(paste(tmp,date,"/b4.",product,".",date,".",tile,".tif",sep=""),silent=TRUE)
	b6myd<- readGDAL(paste(tmp,date,"/b6.",product,".",date,".",tile,".tif",sep=""),silent=TRUE)

	ndsi.myd <- (b4myd$band1-b6myd$band1)/(b4myd$band1+b6myd$band1)  
	rm(b4myd,b6myd)

	EVI<- b1
	EVI$band1 <- evi
	rm(evi)

	EVI.myd<- b1
	EVI.myd$band1 <- evi.myd
	rm(evi.myd)
	
	NDSI<- b1
	NDSI$band1 <- ndsi
	rm(ndsi)

	NDSI.myd<- b1
	NDSI.myd$band1 <- ndsi.myd
	rm(b1,ndsi.myd)

    ### Aggregation

	print("gc before aggregation:")
	print(gc(verbose=getOption("verbose")))

	evi.res<- aggregate(raster(EVI),fact=2,fun=mean,na.rm=TRUE,expand=FALSE)
	rm(EVI)

	evi.myd.res<- aggregate(raster(EVI.myd),fact=2,fun=mean,na.rm=TRUE,expand=FALSE)
	rm(EVI.myd)

	ndsi.res<- aggregate(raster(NDSI),fact=2,fun=mean,na.rm=TRUE,expand=FALSE)
	rm(NDSI)

	ndsi.myd.res<- aggregate(raster(NDSI.myd),fact=2,fun=mean,na.rm=TRUE,expand=FALSE)
	rm(NDSI.myd)
	gc()

	print("gc after aggregation and gc():")
	print(gc(verbose=getOption("verbose")))

    ### moving window means 1km
	
	EVI<- as(evi.res,"SpatialGridDataFrame")
	rm(evi.res)
	EVI.myd<- as(evi.myd.res,"SpatialGridDataFrame")
	rm(evi.myd.res)
	NDSI<- as(ndsi.res,"SpatialGridDataFrame")
	rm(ndsi.res)
	NDSI.myd<- as(ndsi.myd.res,"SpatialGridDataFrame")
	rm(ndsi.myd.res)

    ### trim EVI / NDSI

	EVI$band1[EVI$band1< -0.1 | EVI$band1> 1.1]<- NA
	EVI$band1[EVI$band1< 0 & EVI$band1> -0.1]<- 0
	EVI$band1[EVI$band1< 1.1 & EVI$band1> 1]<- 1

	EVI.myd$band1[EVI.myd$band1< -0.1 | EVI.myd$band1> 1.1]<- NA
	EVI.myd$band1[EVI.myd$band1< 0 & EVI.myd$band1> -0.1]<- 0
	EVI.myd$band1[EVI.myd$band1< 1.1 & EVI.myd$band1> 1]<- 1

	NDSI$band1[NDSI$band1< -0.5 | NDSI$band1> 1]<- NA
	NDSI.myd$band1[NDSI.myd$band1< -0.5 | NDSI.myd$band1> 1]<- NA

    ### gap filling

	EVI$band1[is.na(EVI$band1)]<- EVI.myd$band1[is.na(EVI$band1)]
	NDSI$band1[is.na(NDSI$band1)]<- NDSI.myd$band1[is.na(NDSI$band1)]

    ### shift
    
        if (date=="2003.09.14" & tile=="h19v03") {
	  load<- paste("/input/MODIS/LST/2003.09.06/LSTnight.2003.09.06.h19v03.gapfilled.tif",sep="")
	} else {
	  load<- paste("/input/MODIS/LST/",date,"/LSTnight.",date,".",tile,".gapfilled.tif",sep="")
	}
	LST<- readGDAL(load,silent=TRUE)

	xshift<- summary(LST)$grid[1,1]-summary(EVI)$grid[1,1]
	yshift<- summary(LST)$grid[2,1]-summary(EVI)$grid[2,1]

	print("shifting")
	EVIshift<- shift(raster(EVI),x= xshift,y= yshift)
	NDSIshift<- shift(raster(NDSI),x= xshift,y= yshift)
	EVI<- as(EVIshift,"SpatialGridDataFrame")    
	NDSI<- as(NDSIshift,"SpatialGridDataFrame")    
	rm(EVIshift,NDSIshift)
	gc()

    ### crop/expand

	if ((summary(LST)$grid[1,3]<summary(EVI)$grid[1,3]) | (summary(LST)$grid[2,3]<summary(EVI)$grid[2,3])) {

	  EVIr<- crop(raster(EVI),raster(LST))
	  EVI<- as(EVIr,"SpatialGridDataFrame")
	  NDSIr<- crop(raster(NDSI),raster(LST))
	  NDSI<- as(NDSIr,"SpatialGridDataFrame")

	}

	if ((summary(LST)$grid[1,3]>summary(EVI)$grid[1,3]) | (summary(LST)$grid[2,3]>summary(EVI)$grid[2,3])) {

	  EVIr<- expand(raster(EVI),raster(LST))
	  NDSIr<- expand(raster(NDSI),raster(LST))
	  
	  EVIr[,summary(LST)$grid[1,3]]<- EVIr[,summary(EVI)$grid[1,3]]
	  NDSIr[,summary(LST)$grid[1,3]]<- NDSIr[,summary(EVI)$grid[1,3]]  
	  EVIr[summary(LST)$grid[2,3],]<- EVIr[summary(EVI)$grid[2,3],]
	  NDSIr[summary(LST)$grid[2,3],]<- NDSIr[summary(EVI)$grid[2,3],]
	  
	  EVI<- as(EVIr,"SpatialGridDataFrame")
	  NDSI<- as(NDSIr,"SpatialGridDataFrame")

	}

	print("LST grid")
	print(summary(LST)$grid)
	print("EVI grid")
	print(summary(EVI)$grid)

	if (sum(summary(LST)$grid[,3]==summary(EVI)$grid[,3])!=2) {
	  print("!!! Warning: Grid is not equal !!!")
	}

    ### ---------------------------------------------

	writeGDAL(EVI,paste(workdest,date,"/EVI.",date,".",tile,".resample.gapfilled.tif",sep=""))
	writeGDAL(NDSI,paste(workdest,date,"/NDSI.",date,".",tile,".resample.gapfilled.tif",sep=""))
	unlink(paste(tmp,date,"/*",date,".",tile,".tif",sep=""))

	print("gc at the very end:")
	print(gc(verbose=getOption("verbose")))

	rm(EVI,NDSI,EVI.myd,NDSI.myd,LST,EVIr,NDSIr)
	gc()
	print("### Great!! EVI tile is written to disk ####") 

	} # end if all loads exists
	else {
	print("EVI not calculated due to missing input")
	}
    
    } # if tile does not exist loop
    else {
  print(paste(tile,"already exists"))}
  
  } # end of tile loop

  if (length(list.files(paste(workdest,date,sep=""),patter="EVI.*resample.gapfilled.tif"))==length(tiles)) {
    print("READY! All EVI/NDSI maps produced.")
  }

end<- "end of date loop"
end

if (parallel==TRUE) {
  closeCluster(cl)
}
