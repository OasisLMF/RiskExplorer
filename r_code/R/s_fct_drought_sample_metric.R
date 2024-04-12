sample_metric_seasonal_total_index <- function(file_intermediate, 
                                               number_localities, 
                                               number_insured, 
                                               threshold, 
                                               sims_n, 
                                               population_flag = 0,
                                               window_start,
                                               window_end,
                                               vul_measure, 
                                               vul_table, 
                                               vul_curve_type,
                                               years,
                                               value_per_insured,
                                               dry_days_qualify) {
  
  precip_index_allyears_nc <- 
    ncdf4::nc_open(
      file_intermediate, 
      return_on_error = TRUE
    )
  
    if(precip_index_allyears_nc$error == TRUE){
      # Test this
      showModal(
        modalDialog(
          title = "Error Running Simulation",
          "
          The area selected contained no points from the CHIRPs dataset. 
          Try returning to the exposure tab and selecting a wider area
          "
        )
      )
      return()
    }
  
  years <- ncdf4::ncvar_get(precip_index_allyears_nc, "year")
  lons <- ncdf4::ncvar_get(precip_index_allyears_nc, "longitude")
  lats <- ncdf4::ncvar_get(precip_index_allyears_nc, "latitude")
  
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
  
  measure_var <-
    ifelse(vul_measure == "Number of Dry Spell Days", 
           "precip_drypentad", 
           "insured_metric")
  
  precip_index_oneyear <- 
    lapply(year_list, 
           get_insured_metric_for_year, 
           years = years, 
           nc_file = precip_index_allyears_nc,
           measure_var = measure_var, 
           window_start = window_start,
           window_end = window_end) |> 
    lapply(as.array)
    
  if(vul_measure == "Number of Dry Spell Days") {
    
    precip_index_oneyear <-
      lapply(precip_index_oneyear,
             function(x)
              apply(x,
                    MARGIN = c(1,2), 
                    FUN = calc_dry_index, 
                    threshold = dry_days_qualify / 5)
      ) |> as.array()
      
  }
  
  
  if(all(is.na(precip_index_oneyear[[1]])) == TRUE){
    return()
  }
  
  valid_locs <-
    which(!is.na(precip_index_oneyear[[1]]), arr.ind = TRUE)
  
  for( i in 1:sims_n){
    #Spreading the insured population over the localities
    
    progress_bar$inc(0.5 / as.numeric(sims_n))
    
    no_people_output[i, , ] <-
      t(mapply(
        function(x, y, z) {
          pop_sample(x, y, z)
        },
        x = population_flag,
        y = rep(number_localities, length(year_list)),
        z = rep(number_insured, length(year_list))
      ))
    
    # lon_output[i, , ] <-
    #   t(mapply(
    #     function(x,y){
    #       sample(seq_len(dim(precip_index_oneyear[[x]])[1]),y, replace = TRUE)
    #     },
    #     x = 1:length(year_list),
    #     y = rep(number_localities,length(year_list))
    #   ))
    
    sample_loc_rows <- sample(1:nrow(valid_locs), 
                              number_localities,
                              replace = TRUE)
    
    sample_locs <- 
      valid_locs[sample_loc_rows, ]
    
    lon_output[i, , ] <- 
      t(
        matrix(
          rep(sample_locs[, 1], length(year_list)), 
          nrow = number_localities, 
          byrow = FALSE )
      )
    
    
    # lat_output[i, , ]<- 
    #   t(mapply(
    #     function(x,y){
    #       sample(seq_len(dim(precip_index_oneyear[[x]])[2]),y, replace = TRUE)
    #     },
    #     x = 1:length(year_list),
    #     y = rep(number_localities,length(year_list))
    #   ))
    
    lat_output[i, , ] <- 
      t(
        matrix(
          rep(sample_locs[, 2], length(year_list)), 
          nrow = number_localities, 
          byrow = FALSE )
      )
    
    # Double check this returns right entries
    for(j in 1:length(year_list)){
      index_output[i, j, ] <- 
        mapply(function(x,y,z){
          precip_index_oneyear[[z]][x, y]
        },
        x = lon_output[i, j, ],
        y = lat_output[i, j, ],
        z = j)
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
    lapply(
      apply(payout_output, 
            MARGIN = 1, 
            FUN = rowSums, 
            simplify = FALSE), 
      function(x)  x * value_per_insured
    )
  
  progress_bar$set(message = "Running Simulations", value = 0.96)
  
  lon_by_locality <-
    apply(lon_output, MARGIN = c(1), list) |> 
    unlist()
  
  lon_by_locality <-
    lons[lon_by_locality]
    
  lat_by_locality <-
    apply(lat_output, MARGIN = c(1), list) |> 
    unlist()
  
  lat_by_locality <-
    lats[lat_by_locality]
  
  payout_by_locality <-
    apply(payout_output, MARGIN = c(1), list) |> 
    unlist()
  
  index_by_locality <-
    apply(index_output, MARGIN = c(1), list) |> 
    unlist()
  
  sim_year_individual_df <-   
    cbind.data.frame(
      Sim = rep(
          1:sims_n, 
          each = length(years)
        ),
      Year = rep(years, times = number_insured * as.numeric(sims_n)),
      Location = rep(
        1:number_insured, 
        each = length(years) * as.numeric(sims_n)
      ),
      Longitude = lon_by_locality,
      Latitude = lat_by_locality,
      Index = index_by_locality,
      Payout = payout_by_locality * value_per_insured,
      `Insured Impacted` = 
        as.numeric(payout_by_locality * value_per_insured > 0)
      )
  
  progress_bar$set(message = "Running Simulations", value = 0.97)
  
  localities_paid_by_year <-
    apply(payout_output, MARGIN = 1, function(x) rowSums(x > 0), simplify = FALSE)
  
  insured_impacted_output <-
    as.numeric(payout_output > 0) * no_people_output
  
  insured_impacted_by_year <-
    apply(insured_impacted_output, MARGIN = 1, FUN = rowSums, simplify = FALSE)
  
  progress_bar$set(message = "Running Simulations", value = 0.98)
  
  sim_year_df <- 
    cbind.data.frame(`Sim` = rep(1:sims_n, 
                                 each = length(year_list)),
                     `Year` = year_list,
                     `Payout` = unlist(payout_by_year),
                     `Localities Paid` = unlist(localities_paid_by_year),
                     `Insured Impacted` = unlist(insured_impacted_by_year))
  
  sim_df <- 
    sim_year_df |> 
    dplyr::group_by(Sim) |> 
    dplyr::summarise(`Average Simulated Payout` = mean(Payout),
                     `Average Simulated Policyholders Paid` = mean(`Localities Paid`),
                     `Average Simulated Insured Impacted` = mean(`Insured Impacted`)) |> 
    dplyr::ungroup()
  
  progress_bar$set(message = "Running Simulations", value = 0.99)
  
  raster_bbox <-
    list(min_lon = min(lons),
         max_lon = max(lons),
         min_lat = min(lats),
         max_lat = max(lats))
  
  expected_loss_metrics <-
    data.frame(
      Measure = c("Mean", "Standard Deviation"),
      `Simulated Payout`= c(
        mean(sim_year_df$Payout),
        sd(sim_year_df$Payout)
      ),
      `Simulated Insured Impacted`= 
        c(
          mean(sim_year_df$`Insured Impacted`),
          sd(sim_year_df$`Insured Impacted`)
        ),
      check.names = FALSE
    )
  
  toc()
  
  return(
    list(
      sim_df = sim_df,
      sim_year_df = sim_year_df,
      sim_year_individual_df = sim_year_individual_df,
      precip_index_oneyear = precip_index_oneyear,
      raster_bbox = raster_bbox,
      expected_loss_metrics = expected_loss_metrics
      )
    )
}
