# 1. Controls select input box display behaviour. 
# Each box relies on selections in the one above it.
observeEvent(input$h_nextpage, {
  updateTabsetPanel(session, "tabset",
                    selected = "vulnerability")
})

observeEvent(input$h_prevpage, {
  updateTabsetPanel(session, "tabset",
                    selected = "exposure")
})


h_display_text<<-""

# Select data set
observe({
  req(input$h_peril)
  updateSelectInput(session, "h_dataset", selected = "", choices = as.character(h_mappings[h_mappings$peril ==
                                                                                             input$h_peril, "dataset"]))
})

# Select hazard region
observe({
  req(input$h_peril, input$h_dataset)
  updateSelectInput(session, "h_region", selected = "", choices = as.character(h_mappings[h_mappings$peril ==
                                                                                            input$h_peril & h_mappings$dataset == input$h_dataset, "region_name"]))
})

# Select agency. When all selections are made this will also zoom to
# the correct area on the map
observe({
  req(input$h_peril, input$h_dataset, input$h_region)
  
  h_mappings_selected <<- h_mappings %>%
    filter(h_mappings$peril == input$h_peril & h_mappings$dataset ==
             input$h_dataset & h_mappings$region_name == input$h_region)
  
  updateSelectInput(session, "h_agency", selected = "",
                    choices = as.character(h_mappings_selected[,c(paste0("agency", 1:3))]) %>%
                      purrr::discard(is.na))
  
  leafletProxy("h_map") %>%
    setView(lat = h_mappings_selected$map_lat, lng = h_mappings_selected$map_lng,
            zoom = 3)
  
  output$h_agency_text<-renderText({
    as.character(h_mappings_selected$message)
  })
})

# 2. Basin Suggestion for User. Basin suggested based on exposure
# ll and hazard mappings file.

observe({
  req(input$h_peril, input$h_dataset, is.numeric(e_selected_ll_rv$vals$lat[1]),
      is.numeric(e_selected_ll_rv$vals$lng[1]))
  
  h_basin_suggested <- h_mappings %>%
    filter(dataset==input$h_dataset & basin_lat1 < e_selected_ll_rv$vals$lat[1] & basin_lat2 >
             e_selected_ll_rv$vals$lat[1] & (basin_lng1 < e_selected_ll_rv$vals$lng[1] &
                                               basin_lng2 > e_selected_ll_rv$vals$lng[1] | 
                                               basin_lng3 < e_selected_ll_rv$vals$lng[1] &
                                               basin_lng4 > e_selected_ll_rv$vals$lng[1])) %>%
    select(region_name)
  
  if (nrow(h_basin_suggested) == 0) {
    h_poly_df <- h_mappings %>%
      filter(dataset==input$h_dataset & shape_type == "polygon")
    
    for (i in 1:nrow(h_poly_df)) {
      h_poly <- cbind(eval(parse(text = h_poly_df$poly_lng[i])),
                      eval(parse(text = h_poly_df$poly_lat[i])))
      
      if (point.in.polygon(e_selected_ll_rv$vals$lng[1], e_selected_ll_rv$vals$lat[1],
                           h_poly[, 1], h_poly[, 2]) == TRUE) {
        h_basin_suggested[1, 1] <- h_poly_df$region_name[i]
      }
      
    }
    
  }
  
  if (nrow(h_basin_suggested) == 0) {
    output$h_suggested_region <- renderText({
      "No relevant basin suggestion based on exposure entered. Please check your exposure input
                                          lies in an area impacted by selected perils"
    })
  } else {
    output$h_suggested_region <- renderText({
      paste(h_basin_suggested, "is the relevant region for your exposure")
    })
  }
})


# 3. Hazard load behaviour. Checks all necessary inputs are defined
# and then loads the selected hazard data into the tool

h_data <<- NULL

observeEvent(input$h_data_load, {
  
  if (isTruthy(input$h_peril) & isTruthy(input$h_dataset) & isTruthy(input$h_agency) &
      isTruthy(match(input$h_agency, h_mappings_selected)) & isTruthy(input$h_region) &
      isTruthy(is.numeric(e_selected_ll_rv$vals$lat[1])) & 
      isTruthy(is.numeric(e_selected_ll_rv$vals$lng[1]))){
    
    gc()
    showNotification("Hazard Data Loading...")
    # Defines agency variable strings to include/exclude
    
    if(input$h_dataset=="IBTrACS Historical Data "){
      gc()
      h_include_agency <- toupper(colnames(h_mappings_selected)[match(input$h_agency,
                                                                      h_mappings_selected[1, ])])
      h_exclude_agency <- setdiff(c("AGENCY1", "AGENCY2", "AGENCY3"),
                                  h_include_agency)
      h_exclude_vars <- NULL
      
      # Reads in appropriate hazard data
      h_data <<- data.frame(fread(paste0("./data/ibtracs/", h_mappings_selected$file[1]),
                                  stringsAsFactors = TRUE))
      
      # Selects only columns for user selected agency and renames
      # these appropriately
      for (i in 1:length(h_exclude_agency)) {
        h_exclude_vars <- append(h_exclude_vars, grep(h_exclude_agency[i],
                                                      colnames(h_data)))
        
      }
      colnames(h_data) <<- gsub(h_include_agency, "SELECTED", colnames(h_data))
      
      h_data <<-h_data[, -(h_exclude_vars)] %>%
        filter(!is.na(SELECTED_LAT), !is.na(SELECTED_LON), !is.na(SELECTED_WIND)|!is.na(SELECTED_PRES)) %>%
        group_by(SID)
      
      h_display_text <<- paste(input$h_peril, "/", input$h_dataset, "/",
                              input$h_region, "/", input$h_agency)
      
      # Update UI validation messages
      output$h_hazard_complete <- renderText({
        paste(as.character(icon("check-circle")), "Section Complete: Hazard data loaded with following selections made:",
              h_display_text)
      })
      output$s_hazard_complete <- renderText({
        paste("<span style=\"color:green;font-size:16px\">", as.character(icon("check-circle")),
              "Hazard Section Complete")
      })
      
      s_hazard_ok<<-TRUE
      showNotification("Hazard Data Successfully Loaded")
      print(head(h_data))
      
    }else{
      gc()
      h_exposure_type<-ifelse(input$e_shape_p1==0,"point","circle" )
      h_areaperil_type<<-h_mappings_selected$areaperil_type[1]
      h_epsg_transform<-h_mappings_selected$areaperil_type[1]
      
      h_files=paste0("./data/stochastic/",h_mappings_selected$region_code[1],"/files/",list.files(
        path = paste0("./data/stochastic/",h_mappings_selected$region_code[1],"/files/")))
      
      h_data<<-lapply(h_files, fread, stringsAsFactors = TRUE)
      h_areaperil_dict<<-as.data.frame(h_data[1])
      
      if(h_areaperil_type=="point"&h_exposure_type=="point"){
        
        h_areaperil_dict<<-h_areaperil_dict[which.min(spDistsN1(cbind(h_areaperil_dict$lon1,h_areaperil_dict$lat1),cbind(e_selected_ll_rv$vals$lng[1],e_selected_ll_rv$vals$lat[1]),longlat = TRUE)),]
        
      }else if(h_areaperil_type=="point"&h_exposure_type=="circle"){
        
        h_areaperil_dict<<-h_areaperil_dict[spDistsN1(cbind(h_areaperil_dict$lon1,h_areaperil_dict$lat1),cbind(e_selected_ll_rv$vals$lng[1],e_selected_ll_rv$vals$lat[1]),longlat = TRUE)<input$e_shape_p1,]
        
      }else if(h_areaperil_type=="square"&h_exposure_type=="point"){
        #lon3 must be greater than lon1 and lat2 must be greater than lat1
        
        h_areaperil_dict<<-h_areaperil_dict%>%filter(e_selected_ll_rv$vals$lng[1]>=lon1&e_selected_ll_rv$vals$lng[1]<=lon3&
                                        e_selected_ll_rv$vals$lat[1]>=lat1&e_selected_ll_rv$vals$lat[1]<=lat2)
        
      }else if(h_areaperil_type=="square"&h_exposure_type=="circle"){
        
        h_exposure_poly<-st_as_sf(data.frame(lng=e_selected_ll_rv$vals$lng[1],lat=e_selected_ll_rv$vals$lat[1]),coords=c("lng","lat"),crs=4326)%>%
          st_transform(h_mappings_selected$epsg_transform[1])
        
        h_exposure_poly<-st_buffer(h_exposure_poly,input$e_shape_p1*1000)%>%st_transform("EPSG:4326")
        
        h_poly_intersect<-list(NULL)
        for (i in 1:nrow(h_areaperil_dict)){
          
          h_poly_list<-
            list(cbind(c(h_areaperil_dict$lon1[i],h_areaperil_dict$lon2[i],h_areaperil_dict$lon4[i],
                         h_areaperil_dict$lon3[i],h_areaperil_dict$lon1[i]),
                       c(h_areaperil_dict$lat1[i],h_areaperil_dict$lat2[i],h_areaperil_dict$lat4[i],
                         h_areaperil_dict$lat3[i],h_areaperil_dict$lat1[i])))
          
          h_poly<-st_polygon(h_poly_list)%>%st_sfc(crs=4326)
          h_poly_intersect[i]<-st_intersects(h_poly,h_exposure_poly)
        }
        
        
        h_poly_intersect<-unlist(h_poly_intersect==1)
        h_areaperil_dict<<-cbind(h_areaperil_dict,h_poly_intersect)%>%filter(h_poly_intersect==TRUE)
        
      }
      
      h_intensity<<-h_data[[2]]
      h_occurrence<<-h_data[[3]]
      
      h_location<<-c(e_selected_ll_rv$vals$lat[1],e_selected_ll_rv$vals$lng[1],input$e_shape_p1)
      
      h_display_text <<- paste(input$h_peril, "/", input$h_dataset, "/",
                              input$h_region)
      
      # Update UI validation messages
      output$h_hazard_complete <- renderText({
        paste(as.character(icon("check-circle")), "Section Complete: Hazard data loaded with following selections made:",
              h_display_text)
      })
      output$s_hazard_complete <- renderText({
        paste("<span style=\"color:green;font-size:16px\">", as.character(icon("check-circle")),
              "Hazard Section Complete")
      })
      s_hazard_ok<<-TRUE
      showNotification("Hazard Data Successfully Loaded")
      
   }                         
    
  } else {
    showModal(modalDialog(title = "Warning",
    "Please ensure you have made selections in all fields on the Hazard and Exposure tabs before loading data."))
  }
  
}, ignoreInit = TRUE)

# 4.Map display behaviour. Generates map and draws tracks once users
# have loaded data

output$h_map <- renderLeaflet({
  leaflet(options = leafletOptions(preferCanvas = TRUE)) %>%
    setView(0, lng = 0, zoom = 3) %>%
    addProviderTiles(providers$OpenStreetMap, options = providerTileOptions(updateWhenZooming = FALSE,
                                                                            updateWhenIdle = FALSE))
})

observeEvent(input$h_display_tracks, {
  
  req(h_data, e_selected_ll_rv$vals)
  
  if(grepl("IBTrACS",h_display_text)==TRUE){
  # Only pulls in a subset of tracks as displaying this much data
  # on the map is quite slow
  h_data_plot <- h_data[hour(h_data$ISO_TIME) %in% c(0, 6, 12, 18) &
                          minute(h_data$ISO_TIME) == 0 &!is.na(h_data$SELECTED_WIND)& h_data$SELECTED_WIND >= 119 & between(h_data$SEASON,
                                                                                                                            2012, 2021), ]%>%
    mutate(LABEL=paste(NAME,SEASON))
  
  leafletProxy("h_map") %>%
    clearMarkers() %>%
    clearShapes() %>%
    addMarkers(lat = e_selected_ll_rv$vals$lat, lng = e_selected_ll_rv$vals$lng,
               popup = paste(paste("<strong>", "Selected Location", "</strong>"),
                             paste("Latitude:", e_selected_ll_rv$vals$lat), 
                             paste("Longitude:",e_selected_ll_rv$vals$lng))) %>%
    addCircles(lat = e_selected_ll_rv$vals$lat, lng = e_selected_ll_rv$vals$lng,
               radius = input$e_shape_p1 * 1000 * e_radius_unit_correction(),
               layerId = "circles") %>%
    addCircles(lat = e_selected_ll_rv$vals$lat, lng = e_selected_ll_rv$vals$lng,
               color = "#D41F29", radius = (87.6 + (input$e_shape_p1 * e_radius_unit_correction())) *
                 5 * 1000, label = "Simulation Sample Area", layerId = "sample_circles")
  
  for (i in unique(h_data_plot$SID)) {
    tic()
    
    leafletProxy("h_map") %>%
      addPolylines(data = h_data_plot[h_data_plot$SID == i, ], lat = ~SELECTED_LAT,
                   lng = ~SELECTED_LON, label = ~LABEL, weight = 1.5, opacity = 0.03,
                   color = "red")
  }
  toc()
  leafletProxy("h_map") %>%
    setView(lat = h_mappings_selected$maplat, lng = h_mappings_selected$maplng,
            zoom = 4)
  }else{

    leafletProxy("h_map") %>%
      clearMarkers() %>%
        clearShapes() %>%
          addPolygons(lng=eval(parse(text = h_mappings_selected$poly_lng[1])),
                      lat=eval(parse(text = h_mappings_selected$poly_lat[1])),
                      color="red",label="Hazard Data Coverage")%>%
          addMarkers(lat = e_selected_ll_rv$vals$lat, lng = e_selected_ll_rv$vals$lng,
                     popup = paste(paste("<strong>", "Selected Location", "</strong>"),
                                   paste("Latitude:", e_selected_ll_rv$vals$lat), 
                                   paste("Longitude:",e_selected_ll_rv$vals$lng))) %>%
          addCircles(lat = e_selected_ll_rv$vals$lat, lng = e_selected_ll_rv$vals$lng,
                     radius = input$e_shape_p1 * 1000 * e_radius_unit_correction(),label="Exposure Area",
                     layerId = "circles")%>%
          setView(lat = h_mappings_selected$map_lat[1], lng = h_mappings_selected$map_lng[1],
                  zoom = h_mappings_selected$map_zoom[1])
    
  }
})

# 5. UI section complete checks
output$s_hazard_complete <- renderText({
  paste("<span style=\"color:red;font-size:16px\">", as.character(icon("times-circle")),
        "Hazard Section Incomplete: Revisit This Tab Before Running Simulation")
})

s_hazard_ok<<-FALSE