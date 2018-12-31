# user interface

library(leaflet)
library(sp)
library(maptools)
library(rgdal)
library(shiny)
library(classInt)
library(RColorBrewer)
library(tmap)
library(tmaptools)

shinyUI(fluidPage(
  # plot the svi map
  leafletOutput("map1", width = "100%", height = "100%"),
  
  # create a float panel with sliders
  sidebarPanel( width = 300,
                #title
                h3("Set Weighting Values for Indicators"),
                #add sliders for each variable
                sliderInput("x1", "Not Born in UK:",
                            min = 0, max = 1,
                            value = 1),
                sliderInput("x2", "English not Main Language:",
                            min = 0, max = 1,
                            value = 1),
                sliderInput("x3", "Social Rented Tenure:",
                            min = 0, max = 1,
                            value = 1),
                sliderInput("x4", "Private Rented Tenure:",
                            min = 0, max = 1,
                            value = 1),
                sliderInput("x5", "Unemployed Adults with Dependent Children:",
                            min = 0, max = 1,
                            value = 1),
                sliderInput("x6", "Unemployment Rate:",
                            min = 0, max = 1,
                            value = 1),
                sliderInput("x7", "Limited Activities:",
                            min = 0, max = 1,
                            value = 1),
                sliderInput("x8", "Bad Health:",
                            min = 0, max = 1,
                            value = 1),
                sliderInput("x9", "No Car/Van:",
                            min = 0, max = 1,
                            value = 1),
                sliderInput("x10", "Young Population:",
                            min = 0, max = 1,
                            value = 1),
                sliderInput("x11", "Elderly Population:",
                            min = 0, max = 1,
                            value = 1),
                sliderInput("x12", "New to UK:",
                            min = 0, max = 1,
                            value = 1)
                )
  
))
