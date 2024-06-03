add_loc_search_found <- function(leaflet_proxy, search_found, poly){
  
  leaflet_proxy |> 
    leaflet::clearMarkers() |> 
    leaflet::addMarkers(lat = search_found$latlng$lat,
                        lng = search_found$latlng$lng,
                        popup = paste(paste('<strong>','Selected Location','</strong>'),
                                      paste('Latitude:',
                                            search_found$latlng$lat),
                                      paste('Longitude:',
                                            search_found$latlng$lng)))
  
  vals <- data.frame(lat = search_found$latlng$lat,
                     lng = search_found$latlng$lng)
  
  point <- sf::st_point(c(vals$lng, vals$lat))
  message_text <- marker_in_poly(point, poly)
  
  return(list(vals = vals,
              message_text = message_text))
}

add_loc_map_click <- function(leaflet_proxy, map_click, poly){
  
  #Correction in case users go over 180/-180 boundaries
  
  vals <- 
    data.frame(lat = map_click$lat,
               lng=ifelse(map_click$lng[1] > 270,
                          map_click$lng[1] - 360,
                          ifelse(
                            map_click$lng[1] < (-180),
                            map_click$lng[1] + 360,
                            map_click$lng[1])))
  
  leaflet_proxy <-
    leaflet_proxy |> 
    leaflet::clearMarkers() |> 
    leaflet::addMarkers(lat = vals$lat[1],
                        lng = vals$lng[1],
                        popup = paste(
                          paste('<strong>', 'Selected Location',' </strong>'),
                          paste('Latitude:', vals$lat[1]),
                          paste('Longitude:', vals$lng[1])))
  
  # setView is called here as the marker will appear in a different place to 
  # where the user has clicked
  if(map_click$lng[1] > 270 | 
     map_click$lng[1] < (-180)){
    
    leaflet_proxy  |> 
      setView(lng = vals$lng[1],
              lat = vals$lat[1],
              zoom = 4)
    
  }
  
  point <- sf::st_point(c(vals$lng, vals$lat))
  message_text <- marker_in_poly(point, poly)
  
  return(list(vals = vals,
              message_text = message_text))
}

add_loc_manual_ll <- function(leaflet_proxy, lat_input,
                              lng_input, poly){
  
  
  
  if(-90 > lat_input | 90 < lat_input|
     -180 > lng_input | 180 < lng_input){
    
    message_text <- paste("<span style=\"color:red;font-size:16px\">",
                          "Please ensure your latitude and longitude values are 
                         valid")
    
    vals <- data.frame(NULL)
    
    leaflet_proxy |> 
      leaflet::clearMarkers() 
    # |> 
    #   leaflet::clearShapes()
    
  }else{
    leaflet_proxy |> 
      leaflet::clearMarkers() |> 
      leaflet::addMarkers(lat = lat_input,
                          lng = lng_input,
                          popup = 
                            paste(
                              paste('<strong>','Selected Location','</strong>'),
                              paste('Latitude:',lat_input),
                              paste('Longitude:',lng_input)
                            )
                          ) |> 
      setView(lng = lng_input,
              lat = lat_input,
              zoom = 4)
    
    vals <- data.frame(lat = lat_input,
                       lng = lng_input)
  }
  
  point <- sf::st_point(c(vals$lng, vals$lat))
  message_text <- marker_in_poly(point, poly)
  
  return(list(vals = vals, 
              message_text = message_text))
}


get_rectangle_sf <- function(centroid, length_km, width_km){
  
  centroid_lon <- centroid[1]  
  centroid_lat <- centroid[2]
  
  length_m <- length_km * 1000
  width_m <- width_km * 1000
  
  # Create a data frame with the centroid coordinates
  centroid_df <- data.frame(lat = centroid_lat, lon = centroid_lon)
  
  centroid_sf <- 
    sf::st_as_sf(centroid_df, coords = c("lon", "lat"), crs = 4326)
  
  centroid_coords <- 
    sf::st_transform(centroid_sf, crs = 3857) |>  
    sf::st_coordinates()
  
  sw_df <- 
    data.frame(lng1 = centroid_coords[1,1] - width_m / 2,
               lat1 = centroid_coords[1,2] - length_m / 2)
  
  ne_df <-
    data.frame(lng2 = centroid_coords[1,1] + width_m / 2,
               lat2 = centroid_coords[1,2] + length_m / 2)
  
  sw_sf <- st_as_sf(sw_df, coords = c("lng1", "lat1"), crs = 3857)
  ne_sf <- st_as_sf(ne_df, coords = c("lng2", "lat2"), crs = 3857)
  
  sw_sf <- st_transform(sw_sf, crs = 4326)
  ne_sf <- st_transform(ne_sf, crs = 4326)
  
  centroid_sf <- st_transform(centroid_sf, crs = 4326)
  
  sw_coords <- sw_sf |> 
    sf::st_coordinates()
  
  ne_coords <- ne_sf |>  
    sf::st_coordinates()
  
  rect_coords <- 
    data.frame(
      lng = c(sw_coords[1,1], ne_coords[1,1]),
      lat = c(sw_coords[1,2], ne_coords[1,2])
    )
  
  rect_vertices <-
    matrix(
      c(sw_coords[1,1], sw_coords[1,2],
        sw_coords[1,1], ne_coords[1,2],
        ne_coords[1,1], ne_coords[1,2],
        ne_coords[1,1], sw_coords[1,2],
        sw_coords[1,1], sw_coords[1,2]),
      ncol = 2,
      byrow = TRUE
    )
  # 
  # lngs_identical <-
  #   all(st_coordinates(rect_sf)[1,1] == st_coordinates(rect_sf)[,1])
  # 
  # lats_identical <-
  #   all(st_coordinates(rect_sf)[1,2] == st_coordinates(rect_sf)[,2])
  # 
  rect_sf <- sf::st_polygon(list(rect_vertices))   
  
  rect_sf |> st_sfc(crs = 4326)
  
}

'Function that extracts relevant polygons for region select map '

pull_sf_mapping_data <- function(h_mappings){
  
  polys_lng <-
    lapply(strsplit(as.character(h_mappings$poly_lng),
                    ","),
           as.numeric)
  
  polys_lat <-
    lapply(strsplit(as.character(h_mappings$poly_lat),
                    ","),
           as.numeric)
  
  polys <-
    mapply(x = polys_lng,
           y = polys_lat,
           function(x, y) {
             rbind(cbind(x, y),
                   cbind(x[1], y[1]))
           }, SIMPLIFY = FALSE)
  
  polys <-
    lapply(polys,
           function(x) {
             sf::st_polygon(list(x))
           })
  
  polys <-
    lapply(polys,
           FUN = st_sfc)
  
  polys <-
    lapply(polys,
           FUN = st_set_crs,
           value = "+proj=longlat +datum=WGS84")
  
  polys <-
    do.call(rbind, polys)
  
  sf::st_sf(region_name = h_mappings$region_name,
            geometry = polys,
            crs = 4326)
  
}


marker_in_poly <- function(point_coords, poly) {
  
  
  # 3857 is more accurate for certain regions but need to use 4326 for 
  # South Pacific due to issues introduced from crossing the dateline
  
  transform_code <- ifelse(poly$region_name == "South Pacific", 4326, 3857)
  
  marker <-
    sf::st_point(point_coords) |> 
    sf::st_sfc(crs = 4326)|>
    sf::st_transform(transform_code)
  
  poly <-
    poly |>
    sf::st_transform(transform_code)
  
  in_poly <- st_contains(poly, marker, sparse = FALSE)[[1]]
  
  if(in_poly == 1){
    NULL
  }else{
    paste("<span style=\"color:red;font-size:16px\">",
          "Please ensure your selected latitude and longitude values are 
           located somewhere within the hazard data you have loaded")
  }
  
}

shape_in_poly <- function(expo_poly, haz_poly) {
  
  expo_poly <-
    sf::st_transform(expo_poly, 3857)
  
  haz_poly <-
    sf::st_transform(haz_poly, 3857)
  
  st_within(expo_poly, haz_poly, sparse = FALSE)[[1]]
  
}


