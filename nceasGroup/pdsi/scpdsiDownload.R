## Script to download SCPDSI data from WesWideDroghtTracker
## http://www.wrcc.dri.edu/wwdt/time/
## See .txt files with urls 

## NCEAS macroecology drought group OSS2014 
## @ajpelu 

# Load packages 
library(XML)

# Set directory 
di <- '/Users/ajpeluLap/nceasGroup'
urls <- read.table(paste(di,'/pdsi/urlsSCPDSI_CAstate.txt',sep='')) 

# Create a empty data.frame
all.data <- data.frame()

# Loop to downolad de data 
for (i in 1:nrow(urls)){ 
# Parse url (HTML) to R
myxml <- xmlParse(urls[i,])

# Find node where data is 
d <- getNodeSet(myxml, '//div')

# Get value inside <div> tags 
gv <- sapply(d, xmlValue)

# Split string by ','  
ss <- str_split(gv, ',')

# List to dataframe 
df <- as.data.frame(do.call(rbind, lapply(ss, rbind)))

# Col names 
names(df)[1] <- 'year'
names(df)[2] <- 'value'

# Delete first row
df <- df[-1,]

# Convert to numeric
df[,1] <- as.numeric(levels(df[,1])[df[,1]])
df[,2] <- as.numeric(levels(df[,2])[df[,2]])

# Add month 
df$month <- rep(i, nrow(df))

#  assign(paste("scPDSI","_",i, sep=""),df)

# Append data 
all.data <- rbind(all.data, df)
} 

# Export table  
write.table(all.data,file=paste(di, '/pdsi/scpdsi_CAstate.txt', sep=""), 
            sep="\t", col.names=TRUE)


