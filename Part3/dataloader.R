# This file load necessary data
# 1. cleans the original census data and produces a dataframe of z-scores for each variable involved, then calculate the svi by adding all zscores, calculate a localG
# 2. read in the shapefile of lsoa boundaries and clean it

# load library
library(tidyverse)
library(psycho)
library(maptools)
library(rgdal)

# load data
wd <- getwd()
census1 <- read.csv(paste(wd,"/Data Download/lsoa-data.csv",sep = ""),stringsAsFactors = FALSE)
census2 <- read.csv(paste(wd,"/Data Download/census supplement/Data_supplement.csv",sep = ""),stringsAsFactors = FALSE)
lsoaboundary <- readOGR(paste(wd,"/Data Download/statistical-gis-boundaries-london/statistical-gis-boundaries-london/ESRI",sep = ""),"LSOA_2011_London_gen_MHW")
borough <- readOGR(paste(wd,"/Data Download/Londonborough",sep = ""),"england_lad_2011")

# reorganize data: combine needed variables from census data into one dataframe
# first extract needed data from two original census table and make sure the numbers are numeric
census1_needed <- census1[1:4835,c("Lower.Super.Output.Area","X2011.Census.Population.Age.Structure.All.Ages","Country.of.Birth...Not.United.Kingdom.2011","Household.Language...of.households.where.no.people.aged.16.or.over.have.English.as.a.main.language.2011","Tenure.Social.rented.....2011","Tenure.Private.rented.....2011","Adults.in.Employment...of.households.with.no.adults.in.employment..With.dependent.children.2011","Economic.Activity.Unemployment.Rate.2011","Health.Day.to.day.activities.limited.a.lot.....2011","Health.Bad.or.Very.Bad.health.....2011","Car.or.van.availability.No.cars.or.vans.in.household.....2011")]
colnames(census1_needed)[1] <- "GEO_CODE"
census2_needed <- census2[2:4836,c("GEO_CODE","F168","F181","F182","F183","F1915","F1921")]
census2_needed[,2:7] <- as.data.frame(sapply(census2_needed[,2:7], as.numeric))

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
census_z$svi <- with(census_z,census_z[,2]+census_z[,3]+census_z[,4]+census_z[,5]+census_z[,6]+census_z[,7]+census_z[,8]+census_z[,9]+census_z[,10]+census_z[,11]+census_z[,12]+census_z[,13])
# drop unnecessary columns in attribute table of the boundary and reproject the data
lsoaboundary@data <- lsoaboundary@data[,1:2]
lsoaboundary@data <- data.frame(lsoaboundary@data,census_z[match(lsoaboundary@data[,"LSOA11CD"],census_z[,"GEO_CODE"]),])
lsoaboundary_rep <- spTransform(lsoaboundary, CRS("+init=epsg:4326"))
borough_rep <- spTransform(borough,CRS("+init=epsg:4326"))

# perform moran's I test and add a column to the lsoa dataframe
# create spatial weights
coordsW <- coordinates(lsoaboundary_rep)
lsoa_nb <- poly2nb(lsoaboundary_rep, queen=T)
lsoa.lw <- nb2listw(lsoa_nb, style="C")
# calculate Getis Ord General G
lsoaboundary_rep@data$G_svi <- localG(lsoaboundary_rep@data$svi, lsoa.lw)

