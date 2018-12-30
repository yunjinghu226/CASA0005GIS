# This file load necessary data
# 1. cleans the original census data and produces a dataframe of z-scores for each variable involved
# 2. read in the shapefile of lsoa boundaries and clean it

# load library
library(tidyverse)
library(psycho)
library(maptools)
library(rgdal)

# load data
census1 <- read.csv("Part3/Data Download/lsoa-data.csv",stringsAsFactors = FALSE)
census2 <- read.csv("Part3/Data Download/census supplement/Data_supplement.csv",stringsAsFactors = FALSE)
lsoaboundary <- readOGR("Part3/Data Download/statistical-gis-boundaries-london/statistical-gis-boundaries-london/ESRI/LSOA_2011_London_gen_MHW.shp")

# reorganize data: combine needed variables from census data into one dataframe
# first extract needed data from two original census table and make sure the numbers are numeric
census1_needed <- census1[1:4835,c("Lower.Super.Output.Area","X2011.Census.Population.Age.Structure.All.Ages","Country.of.Birth...Not.United.Kingdom.2011","Household.Language...of.households.where.no.people.aged.16.or.over.have.English.as.a.main.language.2011","Tenure.Social.rented.....2011","Tenure.Private.rented.....2011","Adults.in.Employment...of.households.with.no.adults.in.employment..With.dependent.children.2011","Economic.Activity.Unemployment.Rate.2011","Health.Day.to.day.activities.limited.a.lot.....2011","Health.Bad.or.Very.Bad.health.....2011","Car.or.van.availability.No.cars.or.vans.in.household.....2011")]
colnames(census1_needed)[1] <- "GEO_CODE"
census2_needed <- census2[2:4836,c("GEO_CODE","F168","F181","F182","F183","F1915","F1921")]
census2_needed[,2:7] <- as.data.frame(sapply(census2_needed[,2:7], as.numeric))
attach(census1_needed)
attach(census2_needed)
# then combine all vairables into one table and convert several variables from count to percentage
census2_needed$AgeOver75 <- with(census2_needed,F181+F182+F183)
census_comb <- merge(census1_needed,census2_needed,by = "GEO_CODE")
census_comb$PercentUnder5 <- with(census_comb,F168/X2011.Census.Population.Age.Structure.All.Ages*100)
census_comb$PercentOver75 <- with(census_comb,AgeOver75/X2011.Census.Population.Age.Structure.All.Ages*100)
census_comb$PercentNewtoUK <- with(census_comb,F1921/X2011.Census.Population.Age.Structure.All.Ages*100)
# last extract the geo_code column and other necessary variables
census_var <- census_comb[,c(1,3,4,5,6,7,8,9,10,11,19,20,21)]

# calculate z-score
census_z <- standardize(census_var)
# drop unnecessary columns in attribute table of the boundary
lsoaboundary@data <- lsoaboundary@data[,1:2]

# write the new dataframe and save as csv
# write.csv(census_z,file = "Part3/Working Data/variable_zscore.csv")
