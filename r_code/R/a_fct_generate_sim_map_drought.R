generate_sim_map_drought <- function(one_year_hazard_data, 
                                     individual_sim_data,
                                     index_var,
                                     display_var, 
                                     display_fun, 
                                     value_per_insured, 
                                     bbox) {
  
  if(display_var != "Payout"){
    value_per_insured <- 1
    payout_bins <- c(0,0.01,1)
  } else {
    payout_bins <-
      c(0,0.2,0.4,0.6,0.8,1) * value_per_insured  
  }
  
  
    if(index_var == "Number of Dry Spell Days") {
      index_bins <-    
        sort(
          c(0, 10, 15, 20, 25, 30, 35, 40, 45, 9999)
          , decreasing = FALSE)  
      reverse_val <- TRUE
    } else {
      index_bins <-    
        sort(
          c(0, 25, 50, 75, 90, 125, 150, 175, 200, 9999 )
          , decreasing = FALSE)  
      reverse_val <- FALSE
    }
    
  index_palette_colors <- brewer.pal(9, "Spectral")

  map_palette <-
    leaflet::colorBin(palette = index_palette_colors,
                      bins = index_bins,
                      reverse = reverse_val,
                      right = FALSE)

  marker_palette <-
    leaflet::colorBin(palette = "Greys",
                      bins = payout_bins,
                      domain = individual_sim_data[[display_var]])

  one_year_hazard_data <-
    t(one_year_hazard_data) |>
    apply(MARGIN = c(2), rev)
  
  labels <-
    paste(
      "<b>",
      "Location:",
      "</b>",
      individual_sim_data$Location, 
      "<br>",
      "<b>",
      "Weather Index Value",
      "</b>",
      if(index_var == "Number of Dry Spell Days") {
        scales::comma(
          individual_sim_data$Index,
          accuracy = 1,
          scale = 1
        )
      } else {
        scales::percent(
          individual_sim_data$Index,
          accuracy = 0.1,
          scale = 1
        )
      }
      ,
      "<br>",
      "<b>",
      paste0(display_var,":"),
      "</b>",
      display_fun(individual_sim_data[[display_var]])
    )
  
  if( bbox$min_lon == bbox$max_lon | bbox$min_lat == bbox$max_lat ) {
    
    leaflet::leaflet() |> 
      leaflet::addTiles() |> 
      leaflet::addCircleMarkers(data = individual_sim_data,
                                radius = 8,
                                color = "black",
                                fillColor = 
                                  ~marker_palette(
                                    individual_sim_data[[display_var]]
                                  ),
                                fillOpacity = 1,
                                label = lapply(labels, htmltools::HTML))
  } else {
    
    index_raster <-
      raster::raster(one_year_hazard_data,
                     xmn = bbox$min_lon, xmx = bbox$max_lon,
                     ymn = bbox$min_lat, ymx = bbox$max_lat)
    
    raster::projection(index_raster) <- "+proj=longlat +datum=WGS84"
    
    leaflet::leaflet() |> 
      leaflet::addTiles() |> 
      leaflet::addRasterImage(index_raster, 
                              opacity = 0.8, 
                              colors = map_palette,
                              method = "ngb") |>
      leaflet::addLegend(pal = map_palette,
                         title = index_var,
                         values = c(index_bins),
                         position = "bottomright",
                         opacity = 0.8) |> 
      leaflet::addCircleMarkers(data = individual_sim_data,
                                radius = 8,
                                color = "black",
                                fillColor = 
                                  ~marker_palette(
                                    individual_sim_data[[display_var]]
                                ),
                                fillOpacity = 1,
                                label = lapply(labels, htmltools::HTML)) |> 
      leaflet::addLegend(pal = marker_palette,
                         title = display_var,
                         values = payout_bins,
                         position = "bottomleft",
                         opacity = 1)
  }
  
}
