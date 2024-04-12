drought_text <-
  helpText(
    "This plot displays the distribution of individual simulation years, 
    with each simulation being a combination of the conditions in a particular 
    calendar year and a sparticular distribution of policholders over the exposure 
    area.",
    br(),
    "The red line represents all simulations ranked from the highest to lowest 
    payouts. The blue line represents the average outcome across all simulations."
  )


l_payout_summary_UI <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns('loss_summary_ui'))
  )
}

l_payout_summary_Server <- function(id, sim_output, display_var, display_fun) {
  moduleServer(
    id,
    function(input, output, session) {
      
      observe({
        req(sim_output())
        
        ns <- session$ns
        
        payout_percentiles <-
          data.frame(
            Percentile = seq(0, 1, by = 0.001),
            Payout = quantile(sim_output()$data_sim_year$Payout, 
                              type = 2, 
                              probs = seq(0, 1, by = 0.001) ),
            check.names = FALSE
          )
        
        # Not sure there is a need for these extra payout_metrics calcs, can 
        # we not just pull in expected_loss_metrics from sim output?
        
        if(sim_output()$peril == "Drought") {
        
          payout_metrics <-
            calc_loss_metrics(
              sim_output()$data_sim_year, 
              peril = sim_output()$peril, 
              methods = "Historical Simulation",
              total_value = sim_output()$value_per_insured *
                sim_output()$number_localities,
              display_fun = display_fun
            )
          
          payout_percentiles <-
            payout_percentiles |> 
            dplyr::mutate(`Insured Impacted` = 
                            quantile(sim_output()$data_sim_year$`Localities Paid`, 
                                     type = 2, 
                                     probs = seq(0, 1, by = 0.001)))
            
        } else if (sim_output()$peril == "Windstorm" &
                   sim_output()$dataset == "IBTrACS") {
        
          payout_metrics <- sim_output()$expected_loss_metrics 
        }
          
        output$loss_summary_ui <-
          renderUI({
            tagList(
              h4("Exhibit 5: Simulated Payout Distribution and Expected Loss"),
              drought_text,
              plotlyOutput(ns("payout_summary_plot")),
              tableOutput(ns("payout_summary_table"))
            )
          })
        
        output$payout_summary_plot <- 
          renderPlotly({
            
            l_generate_sim_summary_plot(plot_data = payout_percentiles, 
                                        hline_data = payout_metrics, 
                                        peril = sim_output()$peril, 
                                        dataset = sim_output()$dataset,
                                        display_var = display_var,
                                        display_fun = display_fun)
                                                    
          })
        
        output$payout_summary_table <- 
          renderTable({
            if( sim_output()$peril == "Drought") {
              table_var <- paste("Simulated", display_var)
              
              sim_output()$expected_loss_metrics |>
                dplyr::mutate(
                  !!sym(table_var) := 
                    display_fun(!!sym(table_var))
                ) |> 
                dplyr::select(Measure, !!sym(table_var))
            } else {
              
              sim_output()$expected_loss_metrics |>
                dplyr::mutate(
                  dplyr::across(
                    .cols = dplyr::contains("Payout")|
                      dplyr::contains("Simulated"),
                    .fns = display_fun
                  )
                )
            }
          },
          bordered=TRUE)
       
      })
      
    }
  )
}
