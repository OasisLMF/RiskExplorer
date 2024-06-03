library(sf)
library(dplyr)
library(leaflet)
library(stringr)

haz_mappings <-
  readr::read_csv("./data/mappings/hazard_mappings.csv") |> 
  dplyr::filter(dataset == "IBTrACS Historical Data") 

earliest_year <- 2012

haz_agency <-
  data.frame(
    region_code = 
      c(
        'NA',
        'NI',
        'SI',
        'EP',
        'WP',
        'SP',
        'NI',
        'SI',
        'WP',
        'WP',
        'SP',
        'SP'
      ),
    agency = 
      c(
        'USA',
        'NEWDELHI',
        'REUNION',
        'USA',
        'USA',
        'WELLINGTON',
        'USA',
        'BOM',
        'TOKYO',
        'CMA',
        'BOM',
        'NADI'
      ),
    agency_no = 
      c(
        rep(1, 6),
        rep(2, 2),
        2,
        3,
        2,
        3
      )
  )

# i <- 9
for ( i in 1:nrow(haz_agency)) {
 
  region_code <- haz_agency[i,"region_code"] 
  agency_name  <- haz_agency[i,"agency"] 
  agency_no  <- haz_agency[i,"agency_no"] 
  
  wind_var <-
    paste0("AGENCY",agency_no,"_","WIND")
  
  lat_var <-
    paste0("AGENCY",agency_no,"_","LAT")
  
  lon_var <-
    paste0("AGENCY",agency_no,"_","LON")
  
  if(region_code == "NA") {
    start_year <- 1948
  } else {
    start_year <- 1978
  }
  
  data_loc <-
    paste0("./data/ibtracs/ibtracs_data_", 
           region_code,
           "_", 
           start_year, 
           "_2022-07-15.csv")
   
  ibtracs_data <- 
    readr::read_csv(data_loc,
                    col_types = 
                      cols( SID = col_character())
                    ) |> 
    dplyr::select(
      dplyr::all_of(
        c(
          "ISO_TIME",
          "SID",
          "NAME",
          "SEASON",
          paste0("AGENCY",agency_no,"_",c("LAT","LON","WIND"))
        )
      )
    ) |> 
    dplyr::filter(
      !is.na(!!dplyr::sym(wind_var)),
      SEASON >= earliest_year,
      hour(ISO_TIME) %in% c(0, 6, 12, 18),
      minute(ISO_TIME) == 0
    ) |>
    dplyr::group_by(
      SID
    ) |> 
    dplyr::mutate(
      max_wind = max(!!dplyr::sym(wind_var))
    ) |> 
    dplyr::filter(
      max_wind > 119
    ) |> 
    dplyr::ungroup() |> 
    dplyr::arrange(
      SID, ISO_TIME
    )
  
  ibtracs_data <-
    ibtracs_data |> 
    st_as_sf(
      coords = c(lon_var, lat_var)
    ) 
  
  line_list <-
    ibtracs_data  |> 
      split(f = ibtracs_data$SID)
  
  names(line_list) <- unique(paste(ibtracs_data$NAME, ibtracs_data$SEASON))
  
  make_line <- function(x){
    do.call(c, st_geometry(x)) |>  
      st_cast("LINESTRING")
  }
  
  line_list <-  
    sapply(line_list, make_line) |> 
    sf::st_sfc()
  
  ibtracs_sf <-
    sf::st_sf(
      geometry = line_list,
      name = unique(paste(ibtracs_data$NAME, ibtracs_data$SEASON)),
      crs = 4326
    )
  
  file_name <- paste(region_code, agency_name, sep = "_")
  file_loc <- paste0("./data/hazard_preview_layers/",file_name,".shp")
    
  sf::st_write(ibtracs_sf, file_loc, append = FALSE)
            
}

storm_tracks <-    
  sf::st_read(
    dsn = "./data/hazard_preview_layers/",
    paste(haz_agency$region_code[6],
          haz_agency$agency[6], sep = "_")
  )
          
  leaflet() |> 
  addTiles() |> 
  addPolylines(
    data = storm_tracks, 
    label = ~name
  )
  
  
  
  
  
  