#Answer the question: Is there any spatial patterns for CASA Treasure Hunt locations or are they randomly distributed?

#load the necessary libraries
library(spatstat)
library(sp)
library(rgeos)
library(maptools)
library(GISTools)
library(tmap)
library(sf)
library(geojsonio)
library(tmaptools)
library(rgdal)
library(ggplot2)
library(raster)
library(fpc)
library(plyr)
library(OpenStreetMap)

#read the data of London wards and treasure hunt locations
TreasHuntPoint <- readOGR("TreasHuntPoints.shp")
LondonWards <- readOGR("LondonData_Joined.shp")
#plot the data
tmap_mode("view")
tm_shape(LondonWards) +
  tm_polygons(col = NA, alpha = 0.5) +
  tm_shape(TreasHuntPoint) +
  tm_dots(col = "blue")

#run a point pattern analysis using ripley's K
window <- as.owin(LondonWards)
plot(window)
TreasHunt.ppp <- ppp(x=TreasHuntPoint@coords[,1],y=TreasHuntPoint@coords[,2],window=window)
K <- Kest(TreasHunt.ppp, correction="border")
plot(K)

#figure out where the clustering occurs using DBSCAN
#first extract the points from the spatial points data frame
TreasPoint <- data.frame(TreasHuntPoint@coords[,1:2])
#now run the dbscan analysis
db <- fpc::dbscan(TreasPoint, eps = 1000, MinPts = 4)
#now plot the results
plot(db, TreasPoint, main = "DBSCAN Output", frame = F)

