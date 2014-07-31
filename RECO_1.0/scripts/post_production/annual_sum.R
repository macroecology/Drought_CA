
rm(list=ls(all=TRUE))
gc()

library(sp)
library(rgdal)
library(raster)

countna<- function(x) {sum(is.na(x))}

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

#################################
### calculate monthly average ###
#################################

workd<- "/output/"

dates<- list.files(workd) # files are listed by dates on harddrive
dates<- dates[grep(dates,pattern="2003")]

datefiles<- list.files(paste(workd,"/",dates[2],sep=""))
tiles<- levels(factor(substr(datefiles,17,22)))

#####################################################################

cluter.jobs<- foreach(tile=tiles, .inorder=FALSE, .options.mpi=list(info=TRUE), .verbose=TRUE) %dopar%  { 
###

  if (parallel==TRUE) {
      sinkWorkerOutput(paste(dir,"/path_to_output_error_file/annual_sum_",tile,"_output.txt",sep=""))
    }

  grid<- readGDAL(paste(workd,dates[2],"/Reco.2003.01.09.",tile,".1km.tif",sep=""),silent=TRUE)
  grid$band1[1:length(grid$band1)]<- NA

  sum<- array(0,dim=length(grid$band1))
  count<- array(0,dim=length(grid$band1))

  for (date in dates) {
    print(date)
    if (file.exists(paste(workd,date,"/Reco.",date,".",tile,".1km.tif",sep=""))==TRUE) {
      Reco<- readGDAL(paste(workd,date,"/Reco.",date,".",tile,".1km.tif",sep=""),silent=TRUE)
      if (date=="2003.12.27") {
      	sum<- sum + ifelse(!is.na(Reco$band1),Reco$band1*5,0)
      	count<- count + ifelse(!is.na(Reco$band1),1,0)
      } else { # last period in December is only 5 days long!
      	sum<- sum + ifelse(!is.na(Reco$band1),Reco$band1*8,0)
      	count<- count + ifelse(!is.na(Reco$band1),1,0)
      }
      rm(Reco)
      gc()
    } # if loop
  } # date loop

  # set NA for water, snow, cities...
  sum[count==0]<- NA

  missing.count<- 46 - count

  reco.mean<- ifelse(count>0,sum / count,0)

  sum.fill<- sum + (reco.mean*missing.count)

  Sum.count<- grid
  Sum.count$band1<- count

  Reco.sum<- grid
  Reco.sum$band1<- sum.fill

  writeGDAL(Reco.sum,paste(workd,"annual_sum/Reco_sum.2003.",tile,".tif",sep=""))
  writeGDAL(Sum.count,paste(workd,"annual_sum/Reco_sum.na.count.2003.",tile,".tif",sep=""))

  rm(sum,count,missing.count,reco.mean,sum.fill,Reco.sum,grid,Sum.count)
  gc()
  print(paste("Done with ",tile,"!!!",sep=""))
  
} # tile loop

if (parallel==TRUE) {
  closeCluster(cl)
}

print("Done!!!")
