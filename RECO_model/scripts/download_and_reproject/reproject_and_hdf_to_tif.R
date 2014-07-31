
library(rgdal)
library(raster)

MRT <- "/usr/local/MRT/bin/" # path to MODIS MRT tool
setwd(MRT)

### reproject MODIS HDF files ###

### LST ###################################################################

workd<- "path_to_MODIS_hdfs"
products<- c("MOD11A2","MYD11A2")

dates<- list.files(workd) # files are listed by dates on harddrive

for (date in dates) { # for each date write two .prm files to run MRT (MOD and MYD)
  print(date)

  datefiles<- list.files(paste(workd,"/",date,sep=""))

  for (product in products) { # loop for MOD and MYD resp.
    print(product)

    hdfs<- datefiles[grep(datefiles, pattern=paste(product,".","*.hdf",sep=""))]

      for (hdf in hdfs) {
	print(hdf)
	prmpath<- paste(workd,date,"/",strsplit(hdf,"hdf")[1], "prm", sep="")

	filename<- file(description=prmpath, open="wt")

	write(paste("INPUT_FILENAME = ", workd,date,"/",hdf, sep=""), filename) # see MRT manual to adjust parameter file further
	write("  ", filename, append=TRUE) 
	write("SPECTRAL_SUBSET = ( 1 1 0 0 1 1 0 0 0 0 0 )", filename, append=TRUE)
	write("  ", filename, append=TRUE)
	write(paste("OUTPUT_FILENAME = ", workd,date,"/",strsplit(hdf,"hdf")[[1]],"tif", sep=""), filename, append=TRUE)
	write("  ", filename, append=TRUE)
	write("RESAMPLING_TYPE = NEAREST_NEIGHBOR", filename, append=TRUE)
	write("  ", filename, append=TRUE)
	write("OUTPUT_PROJECTION_TYPE = GEO", filename, append=TRUE)
	write("  ", filename, append=TRUE)
	write("OUTPUT_PROJECTION_PARAMETERS = ( ", filename, append=TRUE)
	write(" 0.0 0.0 0.0", filename, append=TRUE)
	write(" 0.0 0.0 0.0", filename, append=TRUE)
	write(" 0.0 0.0 0.0", filename, append=TRUE)
	write(" 0.0 0.0 0.0", filename, append=TRUE)
	write(" 0.0 0.0 0.0 )", filename, append=TRUE)
	write("  ", filename, append=TRUE)
	write("DATUM = WGS84", filename, append=TRUE)
	close(filename)

	system(command=paste("resample -p ",prmpath,sep="")) # access to terminal

	} #hdf loop
    } # product loop
} # date loop


### Surface Reflection ###########################################################

workd<- "path..."
products<- c("MOD09A1","MYD09A1")

dates<- list.files(workd) # files are listed by dates on harddrive

for (date in dates) { # for each date write two .prm files to run MRT (MOD and MYD)
  print(date)

  datefiles<- list.files(paste(workd,"/",date,sep=""))

  for (product in products) { # loop for MOD and MYD resp.
    print(product)

    hdfs<- datefiles[grep(datefiles, pattern=paste(product,".","*.hdf",sep=""))]

      for (hdf in hdfs) {
	print(hdf)
    
 	prmpath<- paste(workd,date,"/",strsplit(hdf,"hdf")[1], "prm", sep="")

	filename<- file(description=prmpath, open="wt")

	write(paste("INPUT_FILENAME = ", workd,date,"/",hdf, sep=""), filename) 
	write("  ", filename, append=TRUE) 
	write("SPECTRAL_SUBSET = ( 1 1 1 1 1 1 1 1 0 0 0 1 0 )", filename, append=TRUE)
	write("  ", filename, append=TRUE)
	write(paste("OUTPUT_FILENAME = ", workd,date,"/",strsplit(hdf,"hdf")[[1]],"geo.tif", sep=""), filename, append=TRUE)
	write("  ", filename, append=TRUE)
	write("RESAMPLING_TYPE = NEAREST_NEIGHBOR", filename, append=TRUE)
	write("  ", filename, append=TRUE)
	write("OUTPUT_PROJECTION_TYPE = GEO", filename, append=TRUE)
	write("  ", filename, append=TRUE)
	write("OUTPUT_PROJECTION_PARAMETERS = ( ", filename, append=TRUE)
	write(" 0.0 0.0 0.0", filename, append=TRUE)
	write(" 0.0 0.0 0.0", filename, append=TRUE)
	write(" 0.0 0.0 0.0", filename, append=TRUE)
	write(" 0.0 0.0 0.0", filename, append=TRUE)
	write(" 0.0 0.0 0.0 )", filename, append=TRUE)
	write("  ", filename, append=TRUE)
	write("DATUM = WGS84", filename, append=TRUE)
	write('  ', filename, append=TRUE)
	write('OUTPUT_PIXEL_SIZE = 1000', filename, append=TRUE)
	write('  ', filename, append=TRUE)
	close(filename)
	
	system(command=paste("resample -p ",prmpath,sep=""))

      } # hdf loop
    } # product loop

  } # date loop


### Land Cover ###########################################################

workd<- "path..."
product<- c("MCD12Q1")

date<- "2003.01.01" # enter date

datefiles<- list.files(paste(workd,"/",date,sep=""))

hdfs<- datefiles[grep(datefiles, pattern=paste(product,".","*.hdf",sep=""))]

for (hdf in hdfs) {
  print(hdf)
  prmpath<- paste(workd,date,"/",strsplit(hdf,"hdf")[1], "prm", sep="")

  filename<- file(description=prmpath, open="wt")

  write(paste("INPUT_FILENAME = ", workd,date,"/",hdf, sep=""), filename) 
  write("  ", filename, append=TRUE) 
  write("SPECTRAL_SUBSET = ( 1 0 0 0 0 1 0 0 0 0 1 1 1 0 0 0 )", filename, append=TRUE)
  write("  ", filename, append=TRUE)
  write(paste("OUTPUT_FILENAME = ", workd,date,"/",strsplit(hdf,"hdf")[[1]],"tif", sep=""), filename, append=TRUE)
  write("  ", filename, append=TRUE)
  write("RESAMPLING_TYPE = NEAREST_NEIGHBOR", filename, append=TRUE)
  write("  ", filename, append=TRUE)
  write("OUTPUT_PROJECTION_TYPE = GEO", filename, append=TRUE)
  write("  ", filename, append=TRUE)
  write("OUTPUT_PROJECTION_PARAMETERS = ( ", filename, append=TRUE)
  write(" 0.0 0.0 0.0", filename, append=TRUE)
  write(" 0.0 0.0 0.0", filename, append=TRUE)
  write(" 0.0 0.0 0.0", filename, append=TRUE)
  write(" 0.0 0.0 0.0", filename, append=TRUE)
  write(" 0.0 0.0 0.0 )", filename, append=TRUE)
  write("  ", filename, append=TRUE)
  write("DATUM = WGS84", filename, append=TRUE)
  close(filename)

  system(command=paste("resample -p ",prmpath,sep=""))

} #hdf loop