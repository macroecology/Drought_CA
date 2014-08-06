##Water storage in California reservoirs 

##Paul Selmants
##August 4, 2014

rm(list=ls()) # reset R's brain
library(dplyr)
library(ggplot2)

#load .csv file of CA reservoir water storage data
storage <- read.csv("ca_reservoir.csv", stringsAsFactors = FALSE)

#Calculate %change in storage from historical average and from total capacity
storage.stats <- storage %>% mutate(pct.hist = (storage_june - hist_avg)/hist_avg*100) %>%
    mutate(pct.cap = (storage_june/capacity)*100)

p <- ggplot(storage.stats, aes(year, pct.cap, group = 1)) + 
    geom_line(colour = 'blue', size = 0.8) +
    xlab("Year") +
    ylab("Reservoir storage (% capacity)") +
    theme_bw() + 
    scale_x_continuous(limits = c(1992, 2014),  
    breaks = c(1992, 1994, 1996, 1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2014)) +
    scale_y_continuous(limits = c(40,100)) +
    theme(axis.title.x = element_text(vjust = 0.05))

ggsave('CA_reservoir.png', width = 7, height = 4)
 
