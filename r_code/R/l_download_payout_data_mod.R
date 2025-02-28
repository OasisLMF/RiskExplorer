# In-app text is in Server section

l_download_payout_data_UI <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns('loss_download_ui'))
  )
}

l_download_payout_data_Server <- function(id, sim_output) {
  moduleServer(
    id,
    function(input, output, session) {
      
      observe({
        
        req(sim_output())
        
        ns <- session$ns
        
        download_text <- 
          reactive({
            if(sim_output()$peril == "Drought") {
              helpText(
                "This section allows the user to export the results of the 
                 simulation model to an Excel file. There are two output files 
                 that can be downloaded:",
                br(),
                br(),
                tags$ul(
                  tags$li(
                    strong("Output by Simulation:"),
                    "Each row in this file represents an individual simulation 
                    of policyholder locations within the exposure area. The file 
                    gives the total payout averaged across all the historical 
                    years of data for each simulation."
                  ),
                  br(),
                  tags$li(
                    strong("Output by Simulation/Sim-Year:"),
                    "Each row in this file displays payout information for a 
                    given simulation and year of the history."
                  )
                ),
                br(), 
                br())
            } else if (sim_output()$peril == "Windstorm") { 
              helpText(
                "This section allows the user to export the results of the 
                simulation model to an Excel file. There are two output files that
                can be downloaded:",
                br(),
                br(),
                tags$ul(
                  tags$li(
                    strong("Output by Simulation:"),
                    "Each row in this file represents an individual simulated 
                     location/area on the map. The file gives the total loss 
                     averaged across all the historical years of data for each 
                     simulation, as well as the weighting that it is given in 
                     the final simulation calculation. The further away the 
                     simulated area is from the area of exposure, the lower the 
                     weighting given."
                  ),
                  br(),
                  tags$li(
                    strong("Output by Simulation/Sim-Year:"),
                    "Each row in this file represents the loss for a given year 
                     of the history for each simulation."
                  )
                ),
                br(),
                br()
              ) 
            } else {
              
              helpText(
                "This section allows the user to export the results of the 
                 simulation model to an Excel file. There is one output file 
                 that can be downloaded:",
                 br(),
                 br(),
                 tags$ul(
                  tags$li(
                    strong("Output by Simulation:"), 
                    "Each row in this file represents an individually simulated 
                     year from the hazard dataset. The file gives the total loss 
                     for each simulated year of data."
                      )
                    )
                )
            }
          })
          
          output$loss_download_ui <-
            renderUI({
              tagList(
                h4("Export Results to Excel"),
                  download_text(),
                  downloadButton(
                    ns("download_sim_year_data"),
                    label = "Download summary output for each simulation"
                  ),
                  br(),
                  br(),
                  downloadButton(
                    ns("download_sim_year_loc_data"),
                    label = "Download detailed output for each simulation"
                  ),
                  br(),
                  br()
              )
            })
          
          output$download_sim_year_data <- downloadHandler(
            filename = function() {
              paste(
                'risk_explorer_',
                tolower(sim_output()$peril),
                '_sim_year_output_data_', 
                Sys.Date(),
                '.csv', 
                sep = ''
              )
            },
            content = function(con) {
              write.csv(sim_output()$data_sim_year, con)
            }
          )
            
          output$download_sim_year_loc_data <- downloadHandler(
            filename = function() {
              paste(
                'risk_explorer_',
                tolower(sim_output()$peril),
                '_sim_year_loc_output_data_', 
                Sys.Date(),
                '.csv', 
                sep = ''
              )
            },
            content = function(con) {
              write.csv(sim_output()$data_individual_sim, con)
            }
          )
      })
        
    }
  )
}
