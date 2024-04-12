library(mxi.pkg.chirps)
library(reticulate)

computer_username <- "JamesMcIlwaine"

dir_working <-
  file.path(
    "C:",
    "Users",
    computer_username,
    "Maximum Information Dropbox",
    "Innovation",
    "Risk Explorer",
    "Live_App",
    "RiskExplorer",
    "Dev"
  )

filter_range <-
  list(lon_min = 25,
     lon_max = 26,
     lat_min = -20,
     lat_max = -19)

return_chirps_data <- function(filter_range,
                               first_run = FALSE, 
                               version = "3.9.13", 
                               env_name = "chirps", 
                               dir_working, 
                               interp_param = NA ){
  
  if( first_run == TRUE){
    
    #Install Python and create virtual environment
    reticulate::install_python(version)
    reticulate::virtualenv_create(env_name, version = version)
    reticulate::use_virtualenv(env_name)  
    
    #Install required packages
    required_py_packages <-
      c(
        "dask",
        "h5netcdf",
        "netcdf4",
        "numpy",
        "xarray",
        "scipy"
      )
  
    reticulate::py_install(required_py_packages, envname = env_name)
    
  }else{
    
    reticulate::use_virtualenv(env_name)  
    
  }

  dir_chirps <- file.path(dir_working,"data", "chirps")
  
  xarray <-
    mxi.pkg.chirps::process_chirps_data(
      dir_chirps,
      lonmin = filter_range$lon_min,
      lonmax = filter_range$lon_max,
      latmin = filter_range$lat_min,
      latmax = filter_range$lat_max
    )
  
  if (!is.na(interp_param)){
    xarray <- mxi.pkg.chirps::interpolate_chirps_data(xarray, interp_param)
  }
  
  df <- mxi.pkg.chirps::chirps_xarray_to_dataframe(xarray)
  
  return(df)

}


