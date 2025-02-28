setup_python_environment <- function(version, 
                                     env_name, 
                                     packages){
  
  reticulate::install_python(version)
  reticulate::virtualenv_create(env_name, version = version)
  reticulate::use_virtualenv(env_name)
  reticulate::py_install(packages, envname = env_name)  
  
} 


intensity_to_loss_calc <- function(intensity_data, 
                                   vul_table, 
                                   vul_measure, 
                                   vul_curve_type){
  
  vul_table$loss_factor <- 0
  payout <- c(0)
  if(vul_curve_type == "Linear"){
    
    for (i in 2:(nrow(vul_table)-1)){
      
      vul_table$loss_factor[i] <-
        (vul_table$loss[i + 1] - vul_table$loss[i]) /
        (vul_table$intensity[i + 1] - vul_table$intensity[i])
    }
  }
  
  if(vul_measure == "Pressure"|
     vul_measure == "Percentage of Climatology"){
    
    for (i in 1:length(intensity_data)) {
      
      row_select <- 
        sum(vul_table$intensity >= intensity_data[i])
      
      payout[i] <- 
        vul_table$loss[row_select] +
        (intensity_data[i]- vul_table$intensity[row_select]) *
        vul_table$loss_factor[row_select]
    }
    
  }else{
    
    for (i in 1:length(intensity_data)) { 
      
      row_select <- 
        sum(vul_table$intensity <= intensity_data[i])
      
      payout[i] <- 
        vul_table$loss[row_select] +
        (intensity_data[i] - vul_table$intensity[row_select])*
        vul_table$loss_factor[row_select]
    }
  }
  
  return(payout)   
}


pop_sample <- function(flag, 
                       no_localities, 
                       no_insured){
  
  if (flag == 1) {
    
    pop_sample <- 
      sample(1:no_localities, 
             size = no_insured, 
             replace = TRUE) |> 
      vctrs::vec_count() |>
      tidyr::complete(key = 1:no_localities, 
                      fill = list(count = 0)) |>
      dplyr::arrange(key)
    
    no_people <- c(pop_sample$count)
  } else {
    no_people <- rep(round(no_insured / no_localities), 
                     no_localities)
  }
  
  return(no_people)
}

get_insured_metric_for_year <- function(year) {
  start_index <- c(1, 1, which(years == year))
  count_index <- c(-1, -1, 1)
  ncvar_get(precip_index_allyears_nc, "insured_metric", start = start_index, count = count_index)
}

get_precip_index_value <- 
  function(x, y, z){
    precip_index_oneyear[[z]][x,y]
  }

gen_ncdf_output <- function(file, 
                            sims_n, 
                            year_list, 
                            number_localities, 
                            number_insured){
  
  simulation <- seq(1,sims_n)
  year <- year_list
  locality_index <- seq(1,number_localities)
  
  lon_output <- lon_output[, , seq(1, number_localities)]
  lat_output <- lat_output[, , seq(1, number_localities)]
  index_output <- index_output[, , seq(1, number_localities)]
  payout_output <- payout_output[, , seq(1, number_localities)]
  number_people_output <- no_people_output[, , seq(1, number_insured)]
  
  #Remove the existing netcdf output file
  file.remove(file)
  
  simulation_dim <- ncdim_def(name='simulation', units = 'None', vals = simulation)
  year_dim <- ncdim_def(name = 'year', units = 'None', vals = year)
  locality_index_dim <- ncdim_def(name = 'locality_index', units = 'None',vals = locality_index)
  
  dimlist <- list(locality_index_dim, year_dim, simulation_dim)
  
  #Define the variable
  lon_var <- ncvar_def(name = 'lon_simulation', units = 'None', dim = dimlist)
  lat_var <- ncvar_def(name = 'lat_simulation', units = 'None', dim = dimlist)
  index_var <- ncvar_def(name = 'index_simulation', units = 'None', dim = dimlist)
  payout_var <- ncvar_def(name = 'payout_simulation', units = 'None', dim = dimlist)
  number_people_var <- ncvar_def(name = 'number_people_simulation', 
                                 units = 'None', dim = dimlist)
  
  varlist <- list(lon_var, lat_var, index_var, payout_var, number_people_var)
  
  #Open the netcdf file
  simulation_nc <- nc_create('simulation_r.nc',vars = varlist, force_v4 = TRUE)
  
  #Put the data into the netcdf file
  ncvar_put(simulation_nc, lon_var, lon_output)
  ncvar_put(simulation_nc, lat_var, lat_output)
  ncvar_put(simulation_nc, index_var, index_output)
  ncvar_put(simulation_nc, payout_var, payout_output)
  ncvar_put(simulation_nc, number_people_var, number_people_output)
  
  #Close the netcdf object so that the user can open the downloaded file.
  nc_close(simulation_nc)
  
}

sample_metric_seasonal_total_index <- function(file_intermediate, 
                                               number_localities, 
                                               number_insured, 
                                               threshold, 
                                               sims_n, 
                                               population_flag = 0, 
                                               vul_measure, 
                                               vul_table, 
                                               vul_curve_type){
  
  precip_index_allyears_nc <- nc_open(file_intermediate)
  years <- ncvar_get(precip_index_allyears_nc, "year")
  lons <- ncvar_get(precip_index_allyears_nc, "longitude")
  lats <- ncvar_get(precip_index_allyears_nc, "latitude")
  
  year_list <- years #Renaming years to year_list for legacy reasons
  
  #The output will be the index at randomly selected longitude and latitude points. Setting up the arrays for this.
  lon_output <- array(NA, dim = c(sims_n, length(year_list), number_localities))
  lat_output <- array(NA, dim = c(sims_n, length(year_list), number_localities))
  index_output <- array(NA, dim = c(sims_n, length(year_list), number_localities))
  payout_output <- array(NA, dim = c(sims_n, length(year_list), number_localities))
  
  #Originally, the code allowed us to vary the number of people living at each locality.
  #We are not going to use this functionality, but we will keep it in the code in case we want to
  #introduce it later. Population flag is set to 0 so that we have the same number of people in each locality
  
  no_people_output <- array(NA, dim = c(sims_n, length(year_list), number_localities))
  
  #Extract the index for the particular year. Because we are looking at seasonal totals, this has been calculated in the previous step.
  precip_index_oneyear <- 
    lapply(year_list, get_insured_metric_for_year)
  
  for( i in 1:sims_n){
    #Spreading theinsured population over the localities
    no_people_output[i, , ] <-
      t(mapply(
        function(x, y, z) {
          pop_sample(x, y, z)
        },
        x = population_flag,
        y = rep(number_localities, length(year_list)),
        z = rep(number_insured, length(year_list))
      ))
    
    lon_output[i, , ] <- 
      t(mapply(
        function(x,y){
          sample(seq_len(dim(precip_index_oneyear[[x]])[1]),y)
        },
        x = 1:length(year_list),
        y = rep(number_localities,length(year_list))
      ))  
    
    lat_output[i, , ]<- 
      t(mapply(
        function(x,y){
          sample(seq_len(dim(precip_index_oneyear[[x]])[2]),y)
        },
        x = 1:length(year_list),
        y = rep(number_localities,length(year_list))
      ))
    
    
    # Double check this returns right entries
    for(j in 1:length(year_list)){
      index_output[i,j ,] <- 
        mapply(get_precip_index_value,
               lon_output[i,j ,],
               lat_output[i,j ,],
               j) 
    }
    
    payout_output[i, ,] <- 
      apply(index_output[i, ,], 
            MARGIN= c(1, 2), 
            FUN = intensity_to_loss_calc,
            vul_table = vul_table,
            vul_measure = vul_measure,
            vul_curve_type = vul_curve_type) *
      no_people_output[i, , ]
  }
  
  payout_by_year <-
    apply(payout_output, MARGIN = 1, FUN = rowSums, simplify = FALSE)
  
  localities_paid_by_year <-
    apply(payout_output, MARGIN = 1, function(x) rowSums(x > 0), simplify = FALSE)
  
  insured_impacted_output <-
    as.numeric(payout_output > 0) * no_people_output
  
  insured_impacted_by_year <-
    apply(insured_impacted, MARGIN = 1, FUN = rowSums, simplify = FALSE)
  
  sim_year_df <- 
    cbind.data.frame(sim = rep(1:nosims, 
                               each = length(year_list)),
                     year = year_list,
                     payout = unlist(payout_by_year),
                     localities_paid = unlist(localities_paid_by_year),
                     insured_impacted = unlist(insured_impacted_by_year))
  
  gen_ncdf_output("./data/temp/chirps_simulation_output.nc", 
                  sims_n, 
                  year_list, 
                  number_localities, 
                  number_insured)
  
  file.remove(file_intermediate)
  toc()
  return(sim_year_df)
}




