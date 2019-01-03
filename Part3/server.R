# shiny server

source("dataloader.r")
source("indexcalculate.r")


shinyServer(function(input, output, session){
  # plot the map
  output$map1 <- renderLeaflet({
    breaks <- classIntervals(lsoaboundary_rep@data$svi, n=5, style="quantile")$brks
    pal <- colorBin(
      palette = "YlOrBr",
      domain = lsoaboundary_rep@data$svi,
      bins = breaks)
    
    leaflet(lsoaboundary_rep) %>% 
      addPolygons(
        fillColor = ~pal(lsoaboundary_rep@data$svi),
        fillOpacity = 1,
        smoothFactor = 0,
        stroke = F
      ) %>%
      addProviderTiles("Esri.WorldGrayCanvas") %>% 
      addLegend(pal = pal,
                values = ~lsoaboundary_rep@data$svi,
                title = "Social Vulnerability Index",
                position = "bottomleft",
                opacity = 1) %>%
      setView(-0.0881798, 51.48932, zoom = 9)
  })
  # modify the lsoa attribute table
  lsoaboundary_new <- eventReactive(input$getmap,{
    indexcalculator(x1=input$x1,x2=input$x2,x3=input$x3,x4=input$x4,x5=input$x5,x6=input$x6,x7=input$x7,x8=input$x8,x9=input$x9,x10=input$x10,x11=input$x11,x12=input$x12)
  })
  # observer to redraw the map
  observe({

    breaks <- classIntervals(lsoaboundary_new()@data$svi, n=5, style="quantile")$brks
    pal <- colorBin(
      palette = "YlOrBr",
      domain = lsoaboundary_new()@data$svi,
      bins = breaks
    )
    leafletProxy("map1", data = lsoaboundary_new()) %>%
      clearShapes() %>%
      addPolygons(
        fillColor = ~pal(lsoaboundary_new()@data$svi),
        fillOpacity = 1,
        smoothFactor = 0,
        stroke = F
      )


  })
  observe({
    breaks <- classIntervals(lsoaboundary_new()@data$svi, n=5, style="quantile")$brks
    pal <- colorBin(
      palette = "YlOrBr",
      domain = lsoaboundary_new()@data$svi,
      bins = breaks
    )
    proxy <- leafletProxy("map1", data = lsoaboundary_new())
    proxy %>% clearControls() %>%
      addLegend(pal = pal,
                values = ~lsoaboundary_new()@data$svi,
                title = "Social Vulnerability Index",
                position = "bottomleft",
                opacity = 1)
  })
})