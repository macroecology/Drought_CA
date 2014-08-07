# Load packages 
library(RCurl)
library(raster)
library(rgdal)
library(maptools)
library(rasterVis)


# Set the directory 
di <- '/Users/ajpeluLap/myrepos/pdsiSpatial/'
setwd(di)

#### run only a time!!!!! ########
## Raster data about scPDSI 
## http://www.wrcc.dri.edu/wwdt/archive.php?folder=scpdsi
## Loop to download the raster data 
# 
# for (y in 1896:2014) { 
# # Get the url
#   url.aux <- paste('http://www.wrcc.dri.edu/monitor/WWDT/data/PRISM/scpdsi/scpdsi_',y,'_', sep='')
#   for (m in 1:12){
#   url <- paste(url.aux,m,'_PRISM.nc', sep='') 
#   filenamedest <- strsplit(url, split='http://www.wrcc.dri.edu/monitor/WWDT/data/PRISM/scpdsi/')[[1]][2]
#   download.file(url, filenamedest)
# }}
# 
# 






# List the files within the directory 
setwd(paste(di,'/test',sep=''))
pdsi<- list.files()

# Create a raster from first month of pdsi and apply a mask of california
r <- raster(pdsi[1])
mapas<- mask(r, ca)

# loop to create a stak of raster (with mask of california) from all the serie
 for (a in pdsi[-1]){
  r <- raster(a)
  mapa<- mask(r, ca)
  mapas<- stack(mapas, mapa)
}


writeRaster(mapas, file="mapas.nc")

cloudTheme <- rasterTheme(region=brewer.pal(n=12, 'red','Blues'))
tmp <- tempdir()
trellis.device(png, file=paste0(di, '/png/Rplot%02d.png'),
               res=300, width=1500, height=1500)
levelplot(mapas, layout=c(1, 1), par.settings=cloudTheme) 
# +layer(sp.lines(boundaries, lwd=0.6))
dev.off()

# set parameters
boundaries <- ca
mk <- mask(r, ca)
levelplot(mk)

+ layer(sp.lines())







alt.USA <- getData('alt', country='USA', path='./shapefile')
alt.USA <- alt.USA[[1]]
slope.USA <- terrain(alt.USA, opt='slope')
aspect.USA <- terrain(alt.USA, opt='aspect')
hill.USA <- hillShade(slope.USA, aspect.USA, angle=45, direction=315)


levelplot(r)

hsTheme <- modifyList(GrTheme(), list(regions=list(alpha=0.5)))

levelplot(mk, panel=panel.levelplot.raster,
          margin=TRUE, colorkey=FALSE) + layer(sp.lines(boundaries, lwd=0.5))

projLL <- CRS('+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0')
cftLL <- projectExtent(mk, projLL)
ext <- c(-125,30,-112,45)
boundaries <- map('worldHires',
                  xlim=ext[c(1,3)], ylim=ext[c(2,4)],
                  plot=FALSE)
boundaries <- map2SpatialLines(boundaries, proj4string=projLL)
boundaries <- spTransform(boundaries, CRS(projLCC2d))


################# 
## set projection
projLCC2d <- "+proj=longlat +lon_0=-125 +lat_0=30 +lat_1=45 +datum=WGS84 +ellps=WGS84"
projection(mk) <- projLCC2d 






ext <- c(-125,30,-112,45)

boundaries <- map('worldHires',
                  xlim=cftExt[c(1,3)], ylim=cftExt[c(2,4)],
                  plot=FALSE)
boundaries <- map2SpatialLines(boundaries, proj4string=projLL)
boundaries <- spTransform(boundaries, CRS(projLCC2d))




##################################################################
## Animation
##################################################################

##################################################################
## Data
##################################################################

cft <- brick('data/cft_20130417_0000.nc')
## use memory instead of file
cft[] <- getValues(cft)
## set projection
projLCC2d <- "+proj=lcc +lon_0=-14.1 +lat_0=34.823 +lat_1=43 +lat_2=43 +x_0=536402.3 +y_0=-18558.61 +units=km +ellps=WGS84"
projection(cft) <- projLCC2d
#set time index
timeIndex <- seq(as.POSIXct('2013-04-17 01:00:00', tz='UTC'), length=96, by='hour')
cft <- setZ(cft, timeIndex)
names(cft) <- format(timeIndex, 'D%d_H%H')

##################################################################
## Spatial context: administrative boundaries
##################################################################

library(maptools)
library(rgdal)
library(maps)
library(mapdata)

levelplot(mk, xlim=c(-125,-112), ylim=c(30,45))
ext <- c(-125,30,-112,45)


### ESTO FUNCIONA #### 
# set my projection 
mip <- projection('m0.3')
projection(mk) <- mk 
levelplot(mk, xlim=c(-125,-112), ylim=c(30,45))


projLL <- CRS('+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0')
cftLL <- projectExtent(cft, projLL)
cftExt <- as.vector(bbox(cftLL))
boundaries <- map('worldHires',
                  xlim=cftExt[c(1,3)], ylim=cftExt[c(2,4)],
                  plot=FALSE)
boundaries <- map2SpatialLines(boundaries, proj4string=projLL)
boundaries <- spTransform(boundaries, CRS(projLCC2d))

##################################################################
## Producing frames and movie
##################################################################

cloudTheme <- rasterTheme(region=brewer.pal(n=9, 'Blues'))

tmp <- tempdir()
trellis.device(png, file=paste0(tmp, '/Rplot%02d.png'),
               res=300, width=1500, height=1500)
levelplot(mk, par.settings=cloudTheme, 
          
          
          
          ## xlim and ylim to display a smaller region
          levelplot(mk, xlim=c(179000, 181000), ylim=c(329500, 334000))
          
          
  layer(sp.lines(boundaries, lwd=0.6))
dev.off()

old <- setwd(tmp)
## Create a movie with ffmpeg using 6 frames per second a bitrate of 300kbs
movieCMD <- 'ffmpeg -r 6 -b 300k -i Rplot%02d.png output.mp4'
system(movieCMD)
file.remove(dir(pattern='Rplot'))
file.copy('output.mp4', paste0(old, 'cft.mp4'), overwrite=TRUE)
setwd(old)



##################################################################
## Static image
##################################################################

pdf(file="cft.pdf")
levelplot(r, layers=25:48, layout=c(6, 4),
          par.settings=cloudTheme,
          names.attr=paste0(sprintf('%02d', 1:24), 'h'),
          panel=panel.levelplot.raster) +
  layer(sp.lines(boundaries, lwd=0.6))
dev.off()








mapita <- mask(r, ca)
plot(mapita, xlim =c(-125, -112), ylim =c(30, 45))

ogrInfo(dsn='/shapefile/USA_adm1.shp', layer='USA_admn1')

P4S.latlon <- CRS("+proj=longlat +datum=WGS84")
hrr.shp <- readShapePoly("HRR_Bdry", verbose=TRUE, proj4string=P4S.latlon)
plot(hrr.shp)


mapita <- mas

ras<- raster (a)
mapa<- mask (ras, california)
mapas<- stack (mapas, mapa)
















#list all the bil files to open, open, crop and make a stack
# name<- list.files ("C:/Users/visitor/Sara/Drought/ppt", pattern="bil.bil")
name<- name [seq(1, length(name), 2)]
ras<- raster (name[1])
mapas<- mask (ras, california)
for (a in name [-1]){
  ras<- raster (a)
  mapa<- mask (ras, california)
  mapas<- stack (mapas, mapa)
}





      col = heat.colors(length(seq(-6, 6, by = 1))))
)



