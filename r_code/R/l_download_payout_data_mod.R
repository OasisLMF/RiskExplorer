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
             "Drought Test" 
            } else if (sim_output()$peril == "Windstorm") { 
              "TC Test" 
            } else {
              "Other Test"
            }
          })
          
          output$loss_download_ui <-
            renderUI({
              tagList(
                h4("Export Results to Excel"),
                fluidRow(
                  download_text(),
                  downloadButton(
                    ns("download_sim_year_data"),
                    label = "Download summary output for each simulation"
                  ),
                  downloadButton(
                    ns("download_sim_year_loc_data"),
                    label = "Download detailed output for each simulation"
                  )
                )
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
