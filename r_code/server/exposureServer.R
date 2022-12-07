
observeEvent(input$e_nextpage, {
  updateTabsetPanel(session, "tabset",
                    selected = "hazard")
})

observeEvent(input$e_prevpage, {
  updateTabsetPanel(session, "tabset",
                    selected = "intro")
})

# 1. Selected Lat-Long Objects 

e_selected_ll_rv<<-reactiveValues(vals=data.frame(NULL))

output$e_selected_ll_tbl<-renderTable({
  e_selected_ll_rv$vals   
})

# 2.Leaflet Map Display Behaviour
# Address bar is hidden if user knows co-ordinates. 
# removeSearchOSM doesn't work so map has to be re-rendered.

observeEvent(input$e_ll_known,{
  if(input$e_ll_known=='No'){
    
    output$e_input_error_message <- renderText({""})

    output$e_input_map <- renderLeaflet({
      leaflet() %>%
        setMaxBounds(lat1=-90,lat2=90,lng1=-360,lng2=360)%>%
        setView(lat=0,lng=0,zoom=2)%>%
        addSearchOSM(
          options = leaflet.extras::searchOptions(
            autoCollapse = TRUE,
            hideMarkerOnCollapse = TRUE,
            zoom=4,
            position = "topleft",
            minLength = 4
          ))%>%
        addProviderTiles(providers$OpenStreetMap)
    
    })
  }else
  {
   output$e_input_map <-renderLeaflet({
      leaflet() %>%
        setMaxBounds(lat1=-90,lat2=90,lng1=-360,lng2=360)%>%
        setView(lat=0,lng=0,zoom=2)%>%
        addProviderTiles(providers$OpenStreetMap)
    })
  }
})

# 3. Marker display and zoom behaviour. 
# Adds markers after address lookup.NB leaflet.extras 
# package defaults to drawing a circle around the location
# so clearMarkers clears this default as well as any 
# previous markers the user may have entered

observeEvent(input$e_input_map_search_location_found,{
  leafletProxy(mapId = "e_input_map") %>%
    clearMarkers()%>%
    addMarkers(lat=input$e_input_map_search_location_found$latlng$lat,
               lng=input$e_input_map_search_location_found$latlng$lng,
               popup=paste(paste('<strong>','Selected Location','</strong>'),
                           paste('Latitude:',input$e_input_map_search_location_found$latlng$lat),
                           paste('Longitude:',input$e_input_map_search_location_found$latlng$lng)))
  
  e_selected_ll_rv$vals<-data.frame(lat=input$e_input_map_search_location_found$latlng$lat,
                                  lng=input$e_input_map_search_location_found$latlng$lng)
})

observeEvent(input$e_input_map_click,{
  req(input$e_ll_known=='No')
  click = input$e_input_map_click
  
  #Correction in case users go over 180/-180 boundaries
  e_selected_ll_rv$vals<-data.frame(lat=click$lat,
                                  lng=ifelse(click$lng[1]>180,click$lng[1]-360,
                                             ifelse(click$lng[1]<(-180),click$lng[1]+360,click$lng[1])))
  
  leafletProxy(mapId = "e_input_map") %>%
    clearMarkers()%>%
    addMarkers(lat=e_selected_ll_rv$vals$lat[1],
               lng=e_selected_ll_rv$vals$lng[1],
               popup=paste(paste('<strong>','Selected Location','</strong>'),
                                         paste('Latitude:',e_selected_ll_rv$vals$lat[1]),
                                         paste('Longitude:',e_selected_ll_rv$vals$lng[1])))
  
  #setView is called here as the marker will appear in a different place to where the user has clicked
  if(click$lng[1]>180|click$lng[1]<(-180)){
      
      leafletProxy(mapId = "e_input_map") %>%
        setView(e_selected_ll_rv$vals$lng[1],e_selected_ll_rv$vals$lat[1],zoom=4)
                                             
    }
})

# Adds marker after Lat-longs have been entered
observe({
  shiny::req(input$e_lat_input,input$e_lng_input)
  
  if(-90 > input$e_lat_input|90<input$e_lat_input|
     -180 > input$e_lng_input|180 < input$e_lng_input)
  {
    
    output$e_input_error_message <- renderText({paste("<span style=\"color:red;font-size:16px\">",
                                                      "Please ensure your latitude and longitude values
                                                      are valid")
                                              })
    e_selected_ll_rv$vals<-data.frame(NULL)
    
    leafletProxy(mapId = "e_input_map") %>%
      clearMarkers()%>%
      clearShapes()
    
  }else{
  leafletProxy(mapId = "e_input_map") %>%
    clearMarkers()%>%
    clearShapes()%>%
    addMarkers(lat=input$e_lat_input,
               lng=input$e_lng_input,
               popup=paste(paste('<strong>','Selected Location','</strong>'),
                           paste('Latitude:',input$e_lat_input),
                           paste('Longitude:',input$e_lng_input)))%>%
    setView(input$e_lng_input,input$e_lat_input,zoom=4)
  
  
  e_selected_ll_rv$vals<-data.frame(lat=input$e_lat_input,
                                  lng=input$e_lng_input)
  
  output$e_input_error_message <- renderText({""})
  }
})

# 4. Circle display behaviour.
# Adds circles once circle radius has been entered

e_radius_unit_correction<<-reactive({
  ifelse(input$e_shape_units=="km",1,1.60934)
         })

observeEvent(req(input$e_shape_p1,nrow(e_selected_ll_rv$vals)!=0,input$e_shape_units),{
  
                          
  leafletProxy(mapId = "e_input_map")%>%
    removeShape(layerId = "circles")%>%
    addCircles(lat=e_selected_ll_rv$vals$lat,
               lng=e_selected_ll_rv$vals$lng,
               radius =input$e_shape_p1*1000*e_radius_unit_correction(),
               layerId="circles")
  if(input$e_shape_p1*e_radius_unit_correction()>150){
    output$e_exposure_complete<-renderText({""})
    output$s_exposure_complete<-renderText({paste("<span style=\"color:red;font-size:16px\">",
                                                  as.character(icon("times-circle")),"Exposure Section Incomplete: Revisit This Tab Before Running Simulation")})
    output$e_circle_warning<-renderText({
      "Please ensure radius is less than 150km or 93 miles. Sizes above this can cause issues with the calculations."                        
    })
    s_exposure_ok<<-FALSE
  }else{
    output$e_circle_warning<-renderText({""})
  }
})

# 5.UI section complete checks 

output$s_exposure_complete<-renderText({paste("<span style=\"color:red;font-size:16px\">",
                                              as.character(icon("times-circle")),"Exposure Section Incomplete: Revisit This Tab Before Running Simulation")})
s_exposure_ok<<-FALSE


observeEvent(req(input$e_shape_p1*e_radius_unit_correction()<=200&
                   nrow(e_selected_ll_rv$vals)==1&input$v_max_insured>0),{
    
  output$e_exposure_complete<-renderText({paste(as.character(icon("check-circle")),"Section Complete: Exposure Information Entered")})
  output$s_exposure_complete<-renderText({paste("<span style=\"color:green;font-size:16px\">",
                                                as.character(icon("check-circle")),"Exposure Section Complete")})
  s_exposure_ok<<-TRUE

})


observe({
  
  req(isTRUE(input$e_shape_p1*e_radius_unit_correction()>=200)|!is.numeric(input$e_shape_p1*e_radius_unit_correction())|
      nrow(e_selected_ll_rv$vals)==0|isTRUE(input$v_max_insured<=0)|!is.numeric(input$v_max_insured))
  
  output$e_exposure_complete<-renderText({""})
  output$s_exposure_complete<-renderText({paste("<span style=\"color:red;font-size:16px\">",
                                                as.character(icon("times-circle")),"Exposure Section Incomplete: Revisit This Tab Before Running Simulation")})
  s_exposure_ok<<-FALSE
  
  req(!is.numeric(input$e_shape_p1)|nrow(e_selected_ll_rv$vals)==0)  
  
  leafletProxy(mapId = "e_input_map")%>%
    removeShape(layerId = "circles")
})

