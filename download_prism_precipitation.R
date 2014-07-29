# Install the packages we need 
install.packages ("adehabitat")
install.packages ("raster")
install.packages ("rgdal")
install.packages ("RCurl")
install.packages ("stringr")
install.packages ("R.utils")

# load the packages we need 
library (adehabitat)
library (raster)
library (rgdal)
library (RCurl)
library (stringr)
library (R.utils)

# set the working directory
setwd ("C:/Users/visitor/Sara/Drought")

# get a list of the files we should download from prism ftp
year<- 2000
url<- paste ("ftp://prism.nacse.org/monthly/ppt/", year, "/", sep="")
items <- strsplit(getURL(url, .opts=curlOptions(ftplistonly=TRUE)), "\r\n")[[1]] 

# to tidy the list. 
# We only need to download the monthy files, 
# not the year file and also not all the files together
files<- items [-c(grep(paste (year, "_bil", sep=""), items), 
                  grep(paste (year, "_all_bil", sep=""), items))]

# to download files
filename <- files [1]

for (filename in files) {
  sourcefile <- paste (url, filename, sep ="")
  download.file(sourcefile, filename)
}

# we need to add the asc extension
# for (filename in files){
#  file.rename (filename, paste (filename, ".asc", sep="")) 
#}

# to open the files, first unzip
getwd()
gunzip("PRISM_ppt_stable_4kmM2_200006_bil.zip", 
       destname= "kk.bil")

# to check that they are ok, plot the bil file
ras<- raster ("PRISM_ppt_stable_4kmM2_200002_bil.bil")
plot (ras)


folder<- "C:/Users/visitor/Sara/Drought/"
for (filename in files){
   (paste (folder, files) 
  
}
