library(raster)
library(sf)
library(tidyverse)
library(reticulate)
library(ncdf4)

setwd("C:\\Users\\JamesMcIlwaine\\Maximum Information Dropbox\\Innovation\\Risk Explorer\\Live_App\\Dev")

region_codes <-
  read.csv("./data/mappings/hazard_mappings.csv") |> 
  dplyr::filter(peril == "Drought") |> 
  dplyr::select(region_code) |> 
  unlist()


for ( i in (1:length(region_codes))) {
  
  region <- region_codes[i]
  
  filename <-
    paste0("./data/chirps/chirps_srx/chirps_", region, "_0p5.nc")
  
  nc_test <-
    ncdf4::nc_open(
      filename = filename,
      return_on_error = TRUE)
  
  rainfall <-
    ncvar_get(nc_test, "precip")
  
  mean_rainfall <-
    apply(rainfall,
          FUN = mean,
          MARGIN = c(1,2) ) * 72
  
  lats <- range(ncdf4::ncvar_get(nc_test, "latitude"))
  lngs <- range(ncdf4::ncvar_get(nc_test, "longitude"))  
  
  mean_rainfall <-
    t(mean_rainfall) |>
    apply(MARGIN = c(2), rev)
  
  index_raster <-
    raster::raster(mean_rainfall,
                   xmn = lngs[1], xmx = lngs[2],
                   ymn = lats[1], ymx = lats[2])
  
  index_bins <-
    c(0, 100, 200, 300, 400, 500, 750, 1000, 1500, 9999 )

  index_palette_colors <- RColorBrewer::brewer.pal(9, "Spectral")

  map_palette <-
    leaflet::colorBin(palette = index_palette_colors,
                      bins = index_bins,
                      right = FALSE)
  
  raster::projection(index_raster) <- "+proj=longlat +datum=WGS84"
  
  raster::writeRaster(
    index_raster,
    filename = 
      paste0(
        "./data/hazard_preview_layers/",
        region, 
        "_", 
        "drought.tif"
      ),
    format = "GTiff" )
  
  leaflet::leaflet() |> 
    leaflet::addTiles() |> 
    leaflet::addRasterImage(index_raster, 
                            opacity = 0.8, 
                            colors = map_palette,
                            method = "ngb") 

}

