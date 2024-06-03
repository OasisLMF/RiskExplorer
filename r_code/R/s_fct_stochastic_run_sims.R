run_TC_stochastic_simulation_script <- function(hazard_data,
                                                exposure_data,
                                                vulnerability_data,
                                                vulnerability_mappings,
                                                sims_n){
  
  sims_n <- as.numeric(sims_n)
  region <- hazard_data$selected_hazard_mappings()[["region_code"]]
  peril <- hazard_data$selected_hazard_mappings()[["peril"]]
  
  display_type <-
    split_string(hazard_data$selected_hazard_mappings()[["display_type"]])
  
  file <-
    hazard_data$selected_hazard_mappings()[["file"]]
  
  hazard_files <- 
    paste0("./data/stochastic/", region, "/files/",
      list.files(
            path = 
              paste0("./data/stochastic/", region,"/files/")
       )
    )
  
  max_sims <- hazard_data$selected_hazard_mappings()[["max_year_no"]]
  
  #Necessary exposure module values for sims
  expo_coords <- exposure_data$location_choices$ll_vals
  expo_radius <- exposure_data$shape_choices$shape_parameters$radius / 1000
  expo_value <- exposure_data$value_choices$exposure_value_parameters$total_value
  expo_curr <- exposure_data$value_choices$exposure_value_parameters$curr
  
  #Necessary vulnerability module values for sims
  vul_curve_type <- vulnerability_data$trigger_choices$curve_type
  intensity_measure <- vulnerability_data$trigger_choices$intensity
  intensity_unit <- vulnerability_data$trigger_choices$intensity_unit
  
  intensity_unit_conversion <-
    vulnerability_mappings[
      vulnerability_mappings$unit == intensity_unit,
      "transformation_factor"
    ][1]
  
  intensity_var <-
    vulnerability_mappings[
      vulnerability_mappings$measure == intensity_measure,
      "ibtracs_name"
    ][1]
  
  vul_table <- vulnerability_data$trigger_payouts()
  
  vul_table <-
    tidy_vul_table(vul_table, vul_intensity = intensity_measure) |>
    dplyr::mutate(intensity = intensity * intensity_unit_conversion)
  
  hazard_model_data <- lapply(hazard_files, fread, stringsAsFactors = TRUE)
  
  areaperil_dict <- as.data.frame(hazard_model_data[1])
  
  expo_centre <-
    as.numeric(
      c(
        expo_coords$vals$lng,
        expo_coords$vals$lat
      )
    )
  
  if(expo_radius == 0) {
    
    areaperil_dict <- 
      areaperil_dict[
        which.min(
          spDistsN1(
            cbind(areaperil_dict$lon1, areaperil_dict$lat1),
            cbind(expo_centre[1], expo_centre[2]),
            longlat = TRUE
          )
        )
      , ]
    
  } else {
    
    areaperil_dict <- 
      areaperil_dict[
        spDistsN1(
          cbind(areaperil_dict$lon1, areaperil_dict$lat1), 
          cbind(expo_centre[1], expo_centre[2]),
          longlat = TRUE) < 
          expo_radius, ]
    
  }
  
  intensity <- hazard_model_data[[2]]
  occurrence <- hazard_model_data[[3]]
  location <- c(expo_centre, expo_radius)
  
  areaperil_ids <- as.vector(areaperil_dict$areaperil_id)
  
  footprint <- 
    readr::read_csv_chunked(
      paste0("./data/stochastic/", region, "/footprint/footprint.csv"),
      callback = DataFrameCallback$new(function(x, pos) 
        subset(x, areaperil_id %in% areaperil_ids))
      )
  
  sim_periods <- 
    data.frame(
      sim_no = as.factor(c(1:sims_n)), 
      period_no = sample(1:max_sims, sims_n, replace = TRUE)
    )
  
  sim_events <- 
    dplyr::left_join(sim_periods, occurrence, by = "period_no") |> 
    dplyr::inner_join(footprint, by = "event_id") |> 
    dplyr::left_join(intensity, by = c("intensity_bin_id" = "bin_index")) |> 
    dplyr::left_join(areaperil_dict, by = "areaperil_id")
  
  sim_events <- cbind(sim_events, random_var = runif(n = nrow(sim_events)))
  
  # Pick up from here
  sim_events <-
    sim_events  |> 
    dplyr::mutate(
      !!dplyr::sym(intensity_measure) := 
        bin_from + (bin_to - bin_from) * random_var
    ) |> 
    dplyr::group_by(event_id,sim_no) |> 
    dplyr::slice_max(!!dplyr::sym(intensity_measure), with_ties = FALSE) |> 
    dplyr::ungroup() |> 
    dplyr::select(
      lon1, lat1, !!dplyr::sym(intensity_measure), event_id, sim_no
    )
  
  individual_sims <-
    sim_events |>
      dplyr::mutate(
        event_loss = 
          intensity_to_loss_calc(
            sim_events[[intensity_measure]],
            vul_table,
            intensity_measure,
            vul_curve_type
          )
      ) |> 
      dplyr::filter(event_loss > 0) |> 
      dplyr::filter(event_loss > 0) |> 
        dplyr::rename(
          Longitude = lon1,
          Latitude = lat1,
         `Event ID`= event_id,
          Payout = event_loss,
         `Sim No` = sim_no
        )
  
  individual_sims <-
    individual_sims |> 
    dplyr::mutate(Frequency = 1 / sims_n)
  
  loss_by_sim_year <- 
    individual_sims |> 
    dplyr::group_by(`Sim No`) |> 
    dplyr::summarise(
      Payout = sum(Payout),
      `Event Count` = n()
    ) |> 
    dplyr::ungroup() |> 
    dplyr::mutate(
      Payout = pmin(Payout, 1)
    ) |> 
    tidyr::complete(
      `Sim No`,
      fill = 
        list(
          Payout = 0, 
          `Event Count` = 0
          )
      )
  
  stats_col <-
    ifelse(intensity_measure == "Wind Speed",
           "Wind Speed (km)", "Peak Ground Acceleration (%g)")
  
  category_col <-
    ifelse(intensity_measure == "Wind Speed",
           "Category",
           "Modified Mercalli Intensity")
           
  rp_stats_table <-
    data.frame(Category = 1:5,
               `Modified Mercalli Intensity` = 6:10,
               `Wind Speed (km)` =
                 c(119, 154, 178, 209, 252),
               `Peak Ground Acceleration (%g)` = c(11.5, 21.5, 40.1, 74.7, 139),
               check.names = FALSE) |> 
    dplyr::select(
      !!!dplyr::syms(c(stats_col, category_col))
    )
    
  simulated_frequency <-
    calc_intensity_rp(
      individual_sims, 
      rp_stats_table[[stats_col]], 
      "Frequency", 
      intensity_measure)
    
  # Here, check this line
    rp_stats_table <-
      cbind.data.frame(
        rp_stats_table,
        Payout = 
          intensity_to_loss_calc(rp_stats_table[[stats_col]], 
                                 vul_table, 
                                 intensity_measure, 
                                 vul_curve_type),
        `Simulated Frequency` = simulated_frequency,
        `Simulated Return Period Years` =  pmax(1 / simulated_frequency)
      )
    
    expected_loss_metrics <-
      data.frame(
        Measure = c("Expected Payout", 
                    "Standard Deviation Payout"),
        `Simulated Payout` = c(mean(loss_by_sim_year$Payout),
                                sd(loss_by_sim_year$Payout)),
        check.names = FALSE
      )
    
    shiny::showNotification( 
      "
      Simulation Complete. Please navigate to the Events and Payouts tabs to 
      examine outputs.
      "
    )
    
    return(
      list(
        data_individual_sim = individual_sims,
        data_sim_year = loss_by_sim_year,
        rp_stats = rp_stats_table,
        intensity_measure = stats_col,
        peril = peril,
        dataset = "Stochastic",
        curr = expo_curr,
        sim_count = sims_n,
        expo_value = expo_value,
        number_localities = 1,
        expo_ll = expo_centre,
        expo_radius = expo_radius,
        expected_loss_metrics = expected_loss_metrics,
        display_type = display_type
      )
    )

}
