
raster_data <-
  raster::raster("C:/Users/JamesMcIlwaine/Maximum Information Dropbox/Innovation/Risk Explorer/Live_App/Dev/data/hazard_preview_layers/SAF_drought.tif")

index_bins <-
  c(0, 100, 200, 300, 400, 500, 750, 1000, 1500, 9999 )

index_palette_colors <- RColorBrewer::brewer.pal(9, "Spectral")

map_palette <-
  leaflet::colorBin(palette = index_palette_colors,
                    bins = index_bins,
                    right = FALSE)

crs(raster_data) <- CRS("+proj=longlat +datum=WGS84 +no_defs")

leaflet::leaflet() |> 
leaflet::addTiles() |> 
leaflet::addRasterImage(
  raster_data,
  opacity = 0.8, 
  colors = map_palette,
  method = "ngb") |> 
leaflet::addLegend(pal = map_palette,
                   title = "Average Yearly Rainfall (mm)",
                   values = c(index_bins),
                   position = "bottomright",
                   opacity = 0.8) 
  
)
