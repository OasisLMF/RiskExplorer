
gen_sim_centroids <- function(exposure_point, 
                              maxi_radius, 
                              mini_radius,
                              sims_n, 
                              weighting_function, 
                              weighting_parameter = 3.2) {
  
  set.seed(0)
  
  lat_rad <- convert_rad_deg(exposure_point[2], "rad")
  lng_rad <- convert_rad_deg(exposure_point[1], "rad")
  
  # Define special quantities needed for min/max bounding box
  # calculations
  R <- 6378.137
  r <- (maxi_radius - mini_radius)/R
  lat_T <- asin(sin(lat_rad)/cos(r))
  delta_lng <- asin(sin(r)/cos(lat_rad))
  
  
  # Define min/max lat-longs for sampling
  maxlat <- convert_rad_deg(lat_rad + r, "deg")
  minlat <- convert_rad_deg(lat_rad - r, "deg")
  
  maxlng <- convert_rad_deg(lng_rad + delta_lng, "deg")
  minlng <- convert_rad_deg(lng_rad - delta_lng, "deg")
  
  
  # Simulate points from square and throw out values that sit
  # outside circle
  point_sims <- data.frame(lng = 0, lat = 0, dist = 0, weight = 0)
  
  i <- 1
  
  while (i <= sims_n) {
    
    distance <- 
      sf::st_distance(
        sf::st_as_sf(
          data.frame(
            lon = runif(1, min = minlng, max = maxlng),
            lat = runif(1, min = minlat, max = maxlat)
          ),
          crs = 4326
        ),
        exposure_point
      )
    
    if (distance < (maxi_radius - mini_radius)) {
      
      point_sims[i, ] <- c(lng_s, 
                           lat_s, 
                           distance, 
                           ifelse(
                            weighting_function == "linear", 
                            (1 - distance/maxi_radius), 
                             exp(- weighting_parameter * distance / maxi_radius)
                            )
                           )
      i <- i + 1
      
    }
  }
  
  return(point_sims)
  
}
