
gen_sim_centroids_even <- function(exposure_point,
                                   maxi_radius,
                                   mini_radius,
                                   sims_n,
                                   weighting_function,
                                   weighting_parameter = 3.2) {
  
  dists <- runif(sims_n, 0, maxi_radius)
  
  expo <- 
    exposure_point |> 
    sf::st_as_sf(
      coords = c('lng', 'lat'), 
      crs = 4326
    )|>
    sf::st_transform(3857)
  
  utm_n <- st_coordinates(expo)[,1]
  utm_e <- st_coordinates(expo)[,2]
  
  angles <- runif(sims_n, 0, 360)
  angles <- convert_rad_deg(angles, "rad")
  
  sims_utm_n <- utm_n + dists * cos(angles)
  sims_utm_e <- utm_e + dists * sin(angles)
  
  point_sims <- 
    data.frame(
      cbind(
        lng = sims_utm_n,
        lat = sims_utm_e)
      ) |> 
    st_as_sf(coords = c('lng','lat'), 
             crs = 3857) |>
    sf::st_transform(4326)
  
  point_sims <- 
    sf::st_as_sf(point_sims, crs = 4326) |>
    dplyr::mutate(
      dist = dists,
      weight = 
        if(weighting_function == "linear") {
          (1 - distance/maxi_radius)
        } else {
          exp( - weighting_parameter * dists / maxi_radius)
        }
    )
  
  return(point_sims)
}