## Script to analyze SCPDSI data 

## NCEAS macroecology drought group OSS2014 
## @ajpelu @TimAssal 
## version 1.0 

# Load packages 
library(ggplot2)
library(Kendall)
library(plyr)

# Set directory 
di <- '/Users/ajpeluLap/myrepos/Drought_CA'
mydf <- read.table(paste(di,'/pdsi/scpdsi_CAstate.csv',sep=''), header=TRUE) 


# Plot of scPDSI of CA 
# add lines with Palmer Drought classification's
# http://drought.unl.edu/Planning/Monitoring/ComparisonofIndicesIntro/PDSI.aspx
p0 <- ggplot(mydf, aes(x=year, y=value)) + 
  geom_point(stat = 'identity', colour='gray') + 
  geom_hline(yintercept=c(-3,-4), colour='red', linetype=c('dashed', 'solid')) +
  geom_hline(yintercept=0, colour='black') + ylab('scPDSI') +
  theme(legend.position = 'none', panel.grid.major.x = element_blank()) +
  theme_bw() 
# pdf(paste(di,'/pdsi/figure/CA_drougth.pdf', sep=''),height=5, width=8)
p0 + geom_smooth(method="gam", formula=y~s(x), se=FALSE)
dev.off() 

# Panel plot of the scPDSI by months  
# create a variable to colour the bars of the plot 
mydf$sign <- ifelse(mydf[['value']] >= 0, 'positive', 'negative')

p1 <- ggplot(mydf, aes(x=year, y=value, fill=sign)) + 
  geom_bar(stat = 'identity')  + 
  facet_wrap(~month, ncol=4) + 
  scale_fill_manual(values = c('positive' = 'darkblue', 'negative' = 'red')) + 
  geom_hline(aes(yintercept=-3), colour='red', linetype="dashed") + 
  geom_hline(aes(yintercept=-4, colour='red')) +
  theme_bw() + 
  theme(legend.position = 'none', panel.grid.major.x = element_blank()) + 
  ylab('scPDSI')

pdf(paste(di,'/pdsi/figure/panelplotCA_drougth.pdf', sep=''),height=10, width=9)
p1
dev.off() 

##### MannKendall test 
# Create a table with MK statistics and its p-value 
mks <- data.frame()
for (i in 1:12){
sb <- mydf[mydf$month==i,]
mk <- MannKendall(sb$value)
mk$month <- i 
mks <- rbind(mks, mk)}

# Create labels with MannKendall results 
mks$label <- paste(mks$month,' tau=',round(mks$tau, 3), ', ', 'p=', round(mks$sl,4), sep='')

# Join data 
mydf2 <- join(mydf, mks, by='month')

# BN Plot 
p2 <- ggplot(mydf2, aes(x=year, y=value)) +  ylab('scPDSI') +
  geom_bar(stat = 'identity', colour='gray') +  geom_smooth(size=1.5)+ 
  facet_wrap(~month, ncol=4) + 
  geom_hline(aes(yintercept=-3), colour='red', linetype="dashed") + 
  geom_hline(aes(yintercept=-4, colour='red')) +
  theme_bw() +
  theme(legend.position = 'none', panel.grid.major.x = element_blank()) 

p3 <- p2 + geom_text(aes(x=1940, y=4.5, label=label), size=4, family="Times", 
                     face="italic")

ggsave(p3,file=paste(di,'/pdsi/figure/panelPlotCA_month_trends.pdf', sep=''),height=10, width=9)
p3
dev.off() 



################ 
## Plot with plotly 

## Load and install need library
library('devtools')
install_github("ropensci/plotly")

library(plotly)

## Set credentials ()
set_credentials_file(username="ajpelu", api_key="q31kj9i0t9")

py <- plotly()

# Ploty of Drougth. Focused on the last year

p0 <- ggplot(mydf, aes(x=mydf$year, y=mydf$value)) + 
  geom_point(stat = 'identity', colour='gray') +
  

py$ggplotly(p0)

# Get url 
r$response$url





