# read the London Borough boundary shapefile and census csv file from a local directory
BoroughBd <- readOGR("C:/Users/alexy/Desktop/GIS/wk1/BoundaryDataEdinaCensus/england_lad_2011.shp")
LondonData <- read.csv("C:/Users/alexy/Desktop/GIS/wk1/LondonData.csv")
LondonData <- read_csv("C:/Users/alexy/Desktop/GIS/wk1/LondonData.csv", na = "n/a")

# reorganize the data
LondonData <- data.frame(LondonData)
LondonBoroughs <- LondonData[grep("^E09",LondonData[,3]),] # select rows of London Boroughs
LondonBoroughs <- LondonBoroughs[,c(3,16)] # select needed columns
LondonBoroughs <- LondonBoroughs[2:34,] # get rid of duplicated column
BoroughBd@data <- data.frame(BoroughBd@data,LondonBoroughs[match(BoroughBd@data[,"code"],LondonBoroughs[,"code"]),]) # join the attribute data to the SP data
names(BoroughBd)[3] <- c("Borough Name") # rename the column
names(BoroughBd)[6] <- c("Percentage")
BoroughBd <- BoroughBd[c(3,6)] # extract the two neccessary columns
Borough_repro <-spTransform(BoroughBd, CRS("+proj=longlat +datum=WGS84")) #reproject the data

#plot the Borough data
# add a base map layer in esri grayscale style
labels <- sprintf("<strong>%s</strong><br/>%g percent",Borough_repro$`Borough Name`,Borough_repro$Percentage) %>% lapply(htmltools::HTML)
bins <- c(10.3, 19.9, 31.0, 39.4, 48.2, 55.1)
pal <- colorBin(c("#f7fbff", "#c8ddf0","#73b3d8","#2879b9","#08306b"), domain = Borough_repro$Percentage, bins = bins)
map <- leaflet(Borough_repro)%>%setView(lng = 0, lat = 51.5, zoom = 9)
map%>%addProviderTiles(providers$Esri.WorldGrayCanvas)
map%>%addPolygons(weight = 1,opacity = 1, color = "#fff", smoothFactor = 0.3, fillOpacity = 1,
                  fillColor = ~pal(Percentage),
                  highlight = highlightOptions(
                    weight = 5,
                    color = "#fff",
                    fillOpacity = 1,
                    bringToFront = TRUE),
                  label = labels,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto"))
map%>%addLegend(pal = pal, values = ~Percentage, opacity = 0.7, title = "% people not born in UK",
                position = "bottomright")