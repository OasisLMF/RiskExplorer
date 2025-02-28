
e_location_select_UI <- function(id) {
  ns <- NS(id)
  tagList(
    h4("Step 1: Choose Location or Centre of Area to Model"),
    conditionalPanel(condition = paste0("input[\'",
                                        ns("ll_known"),"\'] == 'Yes'"),
                     column(width = 6,
                            helpText("Enter lat-long co-ordinates manually to display 
                       on map. Note that these are entered on a plus minus scale. 
                       E.g. -130 longitude is 130 degrees west and 45 latitude 
                       is 45 degrees north."))),
    conditionalPanel(condition = paste0("input[\'",
                                        ns("ll_known"),"\'] == 'No'"),
                     column(width = 6,
                            helpText("Drop a pin on the map by clicking on the relevant
                       location. You may also look up the address using the 
                       magnifying glass icon in the top left."))),
    selectInput(ns("ll_known"),
      label = "Do you know the latitude and longitude co-ordinates of the 
      location you are modelling?",
      choices = c("Yes", "No"),
      selected = "No"),
    tags$script(
      HTML('$input_mapContainer.on(\'map-container-resize\', function () {
           input_map.invalidateSize();')),
    leafletOutput(ns('input_map'), 
                  height = "50vh", 
                  width = "50vw"),
    conditionalPanel(condition = paste0("input[\'",
                                        ns("ll_known"),"\'] == 'Yes'"),
                     column(width = 6,
                            numericInput(ns("lat_input"),
                                         label = "Latitude (degrees)",
                                         value = "",
                                         min = -90.00,
                                         max = 90.00,
                                         step = 0.01)),
                     column(width = 6,
                            numericInput(ns("lng_input"),
                                         label = "Longitude (degrees)",
                                         value = "",
                                         min = -180.00,
                                         max = 180.00,
                                         step = 0.01))),
    htmltools::span(uiOutput(ns("map_error_message"), 
                             style = "color:red;font-size:16px")),
    tableOutput(ns("selected_ll_tbl"))
  )
}

e_location_select_Server <- function(id, selected_hazard_mappings) {
  moduleServer(
    id,
    function(input, output, session) {
      
      map_render <- reactiveVal(NULL)
      map_error_rv <- reactiveValues(text = NULL)
      selected_ll_rv <- reactiveValues(vals = NULL)
      section_ok <- reactiveVal(NULL)
      
      map_poly_data <- 
        reactive({
          req(selected_hazard_mappings())
          
          selected_df <- data.frame(
            poly_lng = selected_hazard_mappings()["poly_lng"],
            poly_lat = selected_hazard_mappings()["poly_lat"],
            region_name = selected_hazard_mappings()["region_name"]
          )
          
          pull_sf_mapping_data(selected_df)
        })
      
      output$selected_ll_tbl<-renderTable({
        req(selected_ll_rv)
        selected_ll_rv$vals   
      })
      
      observe({
        req(map_error_rv)
        
        output$map_error_message <- 
          renderText({
            map_error_rv$text
          })
        
      })
      
      output$input_map <- 
        leaflet::renderLeaflet({
          
          map_render(TRUE)
          leaflet::leaflet()  |> 
          leaflet::setMaxBounds(lat1 = -90,
                                lat2 = 90,
                                lng1 = -360,
                                lng2 = 360) |> 
          leaflet::setView(lat = 0,
                           lng = 0,
                           zoom = 2) |> 
          leaflet::addTiles() |> 
          leaflet.extras::addSearchOSM(
              options = leaflet.extras::searchOptions(
                autoCollapse = TRUE,
                hideMarkerOnCollapse = TRUE,
                zoom = 4,
                position = "topleft",
                minLength = 4
              ))
        })
      
      proxy_input_map <- 
        reactive({ 
          leaflet::leafletProxy(mapId = "input_map")
        })

      observe({
        
        req(map_render())
        
        proxy_input_map()|>
        leaflet::clearShapes() |> 
        leaflet::clearMarkers() |> 
        leaflet::addPolygons(data = map_poly_data(),
                             color = "#D41F29",
                             label = paste("Selected Hazard Region:",
                                           map_poly_data()$region_name),
                             layer = "hazard_region")
        
        selected_ll_rv$vals <- NULL
      })
      
      observeEvent(input$input_map_search_location_found,{
        
        shiny::req(map_poly_data())
        
        loc_found <-
          add_loc_search_found(leaflet_proxy = proxy_input_map(),
                               search_found = 
                                 input$input_map_search_location_found,
                               poly = map_poly_data())
        
        map_error_rv$text <- loc_found$message_text
        selected_ll_rv$vals <- loc_found$vals
      })
      
      
      shiny::observeEvent(input$input_map_click,{
        
        shiny::req(input$ll_known == 'No', map_poly_data())
        
        loc_map_click <-
          add_loc_map_click(leaflet_proxy = proxy_input_map(), 
                            map_click = input$input_map_click,
                            poly = map_poly_data())
        
        map_error_rv$text <- loc_map_click$message_text
        selected_ll_rv$vals <- loc_map_click$vals
      })
      
      observe({
        
        shiny::req(input$lat_input, input$lng_input, input$ll_known=='Yes',
                   map_poly_data())
        
        loc_manual_ll <-
          add_loc_manual_ll(leaflet_proxy = proxy_input_map(), 
                            lat_input = input$lat_input,
                            lng_input = input$lng_input,
                            poly = map_poly_data())
        
        map_error_rv$text <- loc_manual_ll$message_text
        selected_ll_rv$vals <- loc_manual_ll$vals
      })
      
      observe({
        
        section_ok(FALSE)
        req(selected_ll_rv$vals)
        
        if(is.null(map_error_rv$text)){
          section_ok(TRUE)
        }
      })
      
      return(
        list(
          proxy_input_map = proxy_input_map,
          ll_vals = selected_ll_rv,
          section_ok = section_ok,
          map_poly_data = map_poly_data
        )
      )
        
    }
  )
}
