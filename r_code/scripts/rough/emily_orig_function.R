library(reticulate)
library(mxi.pkg.chirps)
library(tictoc)
library(data.table)
library(lubridate)
library(abind)
library(runjags)
library(ncdf4)
library(tidync)

source("./scripts/chirps_helper_funs.R")

region_code <- "EAF"
date_start <- "04/07/2024"
date_end <- "27/09/2024"

packages <-
  c("dask",
    "h5netcdf",
    "netcdf4",
    "numpy",
    "packaging",
    "pandas",
    "xarray",
    "scipy")

# Do we need to prevent this running more than once
setup_python_environment(version = "3.9.13", 
                         env_name = "chirps",
                         packages = packages)

python_script <- './scripts/python_index_calculation.py'
reticulate::source_python(python_script)

hazard_mappings <-
  read.csv("./data/mappings/hazard_mappings.csv")

pentad_mappings <-
  read.csv("./data/mappings/pentad_mappings.csv")

vul_curve_type <- "Linear"
intensity_measure <- "Percentage of Climatology"

vul_table <- 
  data.frame(Intensity = c(120, 80),
             Damage_Percentage = c(0, 1))|>  
  dplyr::filter(Intensity != ""|
                  Damage_Percentage != "")

if(nrow(vul_table) > 1){
  vul_table <- 
    sapply(vul_table,as.numeric) |> 
    as.data.frame()  
}else{
  vul_table <-
    data.frame(Intensity = as.numeric(vul_table[1]),
               Damage_Percentage = as.numeric(vul_table[2]))
}

threshold <- 
  if(intensity_measure == "Percentage of Climatology"){
    max(vul_table$Intensity)
  }else{
    min(vul_table$Intensity)
  }

vul_table <- 
  rbind(
    if(intensity_measure == "Pressure" | 
       intensity_measure == "Percentage of Climatology"){
      c(999999,0)
    }else{
      c(0, 0)
    }, 
    vul_table) |> 
  dplyr::rename(intensity = Intensity, loss = Damage_Percentage) %>%
  tidyr::drop_na()

# Based on max climatology or min dry days that produces a payout 

window_start <- 
  pentad_mappings[match(date_start, pentad_mappings$Date), "Pentad"]

window_end <- 
  pentad_mappings[match(date_end, pentad_mappings$Date), "Pentad"]

# 
# lonmin <- min(rect_coords$lng)
# lonmax <- max(rect_coords$lng)
# latmin <- min(rect_coords$lat)
# latmax <- max(rect_coords$lat)
# n_sims <- 10000

lonmin <- 33
lonmax <- 37
latmin <- 0
latmax <- 4

#Hardcoded
year_length <- 72
year_start <- 1983 
year_end <- 2019
nosims <- 500
number_localities <-20
number_insured <- number_localities

file_full <- "./data/chirps/chirps_srx"
file_full <- paste(file_full, 
                   paste0("chirps_", region_code, ".nc"), 
                   sep = "/")

file_intermediate <- paste0("./data/temp/",runjags::new_unique(),".nc")

#Error handling around lls that aren't in the file
tic()
return_chirps_nc(window_start, window_end, lonmin, lonmax, latmin, latmax,
                 file_full, year_length, year_start, year_end, threshold, 
                 file_intermediate)
toc()



sample_metric_seasonal_total_index <- 
  function(file_intermediate, number_insured, threshold, 
           no_sims, number_localities, vulnerability) {
    
    precip_index_allyears_nc <- nc_open(file_intermediate)
    years <- ncvar_get(precip_index_allyears_nc, "year")
    lons <- ncvar_get(precip_index_allyears_nc, "longitude")
    lats <- ncvar_get(precip_index_allyears_nc, "latitude")
    year_list <- years #Renaming years to year_list for legacy reasons
  
  #The output will be the index at randomly selected longitude and latitude points. Setting up the arrays for this.
  lon_output <- array(NA, dim = c(nosims, length(year_list), number_localities * 10))
  lat_output <- array(NA, dim = c(nosims, length(year_list), number_localities * 10))
  index_output <- array(NA, dim = c(nosims, length(year_list), number_localities * 10))
  
  #Originally, the code allowed us to vary the number of people living at each locality.
  #We are not going to use this functionality, but we will keep it in the code in case we want to
  #introduce it later. Population flag is set to 0 so that we have the same number of people in each locality
  
  no_people_output <- array(NA, dim = c(nosims, length(year_list), number_localities * 10))
  population_flag = 0
  
  #Iterating over all the years
  for (l in seq_along(year_list)) {
    
    #Spreading out the population over the localities
    if (population_flag == 1) {
      tmp <- sample(1:10, size = number_localities * 10, replace = TRUE)
      no_people <- round(number_insured * tmp * 10 / sum(tmp))
    } else {
      tmp <- array(1,dim=c(size = number_localities * 10))
      no_people <- round(number_insured * tmp * 10 / sum(tmp))
    }
    
    
    #Select the year
    yearin <- year_list[l]
    
    #Extract the index for the particular year. Because we are looking at seasonal totals, this has been calculated in the previous step.
    precip_index_oneyear <- ncvar_get(precip_index_allyears_nc, "insured_metric", start = c(1, 1, which(years == yearin)), count = c(-1, -1, 1))
    
    #The only thing that rainy_season_mask is used for is to exclude any points at which there is no rainy season.
    #This is not necessary now that we are defining our own rainy season. I may get rid of this.
    rainy_season_mask <- ncvar_get(precip_index_allyears_nc, "rainy_season_mask")
    
    
    all_samples <- numeric(nosims)
    
    for (iterations in seq_len(nosims)) {
      #Set up the arrays that will be incremented during the simulations
      lon_list <- numeric()
      lat_list <- numeric()
      samples <- numeric()
      samples_low <- numeric()
      no_people_out <- numeric()
      enough_flag <- 0
      count <- 0
      
      #The while condition tests to see whether we have reached the specified number of insured people. This is necessary if we randomly spread the population over the region (population_flag=1)
      while (enough_flag == 0) {
        #Randomly select a spatial point within precip_index_oneyear
        i_ind <- sample(seq_len(dim(precip_index_oneyear)[2]), 1)
        j_ind <- sample(seq_len(dim(precip_index_oneyear)[1]), 1)
        
        #This is now always true for user specified seasons, so we could get rid of this conditional. Keeping it in for now, in case we ever want to use spatially varying seasons
        if (sum(rainy_season_mask[j_ind, i_ind,], na.rm = TRUE) != 0) {
          
          #Append the longitude, latitude and indices and number of people associated with the indices randomly chosen above
          lon_list <- c(lon_list, lons[j_ind])
          lat_list <- c(lat_list, lats[i_ind])
          samples <- c(samples, precip_index_oneyear[j_ind, i_ind])
          no_people_out <- c(no_people_out, no_people[count + 1])
          
          #Identify if our index has breached the threshold at each of the longitude-latitude points. If we want to, we could include partial breaches here, using a linear interpolation between entry and exit thresholds.
          if (precip_index_oneyear[j_ind, i_ind] <= threshold) {
            samples_low <- c(samples_low, no_people[count + 1])
          }
          
          #The counter allows us to specify the locality number
          count <- count + 1
          
          if (sum(no_people_out, na.rm = TRUE) >= number_insured) {
            enough_flag <- 1
          }
          
          #Writing the longitude, latitude, number of people and index to 3d arrays
          sim_no <- iterations
          year_no <- l
          loc_no <- count
          
          lon_output[sim_no, year_no, loc_no] <- lons[j_ind]
          lat_output[sim_no, year_no, loc_no] <- lats[i_ind]
          no_people_output[sim_no, year_no, loc_no] <- no_people[count]
          index_output[sim_no, year_no, loc_no] <- precip_index_oneyear[j_ind, i_ind]
        }
        
        
      }
      
      #all_samples is the total number of times that the index is breached.
      all_samples[iterations] <- sum(samples_low, na.rm = TRUE)
      
    }
    
    #Appending the yearly data for all simulations into the full array for all years and simulations
    if (l == 1) {
      all_samples_year <- array(all_samples, dim = c(1, length(all_samples)))
    } else {
      all_samples_year <- abind(all_samples_year, array(all_samples, dim = c(1, length(all_samples))),along=1)
    }
  }
  
  #This gives the number of payouts per year. we could use this as the basis for most of the exhibits
  all_samples_year_df <- as.data.frame(all_samples_year)
  all_samples_year_df$Year <- year_list
  all_samples_year_df <- all_samples_year_df[,c(nosims+1,seq(1,nosims))]
  colnames(all_samples_year_df) <- c('Year',seq(1,nosims))
  
  file.remove('simulation_r.csv')
  write.csv(all_samples_year_df, "simulation_r.csv", row.names = FALSE)
  
  #long data format conversion. This is too slow.
  #final_longitude_list=numeric()
  #final_latitude_list=numeric()
  #final_index_list=numeric()
  #final_people_list=numeric()
  
  #for (localities in seq(1,number_localities)) {
  #    print(localities)
  #    for (simulations in seq(1,nosims)) {
  #        for (years in seq(1,length(year_list))) {
  #                final_longitude_list=c(final_longitude_list,lon_simulation[simulations,years,localities])
  #                final_latitude_list=c(final_latitude_list,lat_simulation[simulations,years,localities])
  #                final_index_list=c(final_index_list,index_simulation[simulations,years,localities])
  #                final_people_list=c(final_people_list,number_people_simulation)
  #        }
  #    }
  #}
  
  #Prepare the output data into netcdf format
  simulation <- seq(1,nosims)
  year <- year_list
  locality_index <- seq(1,number_localities)
  
  lon_output <- lon_output[,,seq(1,number_localities)]
  lat_output <- lat_output[,,seq(1,number_localities)]
  index_output <- index_output[,,seq(1,number_localities)]
  number_people_output <- no_people_output[,,seq(1,number_localities)]
  
  #Remove the existing netcdf output file
  file.remove('simulation_r.nc')
  
  #Define the dimensions
  simulation_dim <- ncdim_def(name='simulation',units='None',vals=simulation)
  year_dim <- ncdim_def(name='year',units='None',vals=year)
  locality_index_dim <- ncdim_def(name='locality_index',units='None',vals=locality_index)
  
  dimlist=list(locality_index_dim,year_dim,simulation_dim)
  
  #Define the variable
  lon_var <- ncvar_def(name='lon_simulation',units='None',dim=dimlist)
  lat_var <- ncvar_def(name='lat_simulation',units='None',dim=dimlist)
  index_var <- ncvar_def(name='index_simulation',units='None',dim=dimlist)
  number_people_var <- ncvar_def(name='number_people_simulation',units='None',dim=dimlist)
  varlist=list(lon_var,lat_var,index_var,number_people_var)
  
  
  #Open the netcdf file
  simulation_nc <- nc_create('simulation_r.nc',vars=varlist,force_v4 = TRUE)
  
  #Put the data into the netcdf file
  
  ncvar_put(simulation_nc, lon_var, lon_output)
  ncvar_put(simulation_nc, lat_var, lat_output)
  ncvar_put(simulation_nc, index_var, index_output)
  ncvar_put(simulation_nc, number_people_var, number_people_output)
  
  #Close the netcdf object so that the user can open the downloaded file.
  nc_close(simulation_nc)
  
  #Remote the temporary file made by the python code
  file.remove(file_intermediate)
}

#Example function call
window_start <- 55 #ONDJFM
window_end <- 18+72

lonmin <- 34 # ~Kenya
lonmax <- 42
latmin <- -4
latmax <- 4

year_length <- 72 #Do not change. This is the number of pentads in a year.
year_start <- 1983 #Do not change. This is the start year for the CHIRPS data
year_end <- 2019 #Do not change. This is the end year for the CHIRPS data

file_full <- '/Users/emily/eggbox/new_documents/maxinfo_consult/work/chirps_east_africa.nc'

user_season_flag <- 1 #We have decided to have user defined rainy seasons and so this is always set to 1

number_localities <- 50 #Number of localities at which the insured farmers live
number_insured <- 1000 #Number of insured farmers
nosims <- 10 #Number of simulations (each simulation is a full time series)

#index_type='dry_spell' #Options are seasonal_total or dry_spell
index_type <- 'seasonal_total' #Options are seasonal_total or dry_spell

if (index_type == 'seasonal_total') {
  threshold <- 80 #Threshold (%climatology) at which we will get a pay out for the seasonal anomaly index or for which a season is considered dry
}

if (index_type == 'dry_spell') {
  threshold <- 80 #Threshold (%climatology) for which a pentad is considered dry for the dry spell pay out
  dryspell_length_threshold <- 3 #Number of consecutive pentads < dryspell_threshold that would be considered a dry spell
  no_dryspells_threshold <- 6 #Number of pentads within dry spells at which we will get a pay out. See above for dry spell definition.
}


sample_metric_seasonal_total_index(number_localities, number_insured, threshold, nosims, window_start,window_end,lonmin,lonmax,latmin,latmax,file_full,year_length,year_start,year_end)

#Some example code of how we might work with the netcdf data to produce long data format output for the example simulation exhibits
example_year <- 1997
example_simulation <- 3

tmp <- tidync('simulation_r.nc') %>% hyper_filter(year = year == example_year) %>% hyper_filter(simulation = simulation == example_simulation) %>% hyper_array()
example_index <- tmp$index_simulation
example_lons <- tmp$lon_simulation
exmaple_lats <- tmp$lat_simulation
