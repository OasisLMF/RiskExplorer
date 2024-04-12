
# This function generates centroids of simulation mini-circles given
# a number of sims to run and a mini and maxi circle size. Mini
# circle size is needed to ensure no points are chosen on the edge of
# the maxi-circle where the mini-circle's radius might exceed the
# maxi-circle and include points that exceed 5x RMW in the
# calculations.

get_epsg_code <- function(pts) {
  ifelse(pts[2] >= 0, 32600, 32700) +
    (floor((pts[1] + 180) / 6) %% 60) + 1
}

# Converts degrees to radians
convert_rad_deg <- function(value, conversion_measure) {
  if (conversion_measure == "rad") {
    value * pi/180
  } else {
    value * 180/pi
  }
}

gen_sim_centroids_even <-function(exposure_point,
                                  maxi_radius,
                                  mini_radius,
                                  sims_n,
                                  weighting_function,
                                  weighting_parameter = 3.2) {
  
  dists <- runif(sims_n, 0, maxi_radius)
  
  expo <-
    data.frame(lng = exposure_point[1], lat = exposure_point[2]) |> 
    sf::st_as_sf(coords = c('lng', 'lat')) |> 
    sf::st_set_crs(4326)
  
  epsg <- get_epsg_code(exposure_point)
  expo <- st_transform(expo,epsg)
  
  utm_n <- st_coordinates(expo)[,1]
  utm_e <- st_coordinates(expo)[,2]
  
  angles <- runif(sims_n,0,360)
  angles <- convert_rad_deg(angles,"rad")
  
  sims_utm_n <- utm_n + dists*1000*cos(angles)
  sims_utm_e <- utm_e + dists*1000*sin(angles)
  
  expo <- 
    expo |> sf::st_transform(crs=4326)
  
  point_sims <- 
    data.frame(cbind(lng = sims_utm_n, lat = sims_utm_e)) |> 
    st_as_sf(coords = c('lng', 'lat')) |> 
    sf::st_set_crs(epsg) |>
    sf::st_transform(crs = 4326)
  
  point_sims <-
    data.frame(
      lng = st_coordinates(point_sims)[, 1],
      lat = st_coordinates(point_sims)[, 2],
      dist = dists,
      weight = if (weighting_function == "linear") {
        (1 - distance / maxi_radius)
      } else{
        exp(-weighting_parameter * dists / maxi_radius)
      }
    )
  
  return(point_sims)
}




gen_sim_centroids <- function(exposure_point, maxi_radius, mini_radius,
                              sims_n, weighting_function, weighting_parameter = 3.2) {
  
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
    
    lat_s <- runif(1, min = minlat, max = maxlat)
    lng_s <- runif(1, min = minlng, max = maxlng)
    distance <- spDistsN1(cbind(lng_s, lat_s), as.numeric(exposure_point),
                          longlat = TRUE)
    
    if (distance < (maxi_radius - mini_radius)) {
      
      point_sims[i, ] <- c(lng_s, lat_s, distance, ifelse(weighting_function ==
                                                            "linear", (1 - distance/maxi_radius), exp(-weighting_parameter *
                                                                                                        distance/maxi_radius)))
      i <- i + 1
      
    }
  }
  # toc()
  return(point_sims)
  
}