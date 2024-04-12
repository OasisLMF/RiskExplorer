generate_sim_map_tc <- function(individual_sim_data, 
                                sim_summary_data, 
                                expo_ll, 
                                expo_radius) {
  
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
                 color = "#D41F29", 
                 radius = expo_radius * 5, 
                 label = "Simulation Sample Area", 
                 layerId = "maxi_circles") |>
    leaflet::addCircles(lng = expo_ll[1],
                 lat = expo_ll[2], 
                 radius = expo_radius, 
                 label ="Exposure Loss Area", 
                 layerId = "expo_circles") |>
    leaflet::addCircles(lng = sim_summary_data$Longitude[1],
                 lat = sim_summary_data$Latitude[1],
                 color = "#D41F29", 
                 radius = expo_radius, 
                 label = 
                   paste("Simulation", 
                         sim_summary_data$`Sim No`,
                         "Loss Area"), 
                 layerId = "mini_circles")
  
  if(sum(individual_sim_data$Payout)!= 0) {
    sim_map <- 
      sim_map |>
      addAwesomeMarkers(lng = individual_sim_data$Longitude,
                        lat = individual_sim_data$Latitude,
                        label = individual_sim_data$Label,
                        icon = makeAwesomeIcon("cloud",
                                               iconColor="white",
                                               markerColor ="#D41F29"))
  }
  
  return(sim_map)
}
