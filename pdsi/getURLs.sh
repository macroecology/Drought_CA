#!/bin/bash 

## Script to create a file containing the url's to access SCPDSI data from WesWideDroghtTracker
## http://www.wrcc.dri.edu/wwdt/time/

## NCEAS macroecology drought group OSS2014 
## @ajpelu 

## Drought CA state
# Create a empty txt file 
touch urlsSCPDSI_CAstate.txt 

## Set parameters 
# California region 
REGION="403466289152"

#Variable: 5=PDSI; 7=scPDSI
VAR="7"

for i in {1..12}
do 
	echo http://www.wrcc.dri.edu/wwdt/time/regionText/?region=$REGION\&variable=$VAR\&start_year=1895\&end_year=2014\&month=$i\&span=1\&run_avg=0 >> urlsSCPDSI_CAstate.txt
done