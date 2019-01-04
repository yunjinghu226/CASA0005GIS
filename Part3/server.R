# shiny server

source("dataloader.r")
source("modifier.r")


shinyServer(function(input, output, session){
  # plot the svi map with borough boundaries
  output$map1 <- renderLeaflet({
    breaks <- classIntervals(lsoaboundary_rep@data$svi, n=5, style="quantile")$brks
    pal <- colorBin(
      palette = "YlOrBr",
      domain = lsoaboundary_rep@data$svi,
      bins = breaks)
    labels_lsoa <- sprintf(
      "%s",
      lsoaboundary_rep@data$LSOA11NM
    ) %>% lapply(htmltools::HTML)
    labels_br <- sprintf(
      "%s",
      borough_rep@data$name
    ) %>% lapply(htmltools::HTML)
  
    leaflet(lsoaboundary_rep) %>% 
      addPolygons(
        fillColor = ~pal(lsoaboundary_rep@data$svi),
        fillOpacity = 1,
        smoothFactor = 0,
        stroke = F,
        label = labels_lsoa
      ) %>%
      addPolygons(
        data = borough_rep,
        group = "London Borough",
        fillOpacity = 0,
        color = "white",
        opacity = 1,
        weight = 3,
        smoothFactor = 0.5,
        label = labels_br,
        highlight = highlightOptions(
          weight = 5,
          color = "#666",
          opacity = 1,
          fillOpacity = 0,
          bringToFront = TRUE)
      ) %>%
      addProviderTiles("CartoDB.DarkMatterNoLabels") %>% 
      addLegend(pal = pal,
                values = ~lsoaboundary_rep@data$svi,
                title = "Social Vulnerability Index",
                position = "bottomleft",
                opacity = 1) %>%
      addLayersControl(
        overlayGroups = c("London Borough"),
        options = layersControlOptions(collapsed = FALSE)
      ) 
  })

  # plot the Gi* map
  output$map3 <- renderLeaflet({
    breaks1 <- c(-1000,-2.58,-1.96,-1.65,1.65,1.96,2.58,1000)
    pal_g <- colorBin(
      palette = "RdBu",
      domain = lsoaboundary_rep@data$G_svi,
      bins = breaks1,
      reverse = TRUE)
    leaflet(lsoaboundary_rep) %>%
      addPolygons(
        fillColor = ~pal_g(lsoaboundary_rep@data$G_svi),
        fillOpacity = 1,
        smoothFactor = 0,
        stroke = F
      ) %>%
      addLegend(
        pal = pal_g,
        values = ~lsoaboundary_rep@data$I_svi,
        title = "GI*,SVI",
        position = "bottomleft",
        opacity = 1
      ) %>%
      addProviderTiles("Esri.WorldGrayCanvas")
  })

  # modify the lsoa attribute table
  lsoaboundary_new <- eventReactive(input$getmap,{
    modifier(x1=input$x1,x2=input$x2,x3=input$x3,x4=input$x4,x5=input$x5,x6=input$x6,x7=input$x7,x8=input$x8,x9=input$x9,x10=input$x10,x11=input$x11,x12=input$x12)
  })
  # display the moran's i test result
  iresult <- eventReactive(input$moransi,{
    moran.test(lsoaboundary_new()@data$svi, lsoa.lw)
  })
  output$i_result <- renderPrint({
    iresult()
  })
  
  # observer to redraw the maps
  observe({
    breaks <- classIntervals(lsoaboundary_new()@data$svi, n=5, style="quantile")$brks
    pal <- colorBin(
      palette = "YlOrBr",
      domain = lsoaboundary_new()@data$svi,
      bins = breaks
    )
    labels <- sprintf(
      "%s",
      lsoaboundary_rep@data$LSOA11NM
    ) %>% lapply(htmltools::HTML)
    labels_br <- sprintf(
      "%s",
      borough_rep@data$name
    ) %>% lapply(htmltools::HTML)
    
    leafletProxy("map1", data = lsoaboundary_new()) %>%
      clearShapes() %>%
      addPolygons(
        fillColor = ~pal(lsoaboundary_new()@data$svi),
        fillOpacity = 1,
        smoothFactor = 0,
        stroke = F,
        label = labels
      ) %>%
    addPolygons(
      data = borough_rep,
      group = "London Borough",
      fillOpacity = 0,
      color = "white",
      opacity = 1,
      weight = 3,
      smoothFactor = 0.5,
      label = labels_br,
      highlight = highlightOptions(
        weight = 5,
        color = "#666",
        opacity = 1,
        fillOpacity = 0,
        bringToFront = TRUE)) %>%
      addLayersControl(
        overlayGroups = c("London Borough"),
        options = layersControlOptions(collapsed = FALSE)
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
 
  observe({
    breaks1 <- c(-1000,-2.58,-1.96,-1.65,1.65,1.96,2.58,1000)
    pal_g <- colorBin(
      palette = "RdBu",
      domain = lsoaboundary_new()@data$G_svi,
      bins = breaks1,
      reverse = TRUE)
    leafletProxy("map3", data = lsoaboundary_new()) %>%
      clearShapes() %>%
      addPolygons(
        fillColor = ~pal_g(lsoaboundary_new()@data$G_svi),
        fillOpacity = 1,
        smoothFactor = 0,
        stroke = F
      ) %>%
      addProviderTiles("Esri.WorldGrayCanvas")
  })
  observe({
    breaks1 <- c(-1000,-2.58,-1.96,-1.65,1.65,1.96,2.58,1000)
    pal_g <- colorBin(
      palette = "RdBu",
      domain = lsoaboundary_new()@data$G_svi,
      bins = breaks1,
      reverse = TRUE)
    proxy <- leafletProxy("map3", data = lsoaboundary_new())
    proxy %>% clearControls() %>%
    addLegend(
      pal = pal_g,
      values = ~lsoaboundary_new()@data$I_svi,
      title = "GI*,SVI",
      position = "bottomleft",
      opacity = 1
    )
  })

})