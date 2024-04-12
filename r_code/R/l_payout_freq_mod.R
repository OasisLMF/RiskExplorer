drought_text <- "Placeholder Text for Exhibit 4"
  
l_payout_freq_UI <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns('payout_freq_ui'))
  )
}

l_payout_freq_Server <- function(id, sim_output, display_var, display_fun) {
  moduleServer(
    id,
    function(input, output, session) {
      observe({
        
        req(sim_output())
        ns <- session$ns
          
          payout_freq_data <- 
            reactive({
              process_payout_freq_data(
                sim_output()$data_individual_sim,
                display_var = display_var, 
                display_fun = display_fun, 
                value_per_insured = 
                  ifelse( sim_output()$peril == "Windstorm", 
                          1, 
                          sim_output()$expo_value)
              )
            })
          
          output$payout_freq_plot <-
            renderPlotly({
              req(payout_freq_data())
              browser()
              generate_payout_freq_plot(payout_freq_data(), 
                                        display_var = display_var)
            })
          
          output$payout_freq_DT <-
            renderDT({
              req(payout_freq_data())
              
              options(warn = -1)
              
              payout_freq_data() |> 
                dplyr::select(-Percentage) |> 
                DT::datatable(rownames = FALSE,
                              callback = 
                                DT::JS("$.fn.dataTable.ext.errMode = 'throw';"))
            })
          
          output$payout_freq_ui <-
            renderUI({
              tagList(
                h4("Exhibit 4: Payout Frequency Summary"),
                drought_text,
                plotlyOutput(ns("payout_freq_plot")),
                DTOutput(ns("payout_freq_DT"))
              )
            })
          
      })
      
    }
  )
}
