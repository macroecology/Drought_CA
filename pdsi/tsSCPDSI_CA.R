## Script to analyze SCPDSI data 

## NCEAS macroecology drought group OSS2014 
## @ajpelu 

# Load packages 
library(ggplot2)
library(Kendall)

# Set directory 
di <- '/Users/ajpeluLap/nceasGroup'
mydf <- read.table(paste(di,'/pdsi/scpdsi_CAstate.txt',sep='')) 

# Panel plot 
ggplot(mydf, aes(x=year, y=value)) + geom_point() 
+ facet_grid(.~month)
p1

MannKendall(june)

june <- mydf[,mydf$june==6]

head(june)

