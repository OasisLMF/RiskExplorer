ibtracs_basin_agency <- data.frame(BASIN = c("NA", "EP", "WP", 
                                     "NI", "SI", "SP","SA"), 
                                 AGENCY1 = c("USA", "USA", "USA", "NEWDELHI", 
                                             "REUNION", "WELLINGTON","USA"), 
                                 AGENCY2 = c(NA, NA, "TOKYO","USA", 
                                             "BOM", "BOM", NA), 
                                 AGENCY3 = c(NA, NA, "CMA", 
                                             NA, NA, "NADI", NA))

h_load_data_UI <- function(id) {
  ns <- NS(id)
  tagList(
    actionButton(ns("hazard_data_load"), label = "Load Hazard Data"),
    br(),
    htmltools::span(uiOutput(ns('hazard_complete'),
                    style="color:green;font-size:16px"))
  )
}

h_load_data_Server <- function(id, h_mappings, peril_data_choices, 
                               region_agency_choices) {
  moduleServer(
    id,
    function(input, output, session) {
      
      hazard_data_attributes <-
        reactive({
          req(peril_data_choices$peril_choice(),
              peril_data_choices$dataset_choice(),
              region_agency_choices$region_choice(),
              region_agency_choices$agency_choice())
          
          list(peril = peril_data_choices$peril_choice(),
               dataset = peril_data_choices$dataset_choice(),
               region = region_agency_choices$region_choice(),
               agency = region_agency_choices$agency_choice())
          
        })
      
      selected_data_mappings <- 
        eventReactive(input$hazard_data_load,{
          
          req(hazard_data_attributes()$peril,
              hazard_data_attributes()$dataset,
              hazard_data_attributes()$region,
              hazard_data_attributes()$agency)
          
          h_mappings_selected <-
            filter_and_select_column(h_mappings, 
                                     vec_type = "character", 
                                     column_to_select = colnames(h_mappings), 
                                     unique = FALSE, 
                                     peril == hazard_data_attributes()$peril,
                                     dataset == hazard_data_attributes()$dataset,
                                     region_name == hazard_data_attributes()$region)
          
          names(h_mappings_selected) <- 
            colnames(h_mappings)
          
          h_mappings_selected <-
            c(h_mappings_selected, 
              agency_selected = hazard_data_attributes()$agency)
          
          h_mappings_selected
        }
        )
      
      observeEvent(input$hazard_data_load,{
        
        req(selected_data_mappings())
        
        h_display_text <- paste(hazard_data_attributes()$peril,
                                hazard_data_attributes()$dataset,
                                hazard_data_attributes()$region,
                                hazard_data_attributes()$agency, 
                                sep="/")
        
        output$hazard_complete <- renderText({
          paste(as.character(icon("check-circle")), 
                "Section Complete: Hazard data loaded with following 
                selections made:",
                h_display_text)
        })
        
        showNotification("Hazard Data Loaded")
      })
      
      return(selected_data_mappings)
      
    }  
  )
}