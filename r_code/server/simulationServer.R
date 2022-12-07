
observeEvent(input$s_nextpage, {
  updateTabsetPanel(session, "tabset",
                    selected = "analysis")
})

observeEvent(input$s_prevpage, {
  updateTabsetPanel(session, "tabset",
                    selected = "vulnerability")
})

# 0 Functions required for simulations

# Converts degrees to radians
convert_rad_deg <- function(value, conversion_measure) {
  if (conversion_measure == "rad") {
    value * pi/180
  } else {
    value * 180/pi
  }
}

exit <- function() { invokeRestart("abort") }

# This function generates centroids of simulation mini-circles given
# a number of sims to run and a mini and maxi circle size. Mini
# circle size is needed to ensure no points are chosen on the edge of
# the maxi-circle where the mini-circle's radius might exceed the
# maxi-circle and include points that exceed 5x RMW in the
# calculations.

gen_sim_centroids <- function(exposure_point, maxi_radius, mini_radius,
                              sims_n, weighting_function, weighting_parameter = 3.2) {

  set.seed(0)
  
  lat_rad <- convert_rad_deg(exposure_point[2], "rad")
  lng_rad <- convert_rad_deg(exposure_point[1], "rad")
  
  # Define special quantities needed for min/max bounding box
  # calculations
  R <- 6378.137
  r <- (maxi_radius - mini_radius)/R
  lat_T <- asin(sin(lat_rad)/cos(r))
  delta_lng <- asin(sin(r)/cos(lat_rad))
  
  
  # Define min/max lat-longs for sampling
  maxlat <- convert_rad_deg(lat_rad + r, "deg")
  minlat <- convert_rad_deg(lat_rad - r, "deg")
  
  maxlng <- convert_rad_deg(lng_rad + delta_lng, "deg")
  minlng <- convert_rad_deg(lng_rad - delta_lng, "deg")
  
  
  # Simulate points from square and throw out values that sit
  # outside circle
  point_sims <- data.frame(lng = 0, lat = 0, dist = 0, weight = 0)
  i <- 1
  
  while (i <= sims_n) {
    
    lat_s <- runif(1, min = minlat, max = maxlat)
    lng_s <- runif(1, min = minlng, max = maxlng)
    distance <- spDistsN1(cbind(lng_s, lat_s), as.numeric(exposure_point),
                          longlat = TRUE)
    
    if (distance < (maxi_radius - mini_radius)) {
      
      point_sims[i, ] <- c(lng_s, lat_s, distance, ifelse(weighting_function ==
                                                            "linear", (1 - distance/maxi_radius), exp(-weighting_parameter *
                                                                                                        distance/maxi_radius)))
      i <- i + 1
      
    }
  }
  # toc()
  return(point_sims)
  
}

s_output_values <<- reactiveValues(el = NULL, sims_by_loc = NULL, sims_by_datayear = NULL,
                                   intensity_info = NULL, historic = NULL, historic_all = NULL, historical_summary = NULL, 
                                   sims_n = NULL, yearly_loss_info=NULL,sim_summary=NULL,areaperil=NULL)
s_sim_ok<<-FALSE
s_sim_ok_ibtracs<<-FALSE

#Observe doesnt seem to get triggered when it should be doing so?

observeEvent(input$s_simulation_run, {
  
  if(s_exposure_ok!=TRUE|s_hazard_ok!=TRUE|s_vulnerability_ok!=TRUE){
    
    showNotification("Your inputs are incomplete, please revisit the earlier tabs")
    
   }else{
        
    
    # Set up timer and progress bar
    tic(msg = "Total simulation script run-time")
    gc()
    s_progress <- shiny::Progress$new()
    on.exit(s_progress$close())
    s_progress$set(message = "Running Simulations", value = 0)
    
    rm(list=c("s_historical_losses_all","s_event_loss","s_sims_data", "s_loc_sims","s_sim_results_by_loc","s_sim_results_by_datayear",
              "s_sim_events","h_footprint","s_sim_periods"))
    
    # 1.Define necessary parameters NOTE get rid of sims_n term. Can
    # do all calcs based off the reactive values.
    
    tic(msg = "Filtering data and populating intensity measure")
    
    #Sim count
    s_sims_n <<- as.numeric(input$s_sims_n)
    s_output_values$sims_n <<- as.numeric(input$s_sims_n)
    
    # Vulnerability - trigger and max insured
    s_max_ins <<- as.numeric(input$v_max_insured)
    s_intensity_measure <<- v_intensity_mappings[v_intensity_mappings$measure ==
                                              input$v_intensity, "measure"][1]
    s_intensity_measure_unit <- v_intensity_mappings[v_intensity_mappings$unit ==
                                                   input$v_intensity_unit, "unit"]
    s_intensity_transformation_factor <- v_intensity_mappings[v_intensity_mappings$unit ==
                                                            input$v_intensity_unit, "transformation_factor"]
    s_intensity_ibtracs_name <<- v_intensity_mappings[v_intensity_mappings$unit ==
                                                   input$v_intensity_unit, "ibtracs_name"]
    s_curve_type<<-input$v_curve_type
    
    # Vulnerability - structure and reinstatements
    s_vulnerability <- v_updated_structure_tbl$data%>%filter(Intensity!=""|Damage_Percentage!="")
    
    if(nrow(s_vulnerability)>1){
      s_vulnerability<-sapply(s_vulnerability,as.numeric)%>%as.data.frame()  
    }else{
      s_vulnerability<-data.frame(Intensity=as.numeric(s_vulnerability[1]),Damage_Percentage=as.numeric(s_vulnerability[2]))
    }
    
    s_vulnerability<-rbind(if(s_intensity_measure=="Pressure"){
      c(999999,0,0)
      }else{
        c(0, 0,0)}, 
      s_vulnerability) %>%
      dplyr::rename(intensity = Intensity, loss = Damage_Percentage) %>%
      drop_na()
    
    s_reinstatements <-0
    s_max_recovery <- 1 + s_reinstatements
    s_event_loss <- c(0)
    s_vulnerability$intensity <- s_vulnerability$intensity/ifelse(s_intensity_measure_unit ==
                                                                "mph", s_intensity_transformation_factor, 1)
    
    # Exposure and define sampling circles
    s_exposure_point <<- c(e_selected_ll_rv$vals$lng[1], e_selected_ll_rv$vals$lat[1])
    s_exposure_radius <<- input$e_shape_p1
    s_curr<<-input$v_curr
    #Hazard Validation
    
    if(grepl(s_intensity_measure,h_mappings_selected$suggested_measure[1])==FALSE){
      showModal(modalDialog(title = "Warning",
                          "Intensity Measure selection not appropriate for hazard data. Please revisit 
                           vulnerability tab."))
          return()
        }
    
    if(grepl("IBTrACS",h_display_text)==TRUE){
      
      s_mini_radius <<- 87.6 + s_exposure_radius/ifelse(input$e_shape_units ==
                                                          "miles", s_intensity_transformation_factor, 1)
      s_maxi_radius <<- s_mini_radius * 5  
      
      # Hazard
      s_sims_data <- h_data %>%
          filter(!is.na(!!sym(s_intensity_ibtracs_name)))%>%
          ungroup()
      s_earliest_datayear <- min(s_sims_data$SEASON)
      s_latest_datayear <- max(s_sims_data$SEASON)
      s_n_data_years <- s_latest_datayear - s_earliest_datayear + 1
      
      
      # 2.Filter hazard data that is within maxi_circle bounds
      
      
      s_sims_data <- s_sims_data[spDistsN1(cbind(s_sims_data$SELECTED_LON,
                                                 s_sims_data$SELECTED_LAT), as.numeric(s_exposure_point), longlat = TRUE) <
                                   s_maxi_radius, ]
      
      if(nrow(s_sims_data)==0){
        showNotification("No losses generated in any simulations so latest results are not displayed. 
                         Please check your inputs.")
        return()
      }
      
      # 3. Populate loss column and filter out points that have no
      # impact on loss
      
      
      s_vulnerability$loss_factor<-0
      
      if(s_curve_type=="Linear"){
        
        for (i in 2:(nrow(s_vulnerability)-1)){
          
          s_vulnerability$loss_factor[i]<-(s_vulnerability$loss[i+1]-s_vulnerability$loss[i])/
            (s_vulnerability$intensity[i+1]-s_vulnerability$intensity[i])
        }
        
      }
      
      if(s_intensity_measure=="Pressure"){
        for (i in 1:nrow(s_sims_data)) {
          
          row_select<-nrow(s_vulnerability[s_vulnerability[["intensity"]] >=
                                             s_sims_data[[s_intensity_ibtracs_name]][[i]],])
          
          s_event_loss[i] <- s_vulnerability[["loss"]][row_select] +
            (s_sims_data[[s_intensity_ibtracs_name]][[i]] - s_vulnerability[["intensity"]][row_select])*
            s_vulnerability[["loss_factor"]][row_select]
        }
      }else{
        for (i in 1:nrow(s_sims_data)) { 
         
          row_select<-nrow(s_vulnerability[s_vulnerability[["intensity"]] <=
                                                   s_sims_data[[s_intensity_ibtracs_name]][[i]],])
          
          s_event_loss[i] <- s_vulnerability[["loss"]][row_select] +
                                 (s_sims_data[[s_intensity_ibtracs_name]][[i]] - s_vulnerability[["intensity"]][row_select])*
                                  s_vulnerability[["loss_factor"]][row_select]

          
        }
      }
      
      # This filters on SS Cat 1 wind speed rather than events above 
      # trigger as we need non-triggering events for the trigger stats 
      # exhibit.
      
      if(is.na(s_event_loss)|sum(s_event_loss)==0){
        showNotification("No losses generated in any simulations so latest results are not displayed. 
                         Please check your inputs.")
        return()
       }
    
    
    if(s_intensity_measure=="Pressure"){
      s_sims_data <- cbind(s_sims_data, EVENT_LOSS = s_event_loss) %>%
        filter(!!sym(s_intensity_ibtracs_name)<= max(max(s_vulnerability$intensity[s_vulnerability$loss>0|s_vulnerability$loss_factor!=0]),990))
    }else{
      s_sims_data <- cbind(s_sims_data, EVENT_LOSS = s_event_loss) %>%
        filter(!!sym(s_intensity_ibtracs_name)>= min(min(s_vulnerability$intensity[s_vulnerability$loss>0|s_vulnerability$loss_factor!=0]),119))
      }
      
      toc()
      
      # 4. Function randomly samples from approximate bounds of square. 
      # then throws out observations that don't lie within maxi-circle
      
      s_loc_sims <- gen_sim_centroids(s_exposure_point, s_maxi_radius,
                                        s_mini_radius, s_sims_n, "exponential", 3.2) %>%
        tibble::rownames_to_column() %>%
        mutate(rowname = as.numeric(rowname))
      
      s_mean_weight<-mean(s_loc_sims$weight)
      tic(msg = "Check whether points are in mini-circles and generate simulation output")
      
      s_progress$set(message = "Running Simulations", value = 0.02)
      
      # 5. Store data-points falling inside mini-circles
      
      # s_individual_sim_results <- data.frame(MEASURE = NULL, SEASON = NULL,
      #                                        SID = NULL, TRIGGER_PAYOUT = NULL)
      # 
      
      sims_results_list<-list()
      
      
      for (i in 1:s_sims_n) {
        
        s_progress$inc(0.852/s_sims_n)
        
        s_individual_sim<-s_sims_data[spDistsN1(cbind(s_sims_data$SELECTED_LON, s_sims_data$SELECTED_LAT),
                                as.numeric(s_loc_sims[i, c("lng", "lat")]), TRUE) < s_mini_radius,
                      c("SELECTED_LON","SELECTED_LAT",s_intensity_ibtracs_name,
                        "NAME","SEASON", "SID", "EVENT_LOSS")]
        
        if (nrow(s_individual_sim) != 0) {
          s_individual_sim$i<-i  
          
        } 
        
        if(is.null(s_individual_sim)|nrow(s_individual_sim)==0){
            sims_results_list[[i]]<-NULL
          }else{
            sims_results_list[[i]]<-group_by(s_individual_sim,SID)%>%slice_max(order_by = !!sym(s_intensity_ibtracs_name), 
                                                              with_ties = FALSE)
          }
      }
    
      gc()
      
      s_individual_sim_results<-rbindlist(sims_results_list)
      rm(sims_results_list)
      
      
      s_individual_sim_results<-s_individual_sim_results%>%mutate(i = factor(i, levels = 1:s_sims_n), SEASON = factor(SEASON,
                                                                                  levels = s_earliest_datayear:s_latest_datayear)) 
        
      s_loc_sims <- s_loc_sims %>%
        mutate(rowname = as.factor(rowname))
      
      toc()
      
      # 6. Pull in only max reading in a mini-circle to avoid
      # double-counting SIDs
      
      tic(msg = "Check maxes by SID/sim")
        
      if(sum(s_individual_sim_results$EVENT_LOSS)==0){
        showNotification("No losses generated in any simulations so latest results are not displayed. 
                         Please check your inputs.")
        return()
      }
      
      #Test this!
      
      
      
      
      s_progress$set(value = 0.94)
      
      # 7. Generate by datayear sim output
      
      s_sim_results_by_datayear <- s_individual_sim_results %>%
        group_by(i, SEASON) %>%
        summarise(ANNUAL_LOSS = sum(EVENT_LOSS), 
                  ANNUAL_LOSS_CAPPED = min(sum(EVENT_LOSS), s_max_recovery),
                 `EVENT COUNT`=n()) %>%
        ungroup() %>%
        complete(i, SEASON, fill = list(ANNUAL_LOSS = 0, ANNUAL_LOSS_CAPPED = 0)) %>%
        left_join(s_loc_sims[, c("rowname", "weight")], by = c(i = "rowname"))
      
      s_sim_results_by_datayear$`EVENT COUNT`<-s_sim_results_by_datayear$`EVENT COUNT`%>%replace_na(0)  
      
      toc()
      s_progress$set(value = 0.99)
      
      # 8. Generate by sim simulation output
      
      tic("Calculate metrics and generate necessary data for outputs")
      
      s_sim_results_by_loc <- s_sim_results_by_datayear %>%
        group_by(i) %>%
        summarise(AVERAGE_LOSS_CAPPED = sum(ANNUAL_LOSS_CAPPED)/s_n_data_years,
                  AVERAGE_LOSS = sum(ANNUAL_LOSS)/s_n_data_years, WEIGHT = max(weight),
                  AVERAGE_EVENT_COUNT=sum(`EVENT COUNT`)/s_n_data_years)
      
      
      s_sim_results_by_loc <- s_sim_results_by_loc %>%
        dplyr::arrange(i) %>%
        mutate(weighted_EL = AVERAGE_LOSS_CAPPED * WEIGHT)
      
      colnames(s_sim_results_by_loc) <- c("sim_no", "average_loss_capped",
                                          "average_loss", "weight","average_event_count","weighted_EL")
      
      s_individual_sim_results<-merge(s_individual_sim_results,s_sim_results_by_loc[,c("sim_no","weight")],
            by.x="i",by.y="sim_no") %>% mutate(WEIGHTED_FREQ=weight/s_mean_weight)
      
      # 9. Calculate overall expected losses and other exhibits
      
      s_include_sim <- spDistsN1(cbind(s_sims_data$SELECTED_LON, s_sims_data$SELECTED_LAT),
                                 s_exposure_point, TRUE) < s_mini_radius
      
      if (sum(s_include_sim) != 0) {
        
        s_historical_losses_mapped <- s_sims_data[spDistsN1(cbind(s_sims_data$SELECTED_LON,
                                                                  s_sims_data$SELECTED_LAT), s_exposure_point, TRUE) < 
                                                                 (s_mini_radius +15), ]%>%
          mutate(LABEL=paste(NAME,SEASON))
        
        s_historical_losses_all <- s_sims_data[spDistsN1(cbind(s_sims_data$SELECTED_LON,
                                                               s_sims_data$SELECTED_LAT), s_exposure_point, TRUE) <
                                                               s_mini_radius,]%>%
          group_by(SID)
          
        if(s_intensity_measure=="Pressure"){
          s_historical_losses <- s_historical_losses_all %>%
            slice_min(!!sym(paste0(s_intensity_ibtracs_name)), with_ties = FALSE)
        }else{
          s_historical_losses <- s_historical_losses_all %>%
            slice_max(!!sym(paste0(s_intensity_ibtracs_name)), with_ties = FALSE)
        }
      } else {
        ISO_TIME <- 0
        SEASON <- 0
        SID <- 0
        NAME <- 0
        EVENT_LOSS <- 0
        SELECTED_WIND <- 0
        SELECTED_PRES<-0
        SELECTED_LON <- NA
        SELECTED_LAT <- NA
        
        s_historical_losses <- data.frame(ISO_TIME, SEASON, SID, NAME,EVENT_LOSS, SELECTED_WIND,
                                          SELECTED_PRES,SELECTED_LON,SELECTED_LAT)
        
        s_historical_losses_mapped <- s_historical_losses
      }
      
      s_historical_losses_by_datayear <- s_historical_losses %>%
        group_by(SEASON) %>%
        summarise(ANNUAL_LOSS = sum(EVENT_LOSS), ANNUAL_LOSS_CAPPED = min(sum(EVENT_LOSS),
                                                                                    s_max_recovery))
      
      s_output_values$el <- data.frame(Measure = c("Expected Loss", "Standard Deviation"),
                                       Historical_Loss = c(sum(s_historical_losses_by_datayear$ANNUAL_LOSS_CAPPED)/s_n_data_years,
                                                           sd(c(s_historical_losses_by_datayear$ANNUAL_LOSS_CAPPED,
                                                                rep(0, s_n_data_years - nrow(s_historical_losses_by_datayear))))),
                                       Unweighted_Simulation_Loss = c(mean(s_sim_results_by_loc$average_loss_capped),
                                                                      sd(c(s_sim_results_by_datayear$ANNUAL_LOSS_CAPPED,
                                                                           rep(0, s_n_data_years * s_sims_n - nrow(s_sim_results_by_datayear))))),
                                       Weighted_Simulation_Loss = c(sum(s_sim_results_by_loc$weighted_EL)/sum(s_sim_results_by_loc$weight),
                                                                    wtd.var(s_sim_results_by_datayear$ANNUAL_LOSS_CAPPED,
                                                                            weights = s_sim_results_by_datayear$weight)^0.5))
      
      s_output_values$sims_by_datayear <- s_sim_results_by_datayear %>%
        dplyr::rename(sim_no = i, season = SEASON, annual_loss = ANNUAL_LOSS,
                      annual_loss_capped = ANNUAL_LOSS_CAPPED)
      
      s_output_values$sims_by_loc <- cbind(select(s_loc_sims, -rowname),
                                           select(s_sim_results_by_loc, -weight)) %>%
                                     dplyr::rename(`SIM NUMBER`=sim_no,
                                                     LONGITUDE=lng,LATITUDE=lat,
                                                   `DISTANCE TO EXPOSURE`=dist,WEIGHT=weight,
                                                   `SIMULATION AVERAGE LOSS UNCAPPED`=average_loss,
                                                   `SIMULATION AVERAGE LOSS`=average_loss_capped,
                                                   `WEIGHTED EL`=weighted_EL,
                                                   `AVERAGE EVENT COUNT`=average_event_count
                                                   )%>%
                                     dplyr::relocate(`SIM NUMBER`)
      
      s_output_values$historic <- s_historical_losses
      s_output_values$historic_all <- s_historical_losses_mapped
      
      
      s_intensity_stats <- data.frame(category = 1:5, wind_speed_km = 
                                      c(119.0915,154.4971, 178.6372, 209.2148, 252.6671), 
                                      pressure_mb=c(990,979,965,945,920),
                                      event_loss = 0, historical_frequency = 0,
                                      historical_rp = 0, unweighted_frequency = 0,
                                      unweighted_rp = 0, weighted_frequency = 0,
                                      weighted_rp = 0)
        
      if(s_intensity_measure=="Pressure"){
        
        for (i in 1:nrow(s_intensity_stats)) {
          
          s_intensity_stats$event_loss[i] <- max(s_vulnerability$loss[s_vulnerability$intensity >=
                                                                            s_intensity_stats$pressure_mb[i]])
          s_intensity_stats$historical_frequency[i] <- sum(s_historical_losses$SELECTED_PRES <=
                                                           c(s_intensity_stats$pressure_mb[i]))/s_n_data_years
          s_intensity_stats$unweighted_frequency[i] <- sum(s_individual_sim_results$SELECTED_PRES <=
                                                           c(s_intensity_stats$pressure_mb[i]))/(s_sims_n * s_n_data_years)
          
          ex_3_temp_v <- s_individual_sim_results$SELECTED_PRES <= c(s_intensity_stats$pressure_mb[i])
          
          s_intensity_stats$weighted_frequency[i] <- sum(s_individual_sim_results[ex_3_temp_v,"WEIGHTED_FREQ"])/(s_sims_n * s_n_data_years)    
        }
        
        s_output_values$intensity_info <- s_intensity_stats %>%select(-wind_speed_km)%>%
          mutate(historical_rp = pmax(1/historical_frequency,1), unweighted_rp = pmax(1/unweighted_frequency,1),
                 weighted_rp = pmax(1/weighted_frequency,1))
      }else{
        
        for (i in 1:nrow(s_intensity_stats)) {
          
          s_intensity_stats$event_loss[i] <- max(s_vulnerability$loss[s_vulnerability$intensity <=
                                                                            s_intensity_stats$wind_speed_km[i]])
          s_intensity_stats$historical_frequency[i] <- sum(s_historical_losses$SELECTED_WIND >=
                                                           c(s_intensity_stats$wind_speed_km[i]))/s_n_data_years
          s_intensity_stats$unweighted_frequency[i] <- sum(s_individual_sim_results$SELECTED_WIND >=
                                                           c(s_intensity_stats$wind_speed_km[i]))/(s_sims_n * s_n_data_years)
  
          ##TEST HERE
          ex_3_temp_v<-s_individual_sim_results$SELECTED_WIND >=c(s_intensity_stats$wind_speed_km[i])
          
          s_intensity_stats$weighted_frequency[i] <- sum(s_individual_sim_results[ex_3_temp_v,"WEIGHTED_FREQ"])/(s_sims_n * s_n_data_years)
          
        }
        
        s_output_values$intensity_info <- s_intensity_stats %>%select(-pressure_mb)%>%
          mutate(historical_rp = pmax(1/historical_frequency,1), unweighted_rp = pmax(1/unweighted_frequency,1),
                 weighted_rp = pmax(1/weighted_frequency,1))
      }
      
      is.na(s_output_values$intensity_info) <-sapply(s_output_values$intensity_info,is.infinite)
      
      s_output_values$sim_summary<-s_individual_sim_results%>%
        ungroup()%>%
        select(i,SID,SEASON,NAME,SELECTED_LAT,SELECTED_LON,!!sym(s_intensity_ibtracs_name),EVENT_LOSS)
  
      rm(s_individual_sim_results)
      
      s_output_values$historical_summary<-data.frame(`START YEAR`=s_earliest_datayear,`END YEAR`=s_latest_datayear, 
                                                     `NUMBER OF YEARS`=as.character(s_n_data_years), `HISTORICAL LOSS`=s_output_values$el$Historical_Loss[1],
                                                     check.names=FALSE)
      
      if(s_curve_type=="Step"){
      s_output_values$yearly_loss_info<-s_sim_results_by_datayear%>%
        mutate(`Yearly Loss`=round(ANNUAL_LOSS_CAPPED,9))%>%
        group_by(`Yearly Loss`)%>%
        summarise(`Number of Simulation Years`=n(),
                  `Average Weight`=mean(weight), `Percentage of Simulation Years`=n()/(s_n_data_years*s_sims_n))%>%
        mutate(`Percentile`=cumsum(`Percentage of Simulation Years`))
      }else{
      
      s_losses<-c(pull(s_vulnerability%>%filter(loss>0|loss_factor!=0)%>%select(loss)))
      s_labels_percent<<-character(0)
      s_labels_curr<<-character(0)
      for (i in 1:(length(s_losses)-1)){
        s_labels_percent[i]<<-paste0(scales::percent(s_losses[i]),"-",scales::percent(s_losses[i+1]))
        s_labels_curr[i]<<-paste0(scales::dollar(s_losses[i]*s_max_ins,prefix=input$v_curr),"-",scales::dollar(s_losses[i+1]*s_max_ins,prefix=input$v_curr))
      }
      s_labels_curr<<-c(scales::dollar(0,prefix=input$v_curr),s_labels_curr)
      
      s_output_values$yearly_loss_info<-cbind(s_sim_results_by_datayear,`Yearly Loss`=with(s_sim_results_by_datayear,
                                          cut(ANNUAL_LOSS_CAPPED,s_losses,labels=s_labels_percent)))%>%mutate(`Yearly Loss`=as.character(`Yearly Loss`))%>%
                                          mutate(`Yearly Loss`=ifelse(ANNUAL_LOSS_CAPPED==0,"0%",`Yearly Loss`))%>%
                                          mutate(`Yearly Loss`=as.factor(`Yearly Loss`))%>%group_by(`Yearly Loss`)%>%
        summarise(`Number of Simulation Years`=n(),
                  `Average Weight`=mean(weight), `Percentage of Simulation Years`=n()/(s_n_data_years*s_sims_n))%>%
        mutate(`Percentile`=cumsum(`Percentage of Simulation Years`))
      
      s_labels_percent<<-c(percent(0),s_labels_percent,paste0(">=",percent(max(s_losses))))
      }
      
      s_sim_ok<<-TRUE
      s_sim_ok_ibtracs<<-TRUE
      
      output$s_sim_ok_ibtracs<-renderText({TRUE})
      outputOptions(output, "s_sim_ok_ibtracs", suspendWhenHidden = FALSE)
      
      
      toc()
      toc()
    }else{
      
      #1. Read in footprint file (will need further validation here in case users change exposure)
      
      if( identical(c(e_selected_ll_rv$vals$lat[1],e_selected_ll_rv$vals$lng[1],input$e_shape_p1),h_location)==FALSE){
        showModal(modalDialog(title = "Warning",
                              "Location has been changed since hazard data was loaded. Please re-load 
                              hazard data before continuing."))
        return()
      }
      
      if( point.in.polygon(e_selected_ll_rv$vals$lng[1],e_selected_ll_rv$vals$lat[1],
                       eval(parse(text=h_mappings_selected$poly_lng[1])),
                       eval(parse(text=h_mappings_selected$poly_lat[1])))==0){
        
        showModal(modalDialog(title = "Warning",
                              "Location does not lie within hazard data range.Go back to the Hazard tab and 
                              check your location is covered by the hazard data before running."))
        return()
        
      }
      
      s_areaperil_id<-as.vector(h_areaperil_dict$areaperil_id)
      h_footprint<-readr::read_csv_chunked(paste0("./data/stochastic/",h_mappings_selected$region_code[1],"/footprint/footprint.csv"),
                                           callback = DataFrameCallback$new(function(x, pos) subset(x, areaperil_id %in% s_areaperil_id)))
      
      h_max_n<-h_mappings_selected$max_year_no[1]
      s_sim_periods<-data.frame(sim_no=as.factor(c(1:s_sims_n)),period_no=sample(1:h_max_n,s_sims_n,replace=TRUE))
      
      s_sim_events<-merge(s_sim_periods,h_occurrence,by="period_no")%>%
        merge(h_footprint,by="event_id")%>%
        merge(h_intensity,by.x="intensity_bin_id",by.y="bin_index")
      
      s_sim_events<-cbind(s_sim_events,random_var=runif(n=nrow(s_sim_events)))
      
      
      s_sim_events[[s_intensity_ibtracs_name]]<-s_sim_events$bin_from+(s_sim_events$bin_to-s_sim_events$bin_from)*s_sim_events$random_var
      
      s_vulnerability$loss_factor<-0
      
      if(s_curve_type=="Linear"){
        
        for (i in 2:(nrow(s_vulnerability)-1)){
          
          s_vulnerability$loss_factor[i]<-(s_vulnerability$loss[i+1]-s_vulnerability$loss[i])/
            (s_vulnerability$intensity[i+1]-s_vulnerability$intensity[i])
        }
        
      }
      
      for (i in 1:nrow(s_sim_events)) { 
        
        row_select<-nrow(s_vulnerability[s_vulnerability[["intensity"]] <=
                                           s_sim_events[[s_intensity_ibtracs_name]][[i]],])
        
        s_event_loss[i] <- s_vulnerability[["loss"]][row_select] +
          (s_sim_events[[s_intensity_ibtracs_name]][[i]] - s_vulnerability[["intensity"]][row_select])*
          s_vulnerability[["loss_factor"]][row_select]
        
        
      }
      
      
      s_sim_events <- cbind(s_sim_events, EVENT_LOSS = s_event_loss) %>%
        filter(!!sym(s_intensity_ibtracs_name)>=min(s_vulnerability$intensity[s_vulnerability$loss>0|
                                                          s_vulnerability$loss_factor!=0],119))%>%
          group_by(sim_no,event_id)%>%
            slice_max(order_by = !!sym(s_intensity_ibtracs_name), with_ties = FALSE)
      
      #Spot check certain values for this line  
      
      s_sim_results_by_datayear <- s_sim_events %>%
        group_by(sim_no,occ_year) %>%
        summarise(ANNUAL_LOSS = sum(EVENT_LOSS), 
                  ANNUAL_LOSS_CAPPED = min(sum(EVENT_LOSS), s_max_recovery),
                  `EVENT COUNT`=n())%>%
        ungroup() %>%
        complete(sim_no, fill = list(occ_year=0,ANNUAL_LOSS = 0, ANNUAL_LOSS_CAPPED = 0,`EVENT COUNT`= 0))
      
      
      #Exhibit 2
      if(h_areaperil_type=="square"){
      s_output_values$sim_summary<-s_sim_events%>%
                                      select(sim_no,event_id,areaperil_id,!!sym(s_intensity_ibtracs_name),EVENT_LOSS)
      }else{
        s_output_values$sim_summary<-s_sim_events%>%
          merge(h_areaperil_dict,by="areaperil_id")%>%
          select(sim_no,event_id,areaperil_id,!!sym(s_intensity_ibtracs_name),EVENT_LOSS,lon1,lat1)%>%
          rename(SELECTED_LON=lon1,SELECTED_LAT=lat1)
        
      }
      
      s_output_values$sims_by_loc<-s_sim_results_by_datayear%>%
                                    dplyr::rename(`SIM NUMBER`=sim_no,
                                                  `SIMULATION AVERAGE LOSS UNCAPPED`=ANNUAL_LOSS,
                                                  `SIMULATION AVERAGE LOSS`=ANNUAL_LOSS_CAPPED)
      
      s_output_values$areaperil<-h_areaperil_dict
      
      #Exhibit 3
      s_intensity_stats <- data.frame(placeholder1 = 1:5, placeholder2 = 
                                      c(119.0915,154.4971, 178.6372, 209.2148, 252.6671), 
                                    event_loss = 0, simulated_frequency = 0,
                                    simulated_rp = 0)
      
      names(s_intensity_stats)[1]<-ifelse(s_intensity_ibtracs_name=="PEAK_GROUND_ACCELERATION",
                                           "MMI","category")
      names(s_intensity_stats)[2]<-s_intensity_ibtracs_name
      
      s_intensity_stats[,1]<-1:5
      s_intensity_stats[,2]<-5:9
      
      s_intensity_stats[,2]<-if(s_intensity_ibtracs_name=="PEAK_GROUND_ACCELERATION"){
        c(9.2,18,34,65,124)
      }else{
        c(119.0915,154.4971, 178.6372, 209.2148, 252.6671)
      }
      
      
      for (i in 1:nrow(s_intensity_stats)) {
  
      s_intensity_stats$event_loss[i] <- max(s_vulnerability$loss[s_vulnerability$intensity <=
                                                                  s_intensity_stats[[s_intensity_ibtracs_name]][i]])
      
      s_intensity_stats$simulated_frequency[i] <- sum(s_sim_events[[s_intensity_ibtracs_name]] >=
                                                       c(s_intensity_stats[[s_intensity_ibtracs_name]][i]))/(s_sims_n)
      }      
      
      
      
      s_output_values$intensity_info <- s_intensity_stats %>%
        mutate(simulated_rp = pmax(1/simulated_frequency,1))
      
      is.na(s_output_values$intensity_info) <-sapply(s_output_values$intensity_info,is.infinite)
      
      #Exhibit 4
     
if(s_curve_type=="Step"){      
      s_output_values$yearly_loss_info<-s_sim_results_by_datayear%>%
        mutate(`Yearly Loss`=round(ANNUAL_LOSS_CAPPED,9))%>%
        group_by(`Yearly Loss`)%>%
        summarise(`Number of Simulation Years`=n(), `Percentage of Simulation Years`=n()/(s_sims_n))%>%
        mutate(`Percentile`=cumsum(`Percentage of Simulation Years`))
}else{
  
  s_losses<-c(pull(s_vulnerability%>%filter(loss>0|loss_factor!=0)%>%select(loss)))
  s_labels_percent<<-character(0)
  s_labels_curr<<-character(0)
  for (i in 1:(length(s_losses)-1)){
    s_labels_percent[i]<<-paste0(scales::percent(s_losses[i]),"-",scales::percent(s_losses[i+1]))
    s_labels_curr[i]<<-paste0(scales::dollar(s_losses[i]*s_max_ins,prefix=input$v_curr),"-",scales::dollar(s_losses[i+1]*s_max_ins,prefix=input$v_curr))
  }
  
  s_labels_curr<<-c(scales::dollar(0,prefix=input$v_curr),s_labels_curr)
  s_output_values$yearly_loss_info<-cbind(s_sim_results_by_datayear,`Yearly Loss`=with(s_sim_results_by_datayear,
                                                       cut(ANNUAL_LOSS_CAPPED,s_losses,labels=s_labels_percent)))%>%mutate(`Yearly Loss`=as.character(`Yearly Loss`))%>%
    mutate(`Yearly Loss`=ifelse(ANNUAL_LOSS_CAPPED==0,"0%",`Yearly Loss`))%>%
    mutate(`Yearly Loss`=as.factor(`Yearly Loss`))%>%group_by(`Yearly Loss`)%>%
    summarise(`Number of Simulation Years`=n(), `Percentage of Simulation Years`=n()/(s_sims_n))%>%
    mutate(`Percentile`=cumsum(`Percentage of Simulation Years`))
    
    s_labels_percent<<-c(percent(0),s_labels_percent)
    
}      
      s_output_values$el<- data.frame(Measure = c("Expected Loss", "Standard Deviation"),
                                      Simulation_Loss = c(mean(s_sim_results_by_datayear$ANNUAL_LOSS_CAPPED),
                                                          sd(s_sim_results_by_datayear$ANNUAL_LOSS_CAPPED)))
      
      output$s_sim_ok_ibtracs<-renderText({FALSE})
      outputOptions(output, "s_sim_ok_ibtracs", suspendWhenHidden = FALSE)
      
      s_sim_ok_ibtracs<<-FALSE
      s_sim_ok<<-TRUE
      
    }
  }
},ignoreInit = TRUE)

observeEvent(s_output_values$intensity_info, {
  showNotification("Simulation Complete. Please navigate to the Event and Loss Analysis tabs to see outputs.")
  
})



