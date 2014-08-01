# Install the packages we need 
install.packages ("raster")
install.packages ("rgdal")
install.packages ("RCurl")
install.packages ("stringr")
install.packages ("rgeos")

# load the packages we need 
library (raster)
library (rgdal)
library (RCurl)
library (stringr)
library (maptools)



# set the working directory
# get a list of the files we should download from prism ftp

for (year in 2000:2013){
setwd("C:/Users/visitor/Sara/Drought/ppt")
url<- paste ("ftp://prism.nacse.org/monthly/ppt/", year, "/", sep="")
items <- strsplit(getURL(url, .opts=curlOptions(ftplistonly=TRUE)), "\r\n")[[1]] 
# to tidy the list. 
# We only need to download the monthy files, 
# not the year file and also not all the files together
filename<- items [grep(paste (year, "_bil", sep=""), items)]

# files<- items [-c(grep(paste (year, "_bil", sep=""), items), 
#                 grep(paste (year, "_all_bil", sep=""), items))]

# to download files
# there is a bug in RStudio, if the downloaded files are corrupt, 
# then you should go to 
# Tools > Global Options > Packages, and unselect 
# "Use Internet Explorer library/proxy for HTTP"
# to open the files, first unzip

sourcefile <- paste (url, filename, sep ="")
download.file(sourcefile, filename, method = "auto")
unzip (filename)  
}

# mask the usa maps with california to obtain a map of california

cali<- readShapeSpatial ("C:/Users/visitor/Sara/Drought/USA_adm1.shp")
class (cali)
names (cali)
head (cali)
california<- cali [cali$NAME_1 == "California", ]
plot (california)
name<- paste (substr (filename, 1, nchar(filename)-4), ".bil", sep="")
ras<- raster (name)
plot (ras)


mapa<- mask (ras, california)
plot (mapa, xlim =c(-125, -112), ylim =c(30, 45), main=filename)

str (mapa)
