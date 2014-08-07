#### plot cotton yields over time in California

library( ggplot2 ) 

# read data
# need to change path to reflect public storage (github?)
yields = read.csv( file="/Users/vickenhillis/Desktop/oss_drought/yield.csv" , stringsAsFactors=FALSE )

# remove commas from Value and make numeric
yields$Value <- as.numeric( gsub( "," , "" , yields$Value ) )

# create subset of data for visualization
# retain only upland cotton measured in lb/acre and major counties with enough data to smooth
# removing pima cotton and irrigated subsets because not enough data to visualize
upland.total = yields[ yields$Data.Item=="COTTON, UPLAND - YIELD, MEASURED IN LB / ACRE" , ]
ut.main.counties = upland.total[ upland.total$County == 
	c("FRESNO" , "KERN" , "KINGS" , "MADERA" , "MERCED" , "TULARE" , "RIVERSIDE" , "IMPERIAL" ) , ]

# plot of all data points, not distinguished, and one smooth line for all counties
# this plot uses all counties, not just major counties
ut.all = ggplot( upland.total , aes( x=Year , y=Value ))
ut.all = ut.all + geom_point( alpha=0.2 ) + geom_smooth()
ut.all + ylab("Yield (lb/acre)" ) + xlab( "Year" )

# spaghetti plot with counties distinguished by color and a smoothed line for each county
ut.main = ggplot( ut.main.counties , aes( x=Year , y=Value , colour=County ))
ut.main = ut.main + geom_point( alpha=0.7 ) + geom_smooth( alpha=0.2 , size=0.2 )
ut.main	+ ylab("Yield (lb/acre)" ) + xlab( "Year" )


# create time series of total state yield for 1993 - 2013

cotton.yield = rep(NA , 21 )
for ( i in 1:21 ){

	cotton.yield[i] = sum( upland.total[ upland.total$Year==(1992+i) , ]$Value )
}

cotton = data.frame( Year = 1993:2013 , Yield=cotton.yield )