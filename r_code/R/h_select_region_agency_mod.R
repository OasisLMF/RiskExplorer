h_select_region_agency_UI <- function(id) {
  ns <- NS(id)
  tagList(
      h6("Select Region"),
      column(width = 6,
        leafletOutput(ns("select_region_map"))),
      textOutput(ns("region_select_text")),
      selectInput(ns("agency_select"),
                  label = 'Meteorological Agency',
                  choices = NULL,
                  selected = "")
  ) 
}

h_select_region_agency_Server <- function(id, h_mappings, peril_data_choices){
  moduleServer(
    id,
    function(input, output, session) {
      
      output$select_region_map <- 
        renderLeaflet({
          
          leaflet::leaflet() |> 
          leaflet::addTiles() |> 
          leaflet::setView(lat = 0, 
                           lng = 0,
                           zoom = 2)
          # leaflet::setMaxBounds(lat1 = -90, lat2 = 90, 
          #                       lng1 = -270, lng2 = 270) 
        })  
      
      observe({
        
        req(peril_data_choices$peril_choice(),
            peril_data_choices$dataset_choice(),
            peril_data_choices$choices_map_data())
        
        leaflet::leafletProxy("select_region_map") |>
        leaflet::clearShapes() |>
        leaflet::addPolygons(data = peril_data_choices$choices_map_data(),
                             color = "#D41F29",
                             label = peril_data_choices$choices_map_data()$region_name,
                             layerId = peril_data_choices$choices_map_data()$region_name,
                             highlightOptions = highlightOptions(color = "white",
                                                                weight = 5, 
                                                                bringToFront = T, 
                                                                opacity = 1))
      })
      
      region_choice <-
        eventReactive(input$select_region_map_shape_click,{
          input$select_region_map_shape_click$id  
        })
      
      output$region_select_text <-
        renderText({
          req(region_choice())
          paste(region_choice(), "selected")
        })
      
      
      observe({
      
      req(peril_data_choices$peril_choice(),
          peril_data_choices$dataset_choice(),
          region_choice())
      
      updateSelectInput(session, 
                        inputId = "agency_select", 
                        selected = "",
                        choices = split_string(
                          filter_and_select_column(
                            h_mappings,
                            unique = TRUE,
                            vec_type = "character",
                            column_to_select = "agencies",
                            peril == peril_data_choices$peril_choice(),
                            dataset == peril_data_choices$dataset_choice(),
                            region_name == region_choice()))
                        )
                
        
      })
      
      return(
        list(region_choice = region_choice,
             agency_choice = reactive(input$agency_select))
      )
          
       
    }
  )
}