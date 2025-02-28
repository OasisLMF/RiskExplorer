library(reticulate)
library(mxi.pkg.chirps)
library(tictoc)
library(data.table)
library(lubridate)

version <- "3.9.13"
env_name <- "chirps"

mappings <-
  read.csv("./data/mappings/hazard_mappings.csv")
  
  
reticulate::install_python(version)
reticulate::virtualenv_create(env_name, version = version)
reticulate::use_virtualenv(env_name)

required_py_packages <-
  c(
    "dask",
    "h5netcdf",
    "netcdf4",
    "numpy",
    "packaging",
    "pandas",
    "xarray"
  )

reticulate::py_install(required_py_packages, envname = env_name)

tictoc::tic()

chirps_data <-
  mxi.pkg.chirps::process_chirps_data("./data/chirps/chirps_srx/chirps_EAF.nc", 
                      lonmin = 36.0, 
                      lonmax = 36.5, 
                      latmin = 0, 
                      latmax = 0.5)

chirps_data <-
  mxi.pkg.chirps::chirps_xarray_to_dataframe(chirps_data) |>
  dplyr::mutate(time = as.POSIXct(time, tz = "UTC")) 

chirps_data <-
  chirps_data|>
    dplyr::mutate(time = lubridate::yday(chirps_data$time))|>
    dplyr::mutate(year = lubridate::year(chirps_data$time))|>
    dplyr::group_by(year, latitude, longitude)|>
    dplyr::mutate(pentad = rank(time))|>

tictoc::toc()
  

chirps_data <-
  chirps_data|>
  dplyr::mutate(time = ceiling(chirps_data$time) - 
                       chirps_data$time * (chirps_data$time > 59))
                

tictoc::toc()  
unique(chirps_data$time)

