##Percent Change in California runoff relative to long-term average

##Paul Selmants
##July 29, 2014

rm(list=ls()) # reset R's brain
library(dplyr)
library(ggplot2)
library(tidyr)

setwd("C:/Users/visitor/Sara/Drought/Drought_CA/")

#load .csv file with CA runoff data from 1903-2014 in mm/d
runoff <- read.csv("water/usgs_ca.csv", stringsAsFactors = FALSE)

#Calculate mean runoff from 1903-2014
mean.ro <- mean(runoff$runoff_mm_d) 

#Calculate % change in runoff from mean, separate date column into year and month columns
ro.tidy <- runoff %>% mutate(pct.change = (runoff_mm_d - mean.ro)/mean.ro*100) %>%
    separate(date, into = c("year", "month"), 4) 

#calculate mean annual percent change in runoff for CA from 1903-2014
ro.annual <- ro.tidy %>% 
    group_by(year) %>% 
    summarise(annual.pctchnge = mean(pct.change)) %>%
    transform(year = as.numeric(year))

p <- ggplot(ro.annual, aes(year, annual.pctchnge, group = 1)) +
    geom_line(colour = 'blue', size = 0.8) +
    xlab("Year") +
    ylab("Change in runoff (%)") +
    theme_bw() + 
    scale_x_continuous(limits = c(1996, 2014), 
    breaks = c(1996, 1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2014))  +
    scale_y_continuous(limits = c(-70, 105), 
    breaks = c(-60, -40, -20, 0, 20, 40, 60, 80, 100)) +
    geom_hline(yintercept = 0, linetype = "dashed", size = 0.2) +
    theme(axis.title.x = element_text(vjust = 0.05))

ggsave('CA_runoff.pdf', width = 7, height = 4)     
    