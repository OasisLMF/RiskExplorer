run_TC_ibtracs_simulation_script <- function(hazard_data,
                                             exposure_data,
                                             vulnerability_data,
                                             vulnerability_mappings,
                                             sims_n) {

  #Necessary hazard module values for sims
  region <- hazard_data$selected_hazard_mappings()[["region_code"]]
  agency_selected <- hazard_data$selected_hazard_mappings()[["agency_selected"]]
  agencies <- hazard_data$selected_hazard_mappings()[["agencies"]]
  
  sims_n <- as.numeric(sims_n)
  
  year_start <-
    ifelse(
      hazard_data$selected_hazard_mappings()[["region_code"]] == "\\NA",
      1948,
      1978
    )
  year_end <- 2022
  n_years <- year_end - year_start + 1

  display_type <-
    split_string(hazard_data$selected_hazard_mappings()[["display_type"]])
  
  file <-
    hazard_data$selected_hazard_mappings()[["file"]]

  #Necessary exposure module values for sims
  expo_coords <- exposure_data$location_choices$ll_vals
  expo_radius <- exposure_data$shape_choices$shape_parameters$radius
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
  
  hazard_data <-
    data.frame(
      data.table::fread(
        paste0("./data/ibtracs/", file), stringsAsFactors = TRUE)
    ) |>
    tidy_ibtracs_data(agency_selected, agencies) |>
    dplyr::filter(
      !is.na(SELECTED_LAT),
      !is.na(SELECTED_LON),
      !is.na(SELECTED_WIND)|!is.na(SELECTED_PRES)
    )

  rmw_param <- 87.6 * 1000
  scaling_factor <- 5

  sample_radius <- expo_radius + rmw_param
  sample_area_radius <- sample_radius * scaling_factor

  sample_centre <-
    as.numeric(
      c(
        expo_coords$vals$lng,
        expo_coords$vals$lat
      )
    )
  
  # Remove any points from hazard data not in the sample area 
  hazard_data <-
    hazard_data[spDistsN1(cbind(hazard_data$SELECTED_LON,
                                hazard_data$SELECTED_LAT),
                          sample_centre, 
                          longlat = TRUE) <
                sample_area_radius / 1000, ]

  progress_bar$set(message = "Running Simulations", value = 0.04)

  if(nrow(hazard_data) ==0 ) {
    showNotification(
    "No losses generated in any simulations so latest results are not displayed.
     Please check your inputs."
    )
    return()
  }

  vars_to_keep <-
    c("SELECTED_LON", "SELECTED_LAT", intensity_var,
      "NAME","SEASON", "SID", "EVENT_LOSS")
  
  # Calculate financial losses for each point on track
  hazard_data <-
    cbind(
      hazard_data,
      EVENT_LOSS =
        intensity_to_loss_calc(
          hazard_data[[intensity_var]],
          vul_table,
          intensity_measure,
          vul_curve_type
        )
    ) |>
    dplyr::select(vars_to_keep)

  if(is.na(hazard_data$EVENT_LOSS[1]) | 
     sum(hazard_data$EVENT_LOSS) == 0) {
    showNotification("No losses generated in any simulations so latest results 
                      are not displayed. Please check your inputs.")
    return()
  }
  
  sim_centroids <-
    gen_sim_centroids_even(expo_coords$vals,
                           maxi_radius = (sample_area_radius - sample_radius),
                           mini_radius = sample_radius,
                           sims_n = sims_n,
                           weighting_function = "exponential",
                           weighting_parameter = 3.2) |>
    tibble::rownames_to_column() |>
    mutate(sim_no = as.numeric(rowname))

  individual_sims <- list()

  sim_coords <- st_coordinates(sim_centroids)
  
  sim_centroids <- 
    as.data.frame(sim_centroids) |> 
    dplyr::select(-geometry) |> 
    dplyr::mutate(lng = sim_coords[,1],
                  lat = sim_coords[,2])

  haz_lls <-
    cbind(hazard_data$SELECTED_LON,
          hazard_data$SELECTED_LAT)

  tictoc::tic()
  
  # Subset events falling within each simulation
  for (i in 1:sims_n) {

    progress_bar$inc(0.852 / sims_n)

    individual_sim <-
      hazard_data[
        spDistsN1(haz_lls,
                  sim_coords[i, ], TRUE) < sample_radius / 1000,
      ]

    if (nrow(individual_sim) != 0) {
      individual_sim$sim_no <- i
    }

    if(is.null(individual_sim) | nrow(individual_sim) == 0) {

      individual_sims[[i]]<-NULL

    }else{

      individual_sims[[i]]<-
        individual_sim |>
        dplyr::group_by(SID) |>
        slice_measure(intensity_var, intensity_measure) |> 
        dplyr::filter(EVENT_LOSS > 0) |> 
        dplyr::ungroup()
    }
  }
  
  individual_sims <-
    data.table::rbindlist(individual_sims)

  individual_sims <-
    individual_sims  |>
    dplyr::left_join(
      sim_centroids[, c("sim_no","weight")],
      by = "sim_no"
    ) |>
    dplyr::mutate(
      FREQ = 1 / (sims_n * n_years)
    ) |>
    dplyr::mutate(
      WEIGHTED_FREQ = FREQ * (weight / mean(sim_centroids$weight))
    )

  # Calculate historic loss and produce tracks with small buffer for 
  # display purposes
  
  history_losses <-
    hazard_data[
      spDistsN1(haz_lls,
                sample_centre, TRUE) < sample_radius / 1000,
    ]

  if(nrow(history_losses) != 0) {
    
    history_losses_buffer <-
      hazard_data[
        spDistsN1(haz_lls,
                  sample_centre, TRUE) < (sample_radius + 15) / 1000,
      ] |>
      dplyr::mutate(Label = paste(NAME, SEASON))

    history_losses <- 
      history_losses |> 
      dplyr::group_by(SID) |> 
      slice_measure(intensity_var, intensity_measure) 
    
  } else {
      
    ISO_TIME <- 0
    SEASON <- 1978
    SID <- 0
    NAME <- 0
    EVENT_LOSS <- 0
    SELECTED_WIND <- 0
    SELECTED_PRES<- 0
    SELECTED_LON <- NA
    SELECTED_LAT <- NA
    
    history_losses <-
      data.frame(ISO_TIME, SEASON, SID, NAME, EVENT_LOSS, SELECTED_WIND,
                 SELECTED_PRES,SELECTED_LON,SELECTED_LAT)
    
    history_losses_buffer <- history_losses
  }
  
  history_losses_by_year <-
    history_losses |>
    dplyr::group_by(SEASON) |>
    dplyr::summarise(ANNUAL_LOSS = min(sum(EVENT_LOSS), expo_value)) |>
    tidyr::complete(SEASON = year_start:year_end,
                     fill = list(ANNUAL_LOSS = 0))

  loss_by_sim_year <-
    individual_sims |>
    dplyr::group_by(sim_no, SEASON) |>
    dplyr::summarise(ANNUAL_LOSS = min(sum(EVENT_LOSS), 1),
                     `EVENT COUNT`=n()) |>
    dplyr::ungroup() |>
    tidyr::complete(sim_no = 1:sims_n,
                    SEASON = year_start:year_end,
                    fill = list(ANNUAL_LOSS = 0, 
                                `EVENT COUNT` = 0)) |>
    dplyr::left_join(sim_centroids[, c("sim_no", "weight")], by = "sim_no")
  
  loss_by_sim <-
    loss_by_sim_year |>
    dplyr::group_by(sim_no) |>
    dplyr::summarise(
      AVERAGE_LOSS = sum(ANNUAL_LOSS) / n_years,
      WEIGHT = max(weight),
      AVERAGE_EVENT_COUNT = sum(`EVENT COUNT`) / n_years
    ) |>
    dplyr::ungroup() |>
    dplyr::arrange(sim_no) |>
    dplyr::mutate(weighted_EL = AVERAGE_LOSS * WEIGHT)
  
  
  colnames(loss_by_sim) <-
    c("sim_no", "average_loss", "weight", "average_event_count", "weighted_EL")
  
  loss_by_sim <-
    cbind(select(sim_centroids, -rowname),
          select(loss_by_sim, -weight, -sim_no))  |> 
    dplyr::rename(`Sim Number` = sim_no,
                  Longitude = lng,
                  Latitude = lat,
                  `Distance to Exposure`= dist,
                   Weight = weight,
                  `Simulation Average Loss` = average_loss,
                  `Weighted EL` = weighted_EL,
                  `Average Event Count` = average_event_count
    ) |>
    dplyr::relocate(`Sim Number`)

  expected_loss_metrics <-
    data.frame(
      Measure = c("Expected Payout", 
                  "Standard Deviation Payout"),
      `Historical Payout` = c(mean(history_losses_by_year$ANNUAL_LOSS),
                        sd(history_losses_by_year$ANNUAL_LOSS)),
      `Unweighted Simulation Payout` = c(mean(loss_by_sim_year$ANNUAL_LOSS),
                                     sd(loss_by_sim_year$ANNUAL_LOSS)),
      `Weighted Simulation Payout` = c(sum(loss_by_sim$`Weighted EL`) /
                                   sum(loss_by_sim$`Weight`),
                                   wtd.var(loss_by_sim_year$ANNUAL_LOSS,
                                            weights = loss_by_sim_year$weight)
                                   ^ 0.5),
      check.names = FALSE
    )

# Check with no rows returned

  rp_stats_data_sims <-
    individual_sims |>
    dplyr::group_by(SEASON, sim_no, weight)

  rp_stats_data_sims <-
    slice_measure(rp_stats_data_sims,
                  intensity_var = intensity_var,
                  intensity_measure = intensity_measure) |> 
    dplyr::ungroup() |>
    dplyr::select(SEASON, sim_no,
                  !!sym(intensity_var), WEIGHTED_FREQ) |>
    dplyr::arrange(desc(!!sym(intensity_var))) |>
    dplyr::mutate(FREQUENCY = 1 / (n_years * sims_n))
  
  rp_stats_data_hist <-
    history_losses |>
    dplyr::group_by(SEASON) |>
    slice_measure(intensity_var, intensity_measure) |>
    dplyr::ungroup() |>
    dplyr::select(SEASON, !!sym(intensity_var)) |>
    dplyr::arrange(!!sym(intensity_var))|>
    dplyr::mutate(FREQUENCY = 1 / (n_years))

  rp_stats_table <-
    data.frame(Category = 1:5,
               `Wind Speed (km)` =
                 c(119.0915, 154.4971, 178.6372, 209.2148, 252.6671),
               `Pressure (Mb)` = c(990, 979, 965, 945, 920),
               check.names = FALSE)

  stats_col <-
    ifelse(intensity_measure == "Wind Speed",
           "Wind Speed (km)",
           "Pressure (Mb)")
  
  historic_frequency <-
    calc_intensity_rp(
      rp_stats_data_hist, 
      rp_stats_table[[stats_col]], 
      "FREQUENCY", 
      intensity_var)
  
  unweighted_frequency <-
    calc_intensity_rp(
      rp_stats_data_sims, 
      rp_stats_table[[stats_col]], 
      "FREQUENCY", 
      intensity_var)
  
  weighted_frequency <-
    calc_intensity_rp(
      rp_stats_data_sims, 
      rp_stats_table[[stats_col]], 
      "WEIGHTED_FREQ", 
      intensity_var)
  
  rp_stats_table <-
    cbind.data.frame(
      rp_stats_table,
      Payout = 
          intensity_to_loss_calc(rp_stats_table[[stats_col]], 
                                vul_table, 
                                intensity_measure, 
                                vul_curve_type),
      `Historical Frequency` = historic_frequency,
      `Historical Return Period Years` =  pmax(1 / historic_frequency),
      `Unweighted Simulated Frequency` = unweighted_frequency,
      `Unweighted Simulated Return Period Years`  =  
        pmax(1 / unweighted_frequency),
      `Weighted Simulated Frequency` = weighted_frequency,
      `Weighted Simulated Return Period Years` =  pmax(1 / weighted_frequency)
    )
  
  colnames(history_losses) <-
    c("Longitude", "Latitude", stats_col, "Storm Name", 
      "Year", "Storm ID", "Payout")
  
  colnames(history_losses_buffer) <-
    c("Longitude", "Latitude", stats_col, "Storm Name", 
      "Year", "Storm ID", "Payout", "Label")
  
  colnames(individual_sims) <-
    c("Longitude", "Latitude", stats_col, "Storm Name", 
      "Year", "Storm ID", "Payout", "Sim No", "Weight",
      "Frequency", "Weighted Frequency")
  
  colnames(loss_by_sim_year) <-  
    c("Sim No","Season", "Payout", "Event Count", "Weight")
  
  shiny::showNotification( 
    "
    Simulation Complete. Please navigate to the Events and Payouts tabs to 
    examine outputs.
    "
  )
  
  return(list(
    data_sim = loss_by_sim,
    data_sim_year = loss_by_sim_year,
    data_individual_sim = individual_sims,
    data_hist = history_losses,
    data_hist_map = history_losses_buffer,
    rp_stats = rp_stats_table,
    year_start = year_start,
    intensity_measure = stats_col,
    year_end = year_end,
    peril = "Windstorm",
    dataset = "IBTrACS",
    curr = expo_curr,
    sim_count = sims_n,
    expo_value = expo_value,
    number_localities = 1,
    expo_ll = sample_centre,
    expo_radius = sample_radius,
    expected_loss_metrics = expected_loss_metrics,
    display_type = display_type
  ))

}
