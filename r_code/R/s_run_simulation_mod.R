s_run_simulation_UI <- function(id) {
  ns <- NS(id)
  
  tagList(
    h4("Choose how many simulations to run"),
    selectInput(ns("sims_n"),
                label = 'Number of Sims to Run',
                choices = c(500, 1000, 2000, 5000, 10000), selected = 500),
    actionButton(ns("sims_run"),"Run Simulation"),
    htmltools::br(),
    htmltools::br()
  )
}

s_run_simulation_Server <- function(id, 
                                    hazard_data, 
                                    exposure_data, 
                                    vulnerability_data,
                                    pentad_mappings,
                                    vulnerability_mappings) {
  moduleServer(
    id,
    function(input, output, session) {
      
      observe({
        req(hazard_data$tab_check_ok())
        
        if(hazard_data$selected_hazard_mappings()["peril"] == "Drought"){
          updateSelectInput(session = session,
                            inputId = "sims_n",
                            choices = c(25, 50, 75, 100),
                            selected = 25)  
        }else if (hazard_data$selected_hazard_mappings()["peril"] != "Drought"){
          updateSelectInput(session = session,
                            inputId = "sims_n",
                            choices = c(500, 1000, 2000, 5000, 10000), 
                            selected = 500)
        }
        
      })
      
      
      observeEvent(input$sims_run, {
        
        if(hazard_data$tab_check_ok() != TRUE|
           exposure_data$tab_check_ok() != TRUE|
           vulnerability_data$tab_check_ok() != TRUE|
           !isTruthy(input$sims_n)){
          
          showNotification("Your inputs are incomplete, please revisit the 
                             earlier tabs")
        }
      
      })
      
      sim_output <-
        eventReactive(input$sims_run, {
          
          req(hazard_data$tab_check_ok(),
              exposure_data$tab_check_ok(),
              vulnerability_data$tab_check_ok(),
              input$sims_n)
          
          progress_bar <<- shiny::Progress$new()
          on.exit(progress_bar$close())
          progress_bar$set(message = "Running Simulations", value = 0)
          
          peril <- hazard_data$selected_hazard_mappings()["peril"]
          dataset <- hazard_data$selected_hazard_mappings()["dataset"]
          
          if(peril == "Drought"){
              
              run_drought_simulation_script(
                hazard_data = hazard_data,
                exposure_data = exposure_data,
                vulnerability_data = vulnerability_data,
                sims_n = input$sims_n,
                pentad_mappings = pentad_mappings)
            
            
          }else if (peril == "Windstorm" &
                    dataset == "IBTrACS Historical Data"){
            # does IBTrACS Hist Data need trimmed for blanks??
            
            run_TC_ibtracs_simulation_script(
              hazard_data = hazard_data,
              exposure_data = exposure_data,
              vulnerability_data = vulnerability_data,
              vulnerability_mappings = vulnerability_mappings,
              sims_n = input$sims_n)
            
          }else if (peril == "Winstorm" &
                    dataset == "Stochastic"){
            
            run_TC_stochastic_simulation_script(
              hazard_data = hazard_data,
              exposure_data = exposure_data,
              vulnerability_data = vulnerability_data,
              sims_n = input$sims_n)
            
          }else if (peril == "Earthquake" &
                    dataset == "Stochastic") {
            
            run_EQ_stochastic_simulation_script(
              hazard_data = hazard_data,
              exposure_data = exposure_data,
              vulnerability_data = vulnerability_data,
              sims_n = input$sims_n)
            
          }
        })
      
      return(sim_output)
      
    }
  )
}