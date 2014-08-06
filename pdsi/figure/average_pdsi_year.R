## Temporal plot of scPDSI (average per year)

## NCEAS macroecology drought group OSS2014 
## @ajpelu 
## version 1.0 

# Load packages 
library(ggplot2)
library(plyr)

# Set directory 
di <- '/Users/ajpeluLap/myrepos/Drought_CA'
mydf <- read.table(paste(di,'/pdsi/scpdsi_CAstate.csv',sep=''), header=TRUE) 

# Compute n, mean, sd, se, min, max, median of scpdsi yearly
d <- ddply(mydf, c('year'), summarise,
      N    = sum(!is.na(value)),
      mean = mean(value, na.rm=TRUE),
      sd   = sd(value, na.rm=TRUE),
      se   = sd / sqrt(N),
      min  = min(value, na.rm=TRUE),
      max  = max(value, na.rm=TRUE),
      med  = median(value, na.rm=TRUE))

# Export the table
write.table(d, file=paste(di,'/pdsi/scpdsi_avg_year.csv',sep=''), row=FALSE)


# Plot of mean scPDSI of CA 
p.mean <- ggplot(d, aes(x=year, y=mean)) +
  geom_hline(yintercept=c(-3,-4), colour='red', linetype=c('dashed', 'solid')) +
  geom_hline(yintercept=0, colour='gray') + 
  geom_errorbar(aes(ymax = mean + se, ymin=mean - se)) + 
  geom_line(col='grey') + geom_point(size=3, shape=21, fill="white") + 
  theme_bw() + ylab('scPDSI') 
p.mean 





