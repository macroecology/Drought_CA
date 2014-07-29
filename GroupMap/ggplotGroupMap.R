#####################
#Tim Assal
#7/27/14
#plot NCEAS OSS 2014 Macroecology Drought home locations on a map
#I obtained the lat/long for our home locations from a google web interface
#note, I'm sure an expert would write far better code. 
library(ggplot2)
#create data frame with values
#I obtained lat/long values from a google interface online map
d1 <- data.frame(Name = c("Antonio","Deborah","Leah","Mirela","Paul", "Sara", "Sparkle & Tim","Vicken",
                          " NCEAS"), 
                 long = c (-3.61, -47.05, -122.40, 151.19,-155.09, 14.45, -105.08, -83.93, -119.70),
                 lat = c(37.18, -22.92, 37.8, -33.89, 19.72, 50.08, 40.58, 35.97, 34.42), 
                 Affiliation = c("Univ. of Granada", "Embrapa", "Stanford Univ.", "Sydney", 
                                 "Univ. of Hawaii", "Charles Univ.", "USFS & USGS", "UC Davis",
                                 " NCEAS"))
# Grab a world map
world <- cshp(date = as.Date("2008-1-1"))
world.points <- fortify(world, region = "COWCODE")
# Make a map
ggplot(world.points, aes(long, lat)) + geom_polygon(aes(group = group), 
    fill = "light gray", color = "dark gray", size = 0.1) + geom_point(data = d1, aes(long, lat,
    colour = Name),  size = 3)  +
  theme(legend.position = "bottom") + 
  geom_point(data = d1, aes(long, lat, colour = Name), size = 4) +
   xlab("Longitude") + ylab("Latitude")


# Grab a world map
world <- cshp(date = as.Date("2008-1-1"))
world.points <- fortify(world, region = "COWCODE")
# Main Map
p1<-ggplot(world.points, aes(long, lat)) + geom_polygon(aes(group = group), 
      fill = "light gray", color = "dark gray", size = 0.1) + 
   geom_point(data = d1, aes(long, lat, colour = Name), size = 4) +
  xlab("Longitude") + ylab("Latitude")

#end
################



