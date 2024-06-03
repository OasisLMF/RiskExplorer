generate_sim_map_st <- function(individual_sim_data, 
                                sim_summary_data, 
                                expo_ll, 
                                expo_radius, 
                                icon_type) {
  
  sim_map <-  
    leaflet::leaflet() |>
    leaflet::setView(
      lng = expo_ll[1], 
      lat = expo_ll[2], 
      zoom = 5
    ) |>
    leaflet::addTiles()|>
    leaflet::addMarkers(
      lng = expo_ll[1],
      lat = expo_ll[2],
      label = "Selected Location/Exposure Centre ",
      popup = paste(
        paste('<strong>','Selected Location','</strong>'),
        paste('Latitude:', expo_ll[2]),
        paste('Longitude:', expo_ll[1]))) |>
    leaflet::addCircles(lng = expo_ll[1],
                        lat = expo_ll[2], 
                        radius = expo_radius * 1000, 
                        label = "Exposure Area", 
                        layerId = "expo_circles") 
  
  if(sum(individual_sim_data$Payout)!= 0) {
    sim_map <- 
      sim_map |>
      addAwesomeMarkers(lng = individual_sim_data$Longitude,
                        lat = individual_sim_data$Latitude,
                        label = lapply(individual_sim_data$Label, 
                                       htmltools::HTML),
                        icon = makeAwesomeIcon(icon_type,
                                               iconColor = "white",
                                               markerColor ="#D41F29"))
  }
  
  return(sim_map)
}
