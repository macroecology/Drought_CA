scPDSI 
========================================================
Temporal Serie of Average of scPDSI 

### Objectives: 
*Plot  the scPDSI aggregate by year (mean)


```r
# Set directory 
di <- '/Users/ajpeluLap/myrepos/Drought_CA'
mydf <- read.table(paste(di,'/pdsi/scpdsi_CAstate.csv',sep=''), header=TRUE) 
```


```r
# Load packages 
library(ggplot2)
library(plyr)
```

#### Temporal variation of scPDSI
A first vision of scPDSI from 1895 to 2014 for CA state aggregate by year (mean $\pm$ se)  


```r
# Compute n, mean, sd, se, min, max, median of scpdsi yearly
d <- ddply(mydf, c('year'), summarise,
      N    = sum(!is.na(value)),
      mean = mean(value, na.rm=TRUE),
      sd   = sd(value, na.rm=TRUE),
      se   = sd / sqrt(N),
      min  = min(value, na.rm=TRUE),
      max  = max(value, na.rm=TRUE),
      med  = median(value, na.rm=TRUE))

# Plot of mean scPDSI of CA 
p.mean <- ggplot(d, aes(x=year, y=mean)) +
  geom_hline(yintercept=c(-3,-4), colour='red', linetype=c('dashed', 'solid')) +
  geom_hline(yintercept=0, colour='gray') + 
  geom_errorbar(aes(ymax = mean + se, ymin=mean - se)) + 
  geom_line(col='grey') + geom_point(size=3, shape=21, fill="white") + 
  theme_bw() + ylab('scPDSI') 
p.mean 
```

![plot of chunk droughtCA](figure/droughtCA.png) 

