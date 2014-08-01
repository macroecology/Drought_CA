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

setwd("C:/Users/visitor/Sara/Drought/ppt")
for (year in 2000:2013){
url<- paste ("ftp://prism.nacse.org/monthly/ppt/", year, "/", sep="")
items <- strsplit(getURL(url, .opts=curlOptions(ftplistonly=TRUE)), "\r\n")[[1]] 
filename<- items [grep(paste (year, "_bil", sep=""), items)]
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

#list all the bil files to open, open, crop and make a stack
name<- list.files ("C:/Users/visitor/Sara/Drought/ppt", pattern="bil.bil")
name<- name [seq(1, length(name), 2)]
ras<- raster (name[1])
mapas<- mask (ras, california)
for (a in name [-1]){
ras<- raster (a)
mapa<- mask (ras, california)
mapas<- stack (mapas, mapa)
}

plot (mapas [[2]], xlim =c(-125, -112), ylim =c(30, 45))

