
hazard_text2 <-
  helpText(
    strong(
      'Start with the peril box and work your way down the page, bearing in mind 
       any recommendations the tool makes regarding your selections.'
    ),
    "Once you are happy with your selections click on ",
    strong("Load Hazard Data"),
    "before moving to the next step.",
    br(),
    br(),
    strong("Worldwide tropical cyclone can be modelled using IBTrACS data and 
    worldwide drought using the CHIRPs data"), 
    "(more info on these data sources can be found on the help page)", 
    strong("Stochastic hazard sets are also available for a limited range of 
    regions."), 
    "These are Bangladesh (Oasis) and the Ginoza region of 
    Japan (Aon IF) for tropical cyclone. There is also a  stochastic event set 
    available for Karachi in Pakistan (Aon IF)",
    "Future versions of this tool will look to cover additional perils and 
    datasets.",
    br(),
    br()
  )

h_select_peril_data_UI <- function(id) {
  ns <- NS(id)
  tagList(
    h4(' Choose your peril, region and selected data'),
    hazard_text2,
    selectInput(
      ns("peril_select"),
      label = 'Peril',
      choices = NULL,
      selected = ""
    ),
    selectInput(
      ns("dataset_select"),
      label = 'Data Source',
      choices = NULL,
      selected = ""
    )
  )
}

h_select_peril_data_Server <- function(id, h_mappings) {
  moduleServer(
    id,
    function(input, output, session) {
      
      updateSelectInput(session,
                        inputId = "peril_select",
                        selected = "",
                        choices = unique(h_mappings$peril))

      observe({
        req(input$peril_select)
        
        updateSelectInput(session,
                          inputId = "dataset_select",
                          selected = "",
                          choices = filter_and_select_column(
                            h_mappings,
                            unique = TRUE,
                            vec_type = "character",
                            column_to_select = "dataset",
                            peril == input$peril_select)
        )
      })
      
      choices_map_data <- reactive({
        
        req(input$peril_select, input$dataset_select)
        
        filtered_mappings <-
          filter_and_select_column(
          h_mappings,
          unique = FALSE,
          vec_type = "dataframe",
          column_to_select = c("region_name",
                               "poly_lng",
                               "poly_lat"),
          peril == input$peril_select&
            dataset == input$dataset_select)
        
        if(nrow(filtered_mappings)!= 0){
          pull_sf_mapping_data(filtered_mappings)
        }else{
            
        }
        
      })
      
      return(
        list(
          peril_choice = reactive(input$peril_select),
          dataset_choice = reactive(input$dataset_select),
          choices_map_data = choices_map_data
        )
      )
      
    }
  )
}
