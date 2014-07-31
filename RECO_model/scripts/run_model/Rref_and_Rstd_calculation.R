
rm(list=ls(all=TRUE))
gc()

library(sp)
library(rgdal)
library(raster)

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

############################
### function definitions ###
############################

fn1<- function(p,T,evi) {(p[1]/(p[2]+(p[3]^(-(T-10)/10))))+(p[4]*evi)+p[5]}		# standard functions
fn2<- function(p,T) {p[1]/(p[2]+(p[3]^(-(T-10)/10)))}					# LST only (if EVI is NA)
fn3<- function(p,T,evi) {p[1] + (p[2]*T) + (p[3]*evi)} 				# MED winter
fn4<- function(p,Tdif,evi) {p[1] + (p[2]*Tdif) + (p[3]*evi)}				# MED summer
fn5<- function(p,evi) {p[1] + (p[2]*evi)}  						# MED summer, if LSTdif is not available
fn6<- function(p,T) {p[1] + (p[2]*T)}    						# MED winter, if evi is not available

###########################

workd<- paste("enter_path_to_RECO_1.0_here",sep="") # set working directory

# load Re_std parameter table
load(file=paste(workd,"/par/par_table_Restd_full_for_global_app.Rdata",sep=""))
par_restd<- coef_table
rm(coef_table)

# load Re_ref parameter table
load(file=paste(workd,"/par/par_table_Reref_full_for_global_app.Rdata",sep=""))
par_reref<- coef_table
rm(coef_table)

# load dates of MODIS images
dates<- list.files(paste(workd,"/input/MODIS/",sep=""))
dates<- dates[substr(dates,1,4)=="2003"]

# load list of MODIS tiles
datefiles<- list.files(paste(workd,"input/MODIS/",dates[1],sep=""))
tif<- datefiles[grep(datefiles, pattern=paste("LSTday.*.tif",sep=""))] # select tifs 
tiles<- levels(factor(substr(tif,19,24)))

### 8 day loop ############

###
cluter.jobs<- foreach(date=dates, .inorder=FALSE, .options.mpi=list(info=TRUE), .verbose=TRUE) %dopar%  { 
###
  if (parallel==TRUE) {
      sinkWorkerOutput(paste(dir,"/path_to_output_error_file/Rref_and_Rstd_calculation_",date,"_output.txt",sep=""))
    }
  library(raster)

  print("#####################")
  print(paste("### ",date," ###"))
  print("#####################")

  if (file.exists(paste(workd,"Reco/",date,sep=""))==FALSE) { 
    dir.create(paste(workd,"Reco/",date,sep=""))
  }

  ### tile loop ############

  for (tile in tiles) {
  print(tile)
    if (!file.exists(paste(workd,"/input/MODIS/",date,"/LSTday.",date,".",tile,".gapfilled.tif",sep=""))) {
      print(paste("Error: In ",date," ",tile," LST not available!",sep=""))}
    else {
      grid<- raster(paste(workd,"/input/MODIS/",date,"/LSTday.",date,".",tile,".gapfilled.tif",sep=""))
      grid[]<- NA
      # cell centre coordinates
      lat<- coordinates(grid)[,2] 
      lon<- coordinates(grid)[,1]

      # load Geiger-Koeppen climate classification; code: 1 = Temperature limited, 2 = Temperate/Humid, 3 = Mediterranean
      clim<- raster(paste(workd,"/input/koppen-geiger/Koppen_geiger_kottek_aggregated_resample_",tile,".tif",sep=""))
      clim<- clim[]
      clim[is.na(clim)]<- 0
      
      # load MODIS landcover; code: 0: Water, 1: Shrub, Savannas, Grass, 2: Forest, 3: Crop, 4: Barren Land, 5: Snow/Ice, 6: Urban build-up, 254, 255, NA      
      lc<- raster(paste(workd,"/input/landcover/landcover.2003.01.01.",tile,".aggregated.tif",sep=""))

      # crop lc tiles to the reference grid
      if(length(lc)!=length(grid)) lc<- crop(lc,grid)

      # load MODIS data
      load1<- paste(workd,"/input/MODIS/",date,"/LSTnight.",date,".",tile,".gapfilled.tif",sep="")
      load2<- paste(workd,"/input/MODIS/",date,"/LSTdif.",date,".",tile,".gapfilled.tif",sep="")
      load3<- paste(workd,"/input/MODIS/",date,"/EVI.",date,".",tile,".resample.gapfilled.tif",sep="")
      load4<- paste(workd,"/input/MODIS/EVImean_Tref.2003.",tile,".tif",sep="")
      load8<- paste(workd,"/input/MODIS/EVImean.2003.",tile,".tif",sep="")
      load5<- paste(workd,"/input/MODIS/",date,"/NDSI.",date,".",tile,".resample.gapfilled.tif",sep="")
      load6<- paste(workd,"/input/MODIS/LSTnightmean.2003.",tile,".tif",sep="")
      load7<- paste(workd,"/input/MODIS/LSTmean.2003.",tile,".tif",sep="")
      
      LST<- raster(load1)
      LSTdif<- raster(load2)
      EVImean<- raster(load4)
      EVImean2<- raster(load8)
      LST_nmean<- raster(load6)
      LST_dmean<- raster(load7)
      
      if (file.exists(load3) & file.exists(load5)) {

      	EVI<- raster(load3)
      	NDSI<- raster(load5)
      	temponly<- FALSE

      } else {
      	temponly<- TRUE
      }
      
      ############################################################

      lc<- lc[]
      lc[is.na(lc)]<- 0

      LST<- LST[]
      LSTdif<- LSTdif[] + LST_nmean[]
      EVImean<- EVImean[]
      EVImean2<- EVImean2[]
      LSTmean_d<- LST_dmean[]
      #LSTmean_n<- LST_nmean[]
      
      if (temponly==FALSE) {
	#EVI<- EVI[]
	EVImean[is.na(EVImean)]<- EVImean2[is.na(EVImean)]

	NDSI<- NDSI[]
      	snow<- !is.na(NDSI) & NDSI > -0.1
      	EVI[snow]<- NA

      	EVI<- ifelse(EVImean!=0,EVI[]/EVImean,0)
      	EVI[EVI>3.8 & !is.na(EVI)]<- 3.8
      	EVI[EVI<0 & !is.na(EVI)]<- 0
      }

      ### calculate Rref
      Rref<- NULL
      Rref[1:length(grid[])]<- NA

      # TL
      Rref[clim==1]<- par_reref[1,"TL"] + (par_reref[2,"TL"]*EVImean[clim==1]) + (par_reref[3,"TL"]*LSTmean_d[clim==1])
      # TH - FOR
      Rref[clim==2 & lc==2]<- par_reref[1,"TH-FOR"] + (par_reref[2,"TH-FOR"]*EVImean[clim==2 & lc==2]) + (par_reref[3,"TH-FOR"]*LSTmean_d[clim==2 & lc==2])
      # TH - CROGRA
      Rref[clim==2 & lc%in%c(1,3)]<- par_reref[1,"TH-CROGRA"] + (par_reref[2,"TH-CROGRA"]*EVImean[clim==2 & lc%in%c(1,3)]) + (par_reref[3,"TH-CROGRA"]*LSTmean_d[clim==2 & lc%in%c(1,3)])
      # ST
      Rref[clim==3]<- par_reref[1,"ST"] + (par_reref[2,"ST"]*EVImean[clim==3]) + (par_reref[3,"ST"]*LSTmean_d[clim==3])
      
      Rref[Rref<0]<- 0

      ### calculate Rstd
      Rstd<- NULL
      Rstd[1:length(grid[])]<- NA

      if (temponly==FALSE) {

      	# Temp limited & Forest
      	p1t<- par_restd[c(1:3),"TL_FOR_temponly"]
      	Rstd[clim==1 & lc==2 & is.na(EVI)]<- fn2(p1t[!is.na(p1t)],LST[clim==1 & lc==2 & is.na(EVI)])
      	p1te<- par_restd[c(1:5),"TL_FOR_temp+evi"]
      	Rstd[clim==1 & lc==2 & !is.na(EVI)]<- fn1(p1te[!is.na(p1te)],LST[clim==1 & lc==2 & !is.na(EVI)],EVI[clim==1 & lc==2 & !is.na(EVI)])
      
      	# Temp limited & Grass + CRO!!!
      	p2t<- par_restd[c(1:3),"TL_GRA_temponly"]
      	Rstd[clim==1 & lc%in%c(1,3) & is.na(EVI)]<- fn2(p2t[!is.na(p2t)],LST[clim==1 & lc%in%c(1,3) & is.na(EVI)])
      	p2te<- par_restd[c(1:5),"TL_GRA_temp+evi"]
      	Rstd[clim==1 & lc%in%c(1,3) & !is.na(EVI)]<- fn1(p2te[!is.na(p2te)],LST[clim==1 & lc%in%c(1,3) & !is.na(EVI)],EVI[clim==1 & lc%in%c(1,3) & !is.na(EVI)])
      
      	# Temperate/Humid & Forest
      	p3t<- par_restd[c(1:3),"TH_FOR_temponly"]
      	Rstd[clim==2 & lc==2 & is.na(EVI)]<- fn2(p3t[!is.na(p3t)],LST[clim==2 & lc==2 & is.na(EVI)])
      	p3te<- par_restd[c(1:5),"TH_FOR_temp+evi"]
      	Rstd[clim==2 & lc==2 & !is.na(EVI)]<- fn1(p3te[!is.na(p3te)],LST[clim==2 & lc==2 & !is.na(EVI)],EVI[clim==2 & lc==2 & !is.na(EVI)])
      
      	# Temperate/Humid & Cropland + Grass!!!
      	p4t<- par_restd[c(1:3),"TH_CRO_GRA_temponly"]
      	Rstd[clim==2 & lc%in%c(1,3) & is.na(EVI)]<- fn2(p4t[!is.na(p4t)],LST[clim==2 & lc%in%c(1,3) & is.na(EVI)])
      	p4te<- par_restd[c(1:5),"TH_CRO_GRA_temp+evi"]
      	Rstd[clim==2 & lc%in%c(1,3) & !is.na(EVI)]<- fn1(p4te[!is.na(p4te)],LST[clim==2 & lc%in%c(1,3) & !is.na(EVI)],EVI[clim==2 & lc%in%c(1,3) & !is.na(EVI)])
      
      	# Mediterranean & Forest
      	on<- par_restd[1,"ST_FOR_drysummer"]
      	off<- par_restd[2,"ST_FOR_drysummer"]
      	summer<- date %in% dates[on:off]
      	if (!summer) {
      	  p5t<- par_restd[c(1:2),"ST_FOR_winter_temponly"]
      	  Rstd[clim==3 & lc==2 & is.na(EVI)]<- fn6(p5t[!is.na(p5t)],LST[clim==3 & lc==2 & is.na(EVI)])
      	  p5t<- par_restd[c(1:3),"ST_FOR_winter"]
      	  Rstd[clim==3 & lc==2 & !is.na(EVI)]<- fn3(p5t[!is.na(p5t)],LST[clim==3 & lc==2 & !is.na(EVI)],EVI[clim==3 & lc==2 & !is.na(EVI)])
      	} else {
      	  p5t<- par_restd[c(1:3),"ST_FOR_summer_evi_only"]
      	  Rstd[clim==3 & lc==2 & is.na(LSTdif)]<- fn5(p5t[!is.na(p5t)],EVI[clim==3 & lc==2 & is.na(LSTdif)])
      	  p5te<- par_restd[c(1:3),"ST_FOR_summer"]
      	  Rstd[clim==3 & lc==2 & !is.na(LSTdif)]<- fn4(p5te[!is.na(p5te)],LSTdif[clim==3 & lc==2 & !is.na(LSTdif)],EVI[clim==3 & lc==2 & !is.na(LSTdif)])
      	}
      
      	# Mediterranean & not Forest
      	on<- par_restd[1,"ST_CRO_GRA_drysummer"]
      	off<- par_restd[2,"ST_CRO_GRA_drysummer"]
      	summer<- date %in% dates[on:off]
      	if (!summer) {
      	  p5t<- par_restd[c(1:2),"ST_CRO_GRA_winter_temponly"]
      	  Rstd[clim==3 & lc%in%c(1,3) & is.na(EVI)]<- fn6(p5t[!is.na(p5t)],LST[clim==3 & lc%in%c(1,3) & is.na(EVI)])
      	  p5t<- par_restd[c(1:3),"ST_CRO_GRA_winter"]
      	  Rstd[clim==3 & lc%in%c(1,3) & !is.na(EVI)]<- fn3(p5t[!is.na(p5t)],LST[clim==3 & lc%in%c(1,3) & !is.na(EVI)],EVI[clim==3 & lc%in%c(1,3) & !is.na(EVI)])
      	} else {
      	  p5t<- par_restd[c(1:3),"ST_CRO_GRA_summer_evi_only"]
      	  Rstd[clim==3 & lc%in%c(1,3) & is.na(LSTdif)]<- fn5(p5t[!is.na(p5t)],EVI[clim==3 & lc%in%c(1,3) & is.na(LSTdif)])
      	  p5te<- par_restd[c(1:3),"ST_CRO_GRA_summer"]
      	  Rstd[clim==3 & lc%in%c(1,3) & !is.na(LSTdif)]<- fn4(p5te[!is.na(p5te)],LSTdif[clim==3 & lc%in%c(1,3) & !is.na(LSTdif)],EVI[clim==3 & lc%in%c(1,3) & !is.na(LSTdif)])
      	}

      } else { 

          ### temp only model (no EVI input available)
    	  # Temp limited & Forest
    	  p1t<- par_restd[c(1:3),"TL_FOR_temponly"]
    	  Rstd[clim==1 & lc==2]<- fn2(p1t[!is.na(p1t)],LST[clim==1 & lc==2])
    
    	  # Temp limited & Grass + CRO
    	  p2t<- par_restd[c(1:3),"TL_GRA_temponly"]
    	  Rstd[clim==1 & lc%in%c(1,3)]<- fn2(p2t[!is.na(p2t)],LST[clim==1 & lc%in%c(1,3)])
    
    	  # Temperate/Humid & Forest
    	  p3t<- par_restd[c(1:3),"TH_FOR_temponly"]
    	  Rstd[clim==2 & lc==2]<- fn2(p3t[!is.na(p3t)],LST[clim==2 & lc==2])
    
    	  # Temperate/Humid & Cropland
    	  p4t<- par_restd[c(1:3),"TH_CRO_GRA_temponly"]
    	  Rstd[clim==2 & lc%in%c(1,3)]<- fn2(p4t[!is.na(p4t)],LST[clim==2 & lc%in%c(1,3)])
      }

      ### calculate Reco

      Reco<- grid
      Reco[]<- Rref * Rstd
      rm(Rref, Rstd)

      ####################
      Reco[][Reco[]<0] <- 0
      Reco[][lc[]%in%c(4,5)] <- 0

      # replace NA rows
      if (sum(is.na(Reco[2,]))==dim(Reco)[2]) {Reco[2,]<- Reco[3,]} # in case all values in first row are missing, replace first row with second row
      if (sum(is.na(Reco[1,]))==dim(Reco)[2]) {Reco[1,]<- Reco[2,]}
      
      if (sum(is.na(Reco[dim(Reco)[1]-1,]))==dim(Reco)[2]) {Reco[dim(Reco)[1]-1,]<- Reco[dim(Reco)[1]-2,]} # second last {load[1,]<- load[2,]}
      if (sum(is.na(Reco[dim(Reco)[1],]))==dim(Reco)[2]) {Reco[dim(Reco)[1],]<- Reco[dim(Reco)[1]-1,]} # second last {load[1,]<- load[2,]}
      
      # extent tiles by one row to get rid of missing lines in aggregated plot
      Reco<- expand(Reco,c(1,1))
      
      Reco[1,]<-Reco[2,]
      Reco[dim(Reco)[1],]<-Reco[dim(Reco)[1]-1,]
      Reco[,1]<-Reco[,2]
      Reco[,dim(Reco)[2]]<-Reco[,dim(Reco)[2]-1]  
      
      # crop to plot extent and dismiss tiles that are not overlapping
      e<- extent(-150, 45, 20, 80)

      if(!(bbox(Reco)[1,2] < bbox(e)[1,1] | 
	 bbox(Reco)[2,2] < bbox(e)[2,1] | 
	 bbox(Reco)[2,1] > bbox(e)[2,2] | 
	 bbox(Reco)[1,1] > bbox(e)[1,2])) {     

	    Reco<- crop(Reco,e)

	    if(sum(!is.na(Reco[]))>0) {
	      if (!file.exists(paste(workd,"/output/",date,sep=""))) dir.create(paste(workd,"/output/",date,sep=""))    
	      writeGDAL(as(Reco,"SpatialGridDataFrame"),paste(workd,"/output/",date,"/Reco.",date,".",tile,".1km.tif",sep=""),drivername = "GTiff")
	    }
      }

      rm(Reco)

    } # if LST tile exists loop

  } # tile loop

} # date loop

end<- "end of date loop"
end

if (parallel==TRUE) {
  closeCluster(cl)
}

print("Done!!!")

