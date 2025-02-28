generate_hist_map_tc <- function(hist_data, expo_ll, expo_radius) {
  
  hist_map <-
    leaflet::leaflet()|>
    leaflet::addCircles(
      lng = expo_ll[1],
      lat = expo_ll[2],
      radius = expo_radius,
      label = "Exposure Loss Area"
    )|>
    leaflet::addMarkers(
      lng = expo_ll[1],
      lat = expo_ll[2],
      label = "Selected Location",
      popup = paste(
                paste('<strong>', 'Selected Location', '</strong>'),
                 paste('Latitude:', expo_ll[2]),
                 paste('Longitude:', expo_ll[1])
              )
      ) |>
    leaflet::addTiles() |>
    leaflet::setView(
      lng = expo_ll[1],
      lat = expo_ll[2],
      zoom = 7
    )
  
  if(!is.null(length(hist_data$Longitude)) &
     !is.na(hist_data$Longitude[1])) {
    
    for (i in unique(hist_data$`Storm ID`)) {
      
      hist_map <- 
        leaflet::addPolylines(
          hist_map,
          data = hist_data[hist_data$`Storm ID` == i,],
          lat = ~Latitude, 
          lng = ~Longitude,
          label = ~Label,
          weight = 1.5,
          opacity = 0.03,
          color = "red"
        )
    }
    
  }
  
  return(hist_map)
  
}
