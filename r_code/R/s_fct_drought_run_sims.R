run_drought_simulation_script <- function(hazard_data,
                                          exposure_data,
                                          vulnerability_data,
                                          sims_n,
                                          pentad_mappings){
  
  tictoc::tic()
  #Necessary hazard module values for sims
  region <- hazard_data$selected_hazard_mappings()[["region_code"]]
  display_type <- 
    split_string(hazard_data$selected_hazard_mappings()[["display_type"]])
  progress_bar$set(message = "Running Simulations", value = 0.04)
  
  #Necessary exposure module values for sims
  expo_coords <- exposure_data$shape_choices$shape_parameters$rect_coords
  number_localities <- exposure_data$value_choices$exposure_value_parameters$policy_count
  expo_value <- exposure_data$value_choices$exposure_value_parameters$total_value
  expo_curr <- exposure_data$value_choices$exposure_value_parameters$curr
  
  #Necessary vulnerability module values for sims  
  vul_curve_type <- vulnerability_data$trigger_choices$curve_type
  intensity_measure <- vulnerability_data$trigger_choices$intensity
  growing_season <- vulnerability_data$trigger_choices$growing_season
  
  dry_days_threshold <- 80
    
  if(intensity_measure == "Number of Dry Spell Days") {
    dry_days_threshold <- vulnerability_data$trigger_choices$dry_days_threshold
    dry_days_qualify <- 
      as.numeric(
        gsub(" Days", "", vulnerability_data$trigger_choices$dry_days_qualify)
      )
  } else {
    # This is a crude placeholder to stop Python script failing
    dry_days_threshold <- 80
  }
  
  vul_table <- vulnerability_data$trigger_payouts()
  
  # Reformatting of module outputs for subsequent calcs
  
  lonmin <- min(expo_coords$lng)
  lonmax <- max(expo_coords$lng)
  latmin <- min(expo_coords$lat)
  latmax <- max(expo_coords$lat)
  
  window_start <- 
    pentad_mappings[match(growing_season[1], pentad_mappings$Date), "Pentad"]
  
  window_end <- 
    pentad_mappings[match(growing_season[2], pentad_mappings$Date), "Pentad"]
  
  vul_table <- tidy_vul_table(vul_table, 
                              vul_intensity = intensity_measure)
  
  value_per_insured <- 
    expo_value / number_localities
  
  # Assumption that one person/policy per locality in order to keep 
  # use-case simple, however code should work for different numbers/randomisation
  number_insured <- number_localities
  
  # Set variables for returning chirps data 
  year_length <- 72
  year_start <- 1983 
  year_end <- 2019 
  
  file_intermediate <- paste0("./data/temp/",
                              runjags::new_unique(),
                              ".nc")
  file_full <- "./data/chirps/chirps_srx"
  file_full <- paste(file_full, 
                     paste0("chirps_", region, ".nc"), 
                     sep = "/")
  
  # Python setup for returning chirps through xarray
  packages <-
    c("dask",
      "h5netcdf",
      "netcdf4",
      "numpy",
      "packaging",
      "pandas",
      "xarray",
      "scipy")

  setup_python_environment(version = "3.9.13", 
                           env_name = "chirps",
                           packages = packages)
  
  progress_bar$set(message = "Running Simulations", value = 0.35)
  
  python_script <- './scripts/python_index_calculation.py'
  reticulate::source_python(python_script)
  
  return_chirps_nc(window_start, window_end, lonmin, lonmax, latmin, latmax,
                   file_full, year_length, year_start, year_end, 
                   dry_days_threshold, file_intermediate)
  
  progress_bar$set(message = "Running Simulations", value = 0.45)
  
  population_flag <- 0
  
  years <- year_start:year_end
  
  chirps_output <- sample_metric_seasonal_total_index(file_intermediate, 
                                                      number_localities, 
                                                      number_insured, 
                                                      threshold, 
                                                      sims_n, 
                                                      population_flag,
                                                      window_start,
                                                      window_end,
                                                      intensity_measure, 
                                                      vul_table, 
                                                      vul_curve_type,
                                                      years,
                                                      value_per_insured,
                                                      dry_days_qualify)
  
  tictoc::toc()
  
  if(is.null(chirps_output)) {
    showModal(
      modalDialog(
        title = "Error Running Simulation",
        "
        No losses generated as all weather index data contains N/A values. Is your 
        exposure polygon purely water?
        "
      )
    )
  } else {
    
    shiny::showNotification( 
      "
      Simulation Complete. Please navigate to the Event and Loss tabs to 
      examine outputs.
      "
    )
    
    return(list(
      data_sim = chirps_output$sim_df,
      growing_season = paste(growing_season[1], "to", growing_season[2]),
      data_sim_year = chirps_output$sim_year_df,
      one_year_hazard = chirps_output$precip_index_oneyear,
      data_individual_sim = chirps_output$sim_year_individual_df,
      year_start = year_start,
      intensity_measure = intensity_measure,
      year_end = year_end,
      peril = "Drought",
      dataset = "CHIRPs",
      curr = expo_curr,
      sim_count = sims_n,
      raster_bbox = chirps_output$raster_bbox,
      value_per_insured = value_per_insured,
      number_localities = number_localities,
      expected_loss_metrics = chirps_output$expected_loss_metrics,
      display_type = display_type
    ))
  }
}
