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
