st_payout_summary_text <-
  helpText(
    "This plot displays the distribution of individual simulation payouts, 
    with each simulation being a simulation of events occurring within the 
    exposure area from the stochastic modelled set.",
    br(),br(),
    "The red line represents all simulation-years ranked from the highest to 
    lowest payouts, split into ",
    tags$a("percentiles",
           href="https://oasislmf.github.io/RiskExplorer/components/index_Glossary.html#percentile",
           target="_blank"),
    ". The blue line represents the average payout across all simulations."
  )

st_payout_summary_text2 <-
  helpText(
    strong("Simulated Payout:"),
    "This is the only method of calculating the expected loss when using 
    the stochastic engine. It simply represents the average 
    annual payout across all simulated years.",
    br(),
    br(),
    "The table also shows the standard deviation which gives an estimate of the 
     variability of the payout. The higher the standard deviation, the more 
     variability there is in payouts across years/simulations. This variability 
     is often equated with uncertainty and is one of the additional factors 
     considered when structuring and pricing insurance contracts."
  )

drought_payout_summary_text <-
  helpText(
    "This plot displays the distribution of individual simulation-years, 
    with each simulation being a combination of the conditions in a particular 
    calendar year and a particular distribution of policyholders over the 
    exposure area.",
    br(),br(),
    "The red line represents all simulation-years ranked from the highest to 
    lowest payouts, split into ",
    tags$a("percentiles",
           href="https://oasislmf.github.io/RiskExplorer/components/index_Glossary.html#percentile",
           target="_blank"),
    ". The blue line represents the average payout across all simulations."
  )

drought_payout_summary_text2 <-
  helpText(
    strong("Simulated Payout:"),
    "This is the only method of calculating the expected loss when using 
    the drought simulation framework. It simply represents the average 
    annual payout across all simulations and historic years.",
    br(),
    br(),
    "The table also shows the standard deviation which gives an estimate of the 
     variability of the payout. The higher the standard deviation, the more 
     variability there is in payouts across years/simulations. This variability 
     is often equated with uncertainty and is one of the additional factors 
     considered when structuring and pricing insurance contracts."
  )

tc_payout_summary_text <-
  helpText(
    "Exhibit 5 shows estimates of the expected payout under different 
    calculation methods as well as the full distribution of the simulation 
    output.
    The distribution shown on the graph by the solid red line orders the 
    simulation-years ranked from the highest to lowest payouts, split into ",
    tags$a("percentiles",
           href="https://oasislmf.github.io/RiskExplorer/components/index_Glossary.html#percentile",
           target="_blank"),
    "so you can see the range of outcomes you might 
    expect.",
    "Each value represents an individual simulation-year, i.e. the payouts 
    across a particular year of the history for a particular spatial sample.",
    "The expected payout under different methods is also displayed by horizontal 
    lines on the graph. The text below the graph describes what each method means 
    and how it works.",
    br()
  )

tc_payout_summary_text2 <-
  helpText(
    tags$ul(
      tags$li(
        strong("Historical Payout: "),
        "This method takes an average over the history for your exposure point 
         or area. Simulations don't factor in to this method at all and this 
         method can simply be thought of as an annual average of the payouts 
         sustained over the period."
      ),
      br(),
      tags$li(
        strong("Unweighted Simulation Payout: "),
        "This is the average annual payout across all your simulations with no 
         weighting for proximity to the exposure applied.",
        tags$a(
          "More detail on the simulation approach can be found on the help 
          page.",
          href = "https://oasislmf.github.io/RiskExplorer/components/index_SimMethod.html",
          target = "_blank"
        )
      ),
      br(),
      tags$li(
        strong("Weighted Simulation Payout: "),
        "This is the average annual payout across all your simulations including 
        the weighting for proximity to the exposure applied.",
        tags$a(
          "More detail on the simulation approach can be found on the help page.",
          href = "https://oasislmf.github.io/RiskExplorer/components/index_SimMethod.html",
          target = "_blank"
        )
      ),
      br()
    ),
    "The table also shows the standard deviation which gives an estimate of the 
    variability of the payout. The higher the standard deviation, the more 
    variability there is in payouts across years/simulations. This variability is 
    often equated with uncertainty and is one of the additional factors 
    considered when structuring and pricing insurance contracts."
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
            dplyr::mutate(`Policyholders Impacted` = 
                            quantile(sim_output()$data_sim_year$`Localities Paid`, 
                                     type = 2, 
                                     probs = seq(0, 1, by = 0.001)))
          
          summary_text1 <- drought_payout_summary_text
          summary_text2 <- drought_payout_summary_text2
          
        } else if ((sim_output()$peril == "Windstorm" &
                   sim_output()$dataset == "IBTrACS" |
                   sim_output()$dataset == "Stochastic")) {
        
          payout_metrics <- sim_output()$expected_loss_metrics
          
          
          if(sim_output()$dataset == "IBTrACS") {
            summary_text1 <- tc_payout_summary_text
            summary_text2 <- tc_payout_summary_text2  
          } else {
            summary_text1 <- st_payout_summary_text
            summary_text2 <- st_payout_summary_text2
          }
          
          
        }
          
        output$loss_summary_ui <-
          renderUI({
            tagList(
              h4("Exhibit 5: Simulated Payout Distribution and Expected Loss"),
              summary_text1,
              plotlyOutput(ns("payout_summary_plot")),
              tableOutput(ns("payout_summary_table")),
              summary_text2
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
          bordered = TRUE)
       
      })
      
    }
  )
}
