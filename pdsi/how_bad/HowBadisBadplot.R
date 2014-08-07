## Script to see How bad is bad 

## NCEAS macroecology drought group OSS2014 
## @ajpelu @TimAssal @SparkleLM85
## version 1.0 

# Load packages 
library(ggplot2)
library(plyr)

# Set directory 
di <- '/Users/ajpeluLap/myrepos/Drought_CA'
mydf <- read.table(paste(di,'/pdsi/scpdsi_CAstate.csv',sep=''), header=TRUE) 

# subset the data 
negvalue <- mydf[mydf$value<0,]

# Histogram of the negative values 
m <- ggplot(negvalue, aes(value)) + geom_histogram(stat='bin', binwidth=0.1, fill='grey') + 
  xlab('scPDSI') + ylab('frequency') + theme_bw() + geom_vline(x=-4)

# How many months are there in the temporal serie? 
nrow(mydf) 
# 1440 

# Get all months scPDSI < -3 ('severe') 
severe <- negvalue[which(negvalue[,'value']>-4 & negvalue[,'value']<=-3 ),]
severe <- severe[order(severe$year),]

# and scPDSI < -4 ('extreme')
extreme <- negvalue[which(negvalue[,'value']<=-4),]

# data for the plot 
sevExt <- negvalue[which(negvalue[,'value']<=-3),]

# how bad is bad plot
ggplot(sevExt, aes(x=year, y=value)) + geom_point() + ylim(-5,0)
