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
for (year in 1981:2013){
url<- paste ("ftp://prism.nacse.org/monthly/ppt/", year, "/", sep="")
items <- strsplit(getURL(url, .opts=curlOptions(ftplistonly=TRUE)), "\r\n")[[1]] 
filename<- items [grep(paste (year, "_bil", sep=""), items)]
sourcefile <- paste (url, filename, sep ="")
download.file(sourcefile, filename, method = "auto")
unzip (filename)  
}

# mask the usa maps with california to obtain a map of california
cali<- readShapeSpatial ("C:/Users/visitor/Sara/Drought/USA_adm1.shp")
california<- cali [cali$NAME_1 == "California", ]

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

dim (mapas)
plot (mapas [[2]], xlim =c(-125, -112), ylim =c(30, 45))
mean_precip<- mean (mapas)
plot (mean_precip, xlim =c(-125, -112), ylim =c(30, 45))
media<- mean (mean_precip@data@values, na.rm=TRUE)
dim (mapas)

diff<- NULL
for (i in 1:dim (mapas)[3]){
  mapa2<- mapas [[i]]
  media1<- mean (getValues (mapa2), na.rm=TRUE)
  dif <- c(media1 - media )
  diff<- c(diff, dif)
}

media
years<- c(1981:2013)
write.table (data.frame (years, diff), 
             "precip_diff.csv", sep=",", row.names=F)
perc<- (diff*100)/media
dev.off()

plot (perc, type="l", axes= F, xlim= c(0, 33), 
      col="blue", lty=2, 
      ylab= "% Change in precipitation", xlab="Years")
abline (h=0, col="grey")
axis(1, labels=c(1981:2013), at=c(1:33), las=2)
axis (2)

data<- data.frame (years, percentage_precipitation=perc)
qplot(years, percentage_precipitation, data = data) +
  geom_line()


library (ggplot2)
data<- data.frame (Years= c(1981:2013), Diff_precip=diff)
names (data)
qplot(Years, Diff_precip, data=data, 
      geom=c("point", "smooth"),
      method="lm", formula=y~x,
      main="PRISM precipitation",
      xlab="Years", ylab="Anomalies in precipitation (mm)")


plot (mapas, xlim =c(-125, -112), 
      ylim =c(30, 45), zlim= c(0, 5000), 
      axes=F, box=F, main="")


##### MannKendall test
install.packages ("Kendall")
library(ggplot2)
library(Kendall)
library(plyr)
library(mgcv)


coord<- xyFromCell (mapas [[1]], 1:ncell(mapas [[1]]))
res<- coord
for (i in 1:dim (mapas)[3]){
  mapa2<- mapas [[i]]
  datos<- getValues (mapa2)
  res<- cbind (res, datos)
}

res2<- res [-c(which (is.na (res[,3]))),]
names (res2)<-c(1981:2013) 
dim (res2)

trends<- NULL
for (i in 1:nrow (res2)){
  mk <- MannKendall(res2 [i,-c(1:2)])
  resul<- c(tau= round (mk$tau [1], 3), p= round (mk$sl [1], 4))
  trends<- rbind(trends, resul)
}

colnames (trends)<- c("tau", "p")
trends_maps<- cbind (res2[,c(1:2)], trends)
head (trends_maps)

tau<- rasterFromXYZ (trends_maps[,c(1:3)])

p<- rasterFromXYZ (trends_maps[,c(-3)])

colores<- colorRampPalette(c( "red", "blue"))
plot (tau, col=colores(100), axes=F, box=F)
plot (p)


