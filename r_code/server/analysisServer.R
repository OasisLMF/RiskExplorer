
observeEvent(input$a_nextpage, {
  updateTabsetPanel(session, "tabset",
                    selected = "results")
})

observeEvent(input$a_prevpage, {
  updateTabsetPanel(session, "tabset",
                    selected = "simulation")
})

observe({
  req(input$s_simulation_run,input$r_output_display)
  
  r_output_display_conversion<<-ifelse(input$r_output_display=="Currency",s_max_ins,1)
  
  if(s_sim_ok==TRUE&s_sim_ok_ibtracs==TRUE){
    
    # 1. Exhibit 1: Historical Loss Summary
    
    # Table of historic losses
    a_DT_vars_to_rename<-c(`MAX WIND SPEED (KM)` = "SELECTED_WIND", `MIN PRESSURE (Mb)` = "SELECTED_PRES",
                            `EVENT LOSS` = "EVENT_LOSS",`ISO TIME` = "ISO_TIME",
                            `LATITUDE` = "SELECTED_LAT", `LONGITUDE` = "SELECTED_LON")
    
    output$a_ex1_summary<-renderTable({
      
      a_ex1_summary_df<-s_output_values$historical_summary%>%mutate(`HISTORICAL LOSS`=`HISTORICAL LOSS`*
                                                 r_output_display_conversion)%>%
        mutate(`HISTORICAL ANNUAL LOSS (CURRENCY)`=dollar(`HISTORICAL LOSS`,prefix="",suffix=s_curr,accuracy = 1),
               `HISTORICAL ANNUAL LOSS (PERCENTAGE)`=sprintf("%0.2f%%",100*`HISTORICAL LOSS`))
      
        if(input$r_output_display=="Currency"){
          a_ex1_summary_df%>%select(-`HISTORICAL LOSS`,-`HISTORICAL ANNUAL LOSS (PERCENTAGE)`)
        }else{
          a_ex1_summary_df%>%select(-`HISTORICAL LOSS`,-`HISTORICAL ANNUAL LOSS (CURRENCY)`)
        }  
    })
    
    a_ex1_DT<-s_output_values$historic%>%
      select(SID,SEASON,ISO_TIME,NAME,!!sym(s_intensity_ibtracs_name),EVENT_LOSS)%>%
      mutate(EVENT_LOSS=EVENT_LOSS*r_output_display_conversion)%>%
      dplyr::rename(any_of(a_DT_vars_to_rename))%>%
      datatable()%>%
      formatRound(columns=5,digits=1)
    
    output$a_ex1_DT<-renderDataTable({
      if(input$r_output_display=="Currency"){
        formatCurrency(a_ex1_DT,columns=6,digits=0,mark=",",currency=s_curr)
      }else{
        formatPercentage(a_ex1_DT,columns=6,digits=1)
      }            
    })
    
    
    
    # Map of losses
    output$a_historical_loss_map<-renderLeaflet({ 
      
      a_hist_map<-leaflet()%>%
        addCircles(lat=s_exposure_point[2],
                   lng=s_exposure_point[1],
                   radius=1000*s_mini_radius,
                   label="Exposure Loss Area"
        )%>%
        addMarkers(s_exposure_point[1],s_exposure_point[2],
                   label="Selected Location",
                   popup=paste(paste('<strong>','Selected Location','</strong>'),
                               paste('Latitude:',s_exposure_point[2]),
                               paste('Longitude:',s_exposure_point[1])))%>%
        addProviderTiles(providers$OpenStreetMap)%>%
        setView(lat=s_exposure_point[2],
                lng=s_exposure_point[1],
                zoom=5)
      
      if(!is.null(length(s_output_values$historic$SELECTED_LON))&!is.na(s_output_values$historic$SELECTED_LON[1])){
      
        for (i in unique(s_output_values$historic_all$SID)){
          
          a_hist_map<-addPolylines(a_hist_map,data = s_output_values$historic_all[s_output_values$historic_all$SID == i,],
                                   lat = ~SELECTED_LAT, lng = ~SELECTED_LON,label=~LABEL,weight=1.5,opacity=0.03,color="red")
        }
      }
      a_hist_map
    })
  }

  if(s_sim_ok==TRUE){
  # 2. Exhibit 2: Simulation map
  a_ex2_sim_no_r<-reactive(input$a_ex2_sim_no)
  a_ex2_sim_no_d<-debounce(a_ex2_sim_no_r,1500)
  
    a_sim_loss_data<-reactive({
      
      req(a_ex2_sim_no_d()>=1&a_ex2_sim_no_d()<=s_sims_n&a_ex2_sim_no_d()%%1==0)
      if(s_sim_ok_ibtracs==TRUE){
      s_output_values$sim_summary%>%filter(i==a_ex2_sim_no_d())%>%
        mutate(LABEL=paste(NAME,SEASON,"Loss:",percent(EVENT_LOSS)))
        }else{
      s_output_values$sim_summary%>%filter(sim_no==a_ex2_sim_no_d())%>%
            mutate(LABEL=paste("Event ID:",event_id,"Loss:",percent(EVENT_LOSS)))
      }
    })
    
    a_sim_loc_data<-reactive({
      
      req(a_ex2_sim_no_d()>=1&a_ex2_sim_no_d()<=s_sims_n&a_ex2_sim_no_d()%%1==0)
      if(s_sim_ok_ibtracs==TRUE){
      s_output_values$sims_by_loc%>%filter(`SIM NUMBER`==a_ex2_sim_no_d())%>%
        select(LONGITUDE,LATITUDE,`DISTANCE TO EXPOSURE`,WEIGHT,`SIMULATION AVERAGE LOSS`,`AVERAGE EVENT COUNT`)
      }else{
        s_output_values$sims_by_loc%>%filter(`SIM NUMBER`==a_ex2_sim_no_d())
      }
    })
    
    output$a_ex2_summary<-renderTable({
      
      if(s_sim_ok_ibtracs==TRUE){
        a_sim_loc_summary_df<-a_sim_loc_data()%>%mutate(`SIMULATION AVERAGE LOSS`=`SIMULATION AVERAGE LOSS`*
                                                              r_output_display_conversion)%>%
          mutate(`SIMULATION AVERAGE LOSS (CURRENCY)`=dollar(`SIMULATION AVERAGE LOSS`,prefix="",suffix=s_curr,accuracy = 1),
                 `SIMULATION AVERAGE LOSS (PERCENTAGE)`=sprintf("%0.2f%%",100*`SIMULATION AVERAGE LOSS`),
                  WEIGHT=sprintf("%0.2f%%",100*WEIGHT),
                 LONGITUDE=dollar(LONGITUDE,accuracy=0.001,prefix=""),
                 LATITUDE=dollar(LATITUDE,accuracy=0.001,prefix=""),
                 `DISTANCE TO EXPOSURE`=dollar(`DISTANCE TO EXPOSURE`,prefix="",accuracy=0.01,suffix="km"))
  
        if(input$r_output_display=="Currency"){
          a_sim_loc_summary_df%>%select(-`SIMULATION AVERAGE LOSS`,-`SIMULATION AVERAGE LOSS (PERCENTAGE)`)
        }else{
          a_sim_loc_summary_df%>%select(-`SIMULATION AVERAGE LOSS`,-`SIMULATION AVERAGE LOSS (CURRENCY)`)
        }
      }else{
        a_sim_loc_summary_df<-a_sim_loc_data()%>%mutate(`SIMULATION AVERAGE LOSS`=`SIMULATION AVERAGE LOSS`*
                                                          r_output_display_conversion)%>%
          mutate(`SIMULATION AVERAGE LOSS (CURRENCY)`=dollar(`SIMULATION AVERAGE LOSS`,prefix="",suffix=s_curr,accuracy = 1),
                 `SIMULATION AVERAGE LOSS (PERCENTAGE)`=sprintf("%0.2f%%",100*`SIMULATION AVERAGE LOSS`))
         
        if(input$r_output_display=="Currency"){
          a_sim_loc_summary_df%>%select(-`SIMULATION AVERAGE LOSS UNCAPPED`,-occ_year,-`SIMULATION AVERAGE LOSS`,-`SIMULATION AVERAGE LOSS (PERCENTAGE)`)
        }else{
          a_sim_loc_summary_df%>%select(-`SIMULATION AVERAGE LOSS UNCAPPED`,-occ_year,-`SIMULATION AVERAGE LOSS`,-`SIMULATION AVERAGE LOSS (CURRENCY)`)
        }                                       
        
      }
    })
    
    output$a_ex2_map<-renderLeaflet({
      
      req(a_sim_loss_data())
      if(s_sim_ok_ibtracs==TRUE){
      ex2_map<-leaflet(options = leafletOptions(preferCanvas = TRUE)) %>%
      setView(lat=s_exposure_point[2], lng = s_exposure_point[1], zoom = 5) %>%
      addProviderTiles(providers$OpenStreetMap, options = providerTileOptions(updateWhenZooming = FALSE,
                                                                              updateWhenIdle = FALSE))%>%
      addMarkers(s_exposure_point[1],s_exposure_point[2],
                 label="Selected Location",
                 popup=paste(paste('<strong>','Selected Location','</strong>'),
                             paste('Latitude:',s_exposure_point[2]),
                             paste('Longitude:',s_exposure_point[1])))%>%
      addCircles(lng = s_exposure_point[1],lat=s_exposure_point[2],
                 color = "#D41F29", radius = s_maxi_radius* 1000, label = "Simulation Sample Area", layerId = "maxi_circles")%>%
      addCircles(lng = s_exposure_point[1],lat=s_exposure_point[2], radius = s_mini_radius* 1000, 
                 label ="Exposure Loss Area", layerId = "expo_circles")%>%
      addCircles(lng = a_sim_loc_data()$LONGITUDE[1],lat=a_sim_loc_data()$LATITUDE[1],
                 color = "#D41F29", radius = s_mini_radius* 1000, 
                 label = paste("Simulation",a_ex2_sim_no_d(),"Loss Area"), layerId = "mini_circles")
      
      if(sum(a_sim_loss_data()$`EVENT_LOSS`)!=0){
        ex2_map<-ex2_map%>%addAwesomeMarkers(lng = a_sim_loss_data()$SELECTED_LON,lat=a_sim_loss_data()$SELECTED_LAT,label=a_sim_loss_data()$LABEL,
                        icon=makeAwesomeIcon("map-marker",iconColor="white",markerColor ="#D41F29"))
      }
      
      ex2_map
      
      }else if(h_areaperil_type=="square"){
      
        a_split_data_poly = lapply(unique(h_areaperil_dict$areaperil_id), function(x) {
          df = as.matrix(cbind(as.numeric(c(h_areaperil_dict[h_areaperil_dict$areaperil_id == x, c("lon1","lon2","lon4","lon3")])),
                               as.numeric(c(h_areaperil_dict[h_areaperil_dict$areaperil_id == x, c("lat1","lat2","lat4","lat3")]))))
          polys = Polygons(list(Polygon(df)), ID = x)
          return(polys)
        })
        
        a_data_polys = SpatialPolygons(a_split_data_poly)
        
        ex2_map<-leaflet(a_data_polys,options = leafletOptions(preferCanvas = TRUE)) %>%
          addTiles() %>%
          setView(lat=s_exposure_point[2], lng = s_exposure_point[1], zoom = 5) %>%
          addProviderTiles(providers$OpenStreetMap, options = providerTileOptions(updateWhenZooming = FALSE,
                                                                                  updateWhenIdle = FALSE))%>%
          addMarkers(s_exposure_point[1],s_exposure_point[2],
                     label="Selected Location",
                     popup=paste(paste('<strong>','Selected Location','</strong>'),
                                 paste('Latitude:',s_exposure_point[2]),
                                 paste('Longitude:',s_exposure_point[1])))%>%
          addCircles(lat = e_selected_ll_rv$vals$lat, lng = e_selected_ll_rv$vals$lng,
                     radius = s_exposure_radius * 1000 * e_radius_unit_correction(),label="Exposure Area",
                     layerId = "circles")%>%
          addPolygons(label = paste0("Area ID:",sapply(
            a_data_polys@polygons,
            slot,
            "ID"
          )),color= "#D41F29")
        }else{
          ex2_map<-leaflet(options = leafletOptions(preferCanvas = TRUE)) %>%
            addTiles() %>%
            setView(lat=s_exposure_point[2], lng = s_exposure_point[1], zoom = 5) %>%
            addProviderTiles(providers$OpenStreetMap, options = providerTileOptions(updateWhenZooming = FALSE,
                                                                                    updateWhenIdle = FALSE))%>%
            addMarkers(s_exposure_point[1],s_exposure_point[2],
                       label="Selected Location",
                       popup=paste(paste('<strong>','Selected Location','</strong>'),
                                   paste('Latitude:',s_exposure_point[2]),
                                   paste('Longitude:',s_exposure_point[1])))%>%
            addCircles(lat = e_selected_ll_rv$vals$lat, lng = e_selected_ll_rv$vals$lng,
                       radius = s_exposure_radius * 1000 * e_radius_unit_correction(),label="Exposure Area",
                       layerId = "circles")
          
          if(sum(a_sim_loss_data()$`EVENT_LOSS`)!=0){
            ex2_map<-ex2_map%>%addAwesomeMarkers(lng = a_sim_loss_data()$SELECTED_LON,lat=a_sim_loss_data()$SELECTED_LAT,label=a_sim_loss_data()$LABEL,
                                                 icon=makeAwesomeIcon("map-marker",iconColor="white",markerColor ="#D41F29"))
          }
        }
      ex2_map
    })
    
    output$a_ex2_DT<-renderDataTable({
      
      if(s_sim_ok_ibtracs==TRUE){
        
      a_ex2_table_DT<-a_sim_loss_data()%>%select(-i,-LABEL)%>%
      mutate(EVENT_LOSS=EVENT_LOSS*r_output_display_conversion)%>%
      dplyr::rename(any_of(a_DT_vars_to_rename))
      
      if(input$r_output_display=="Currency"){
        a_ex2_table_DT<-a_ex2_table_DT%>%mutate(`EVENT LOSS`=dollar(`EVENT LOSS`,prefix="", suffix=s_curr,accuracy = 1))
      }else{
        a_ex2_table_DT<-a_ex2_table_DT%>%mutate(`EVENT LOSS`=percent(`EVENT LOSS`,accuracy =1))
      }
      a_ex2_table_DT%>%datatable()%>%
      formatRound(columns=4:5,digits=3)%>%
        formatRound(columns=6,digits=2)
      
      }else{
      a_ex2_table_DT<-a_sim_loss_data()%>%select(-LABEL)%>%
        mutate(EVENT_LOSS=EVENT_LOSS*r_output_display_conversion)
      
      if(input$r_output_display=="Currency"){
        a_ex2_table_DT<-a_ex2_table_DT%>%mutate(EVENT_LOSS=dollar(EVENT_LOSS,prefix="", suffix=s_curr,accuracy = 1))
      }else{
        a_ex2_table_DT<-a_ex2_table_DT%>%mutate(EVENT_LOSS=percent(EVENT_LOSS,accuracy =1))
      }
      a_ex2_table_DT%>%datatable()%>%
        formatRound(columns=4,digits=2)
      }
      
    })

  # 3. Exhibit 3: SS category intensity return periods under history and simulations 
  

  output$a_intensity_stats_table<-renderTable({
    
    a_ex3_intensity_header<-ifelse(s_intensity_measure=="Pressure","Pressure (mb)",
                             ifelse(s_intensity_measure=="Peak Ground Acceleration","Peak Ground Acceleration (%g)",
                              "Wind Speed (km)"))
   
    a_intensity_table<-s_output_values$intensity_info
    
    if(s_sim_ok_ibtracs==TRUE){
    colnames(a_intensity_table)<-c("S-S Category",
                                         a_ex3_intensity_header,
                                         "Loss",
                                         "Historical Frequency",
                                         "Historical Return Period Years",
                                         "Unweighted Simulated Frequency",
                                         "Unweighted Simulated Return Period Years",
                                         "Weighted Simulated Frequency",
                                         "Weighted Simulated Return Period Years"
                                 )

    
    a_intensity_table[,c("Historical Return Period Years",
                       "Unweighted Simulated Return Period Years",
                       "Weighted Simulated Return Period Years",
                                    a_ex3_intensity_header)]<-format(a_intensity_table[,c("Historical Return Period Years",
                                                                                      "Unweighted Simulated Return Period Years",
                                                                                      "Weighted Simulated Return Period Years",
                                                                                      a_ex3_intensity_header)],digits=0)
    }else{
      
      colnames(a_intensity_table)<-c(ifelse(s_intensity_measure=="Peak Ground Acceleration","MMI Intensity","S-S Category"),
                                   a_ex3_intensity_header,
                                   "Loss",
                                   "Simulated Frequency",
                                   "Simulated Return Period Years")
      
      a_intensity_table[,c("Simulated Return Period Years",
                         a_ex3_intensity_header)]<-format(a_intensity_table[,c("Simulated Return Period Years",
                                                                           a_ex3_intensity_header)],digits=0)
    }
    a_intensity_table<-a_intensity_table%>%
      mutate(Loss=Loss*r_output_display_conversion)%>%
        mutate(`Loss as Currency`=dollar(Loss,prefix="",suffix=s_curr,accuracy = 1),
                                          `Loss as Percentage`=sprintf("%0.1f%%",100*Loss))
    
    if(s_intensity_measure=="Peak Ground Acceleration"){
      a_intensity_table<-a_intensity_table%>%dplyr::relocate(`MMI Intensity`,!!sym(a_ex3_intensity_header),
                       `Loss as Currency`,`Loss as Percentage`)
    }else{
      a_intensity_table<-a_intensity_table%>%dplyr::relocate(`S-S Category`,!!sym(a_ex3_intensity_header),
                                         `Loss as Currency`,`Loss as Percentage`)
    }
      
    if(input$r_output_display=="Currency"){
      a_intensity_table%>%select(-Loss,-`Loss as Percentage`)
    }else{
      a_intensity_table%>%select(-Loss,-`Loss as Currency`)
    }
    
  })
  
  }

  
})