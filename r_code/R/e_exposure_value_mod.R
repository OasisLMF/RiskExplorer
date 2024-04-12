e_exposure_value_UI <- function(id) {
  ns <- NS(id)
  tagList(
    conditionalPanel(
      condition = "output.non_drought_peril",
      ns = ns,
      h4("Step 3: Enter your Asset Value and Currency"),
      helpText("Enter an asset value greater than zero and select the 
               appropriate currency."),
      fluidRow(
        column(4,
               autonumericInput(ns("non_drought_total_value"), 
                                label = "Asset Value",
                                value = 0,
                                digitGroupSeparator = ",",
                                decimalPlaces = 0)),
        column(4,
               selectInput(ns("non_drought_curr"),
                           label = "Currency",
                           choices = NULL)))
    ),
    conditionalPanel(
      condition = "output.drought_peril",
      ns = ns,
      h4("Step 3: Enter your Policy Currency, Policy Value and the Number of 
         Policies issued"),
      helpText("Enter an asset value and a policy count greater than zero and select the 
               appropriate currency."),
      fluidRow(
        column(4,
               autonumericInput(ns("drought_policy_value"), 
                                label = "Policy Value",
                                value = 0,
                                digitGroupSeparator = ",",
                                decimalPlaces = 0)),
        column(4,
               selectInput(ns("drought_curr"),
                           label = "Currency",
                           choices = NULL))),
      fluidRow(
        column(4,
               numericInput(ns("drought_policy_count"),
                            label = "Number of Policies",
                            value = 1,
                            min = 1,
                            max = 100,
                            step = 1)),
        column(4,
               tableOutput(ns("drought_policy_value")))
      ),
      htmltools::span(uiOutput(ns("policy_count_error_message"), 
                               style = "color:red;font-size:16px")),
    )
  )
}

e_exposure_value_Server <- function(id, selected_hazard_mappings, curr_codes) {
  moduleServer(
    id,
    function(input, output, session) {
      
      updateSelectInput(session = session, inputId = "drought_curr", 
                        choices = curr_codes, selected = "USD")
      
      updateSelectInput(session = session, inputId = "non_drought_curr", 
                        choices = curr_codes, selected = "USD")
      
      section_ok <- reactiveVal(NULL)
      
      exposure_value_parameters <- 
        reactiveValues(peril = NULL,
                       total_value = NULL,
                       curr = NULL,
                       policy_count = NULL)
      
      output$non_drought_peril <- 
        reactive({
          tryCatch({
            
            isTruthy(selected_hazard_mappings()["peril"]) 
            if(selected_hazard_mappings()["peril"] == "Windstorm"|
               selected_hazard_mappings()["peril"] == "Earthquake"){
              exposure_value_parameters$peril <- 
                selected_hazard_mappings()["peril"]
              TRUE
            }else{
              FALSE
            }
          },
          shiny.silent.error = function(e) {
            FALSE
          })
        })
      
      output$drought_peril <- 
        reactive({
          tryCatch({
            
            isTruthy(selected_hazard_mappings()["peril"]) 
            if(selected_hazard_mappings()["peril"] == "Drought"){
              exposure_value_parameters$peril <- 
                selected_hazard_mappings()["peril"]
              TRUE
            }else{
              FALSE
            }
          },
          shiny.silent.error = function(e) {
            FALSE
          })
        })
      
      outputOptions(output, "drought_peril", suspendWhenHidden = FALSE)  
      outputOptions(output, "non_drought_peril", suspendWhenHidden = FALSE)
      
      drought_policy_value <- 
        reactive({
          req(exposure_value_parameters$peril == "Drought",
              input$drought_policy_count,
              input$drought_policy_value,
              input$drought_curr)
          
          input$drought_policy_count * input$drought_policy_value
        })
      
      observe({
        req(exposure_value_parameters$peril)
        
        if(exposure_value_parameters$peril == "Drought"){
          req(input$drought_policy_count, input$drought_policy_value, 
              input$drought_curr)
          
          exposure_value_parameters$policy_count <- 
            if(is.null(input$drought_policy_count)){
              0
            } else {
              input$drought_policy_count
            }
            
          exposure_value_parameters$total_value <- 
            input$drought_policy_count *input$drought_policy_value
          
          exposure_value_parameters$curr <- input$drought_curr
          
        }else if(exposure_value_parameters$peril == "Windstorm"|
                 exposure_value_parameters$peril == "Earthquake"){
          
          req(input$non_drought_total_value, input$non_drought_curr)
          
          exposure_value_parameters$policy_count <- 1
          
          exposure_value_parameters$total_value <- input$non_drought_total_value
          
          exposure_value_parameters$curr <- input$non_drought_curr
        }
      })
      
      observe({
        req(exposure_value_parameters$policy_count)
        
        output$policy_count_error_message <- 
          renderText({
            
            if(exposure_value_parameters$policy_count > 100 | 
               exposure_value_parameters$policy_count < 1) 
            {
              "Please Enter a Policy Count between 1 and 100" 
            } else {
              NULL
            }    
        
          })
      })
      
      output$drought_policy_value <-
        renderTable({
          if(is.null(drought_policy_value())){
            data.frame(`Total Value` = "N/A")
          }else{
            data.frame(`Total Value` = 
                         scales::dollar(drought_policy_value(),
                                        prefix = "",
                                        accuracy = 1,
                                        suffix = input$drought_curr),
                       check.names = FALSE)
          }
        })
      
      observe({
        
        section_ok(FALSE)
        req(exposure_value_parameters$peril,
            exposure_value_parameters$total_value,
            exposure_value_parameters$curr)
        
        if(exposure_value_parameters$peril == "Drought" &
           exposure_value_parameters$total_value > 0 &
           exposure_value_parameters$policy_count <= 100
           ) {
          req(exposure_value_parameters$policy_count)
          section_ok(TRUE)
        }else if(
          exposure_value_parameters$peril != "Drought" &
          exposure_value_parameters$total_value > 0) {
          section_ok(TRUE)
        }

      })
      
      return(list(exposure_value_parameters = exposure_value_parameters,
                  section_ok = section_ok))
      
    }
  )
}
