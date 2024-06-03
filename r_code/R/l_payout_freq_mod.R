payout_freq_text_tc <- 
  helpText(
    strong("Exhibit 4 shows the distribution of payout 
      amounts over the course of a year"),
    "E.g., if the red bar shows 90% for a payout 
    of zero, then 90% of simulation-years lead to a total payout of zero. The 
    table below provides some more context, displaying the relevant",
    tags$a("percentile",
           href = "https://oasislmf.github.io/RiskExplorer/components/index_Glossary.html#percentile",
           target = "_blank"), 
    "and weighting.",
    br(),br(),
    "Note that where ranges are displayed, these 
    include the higher amount and exclude the lower amount e.g.,0-20,000 USD 
    would exclude payouts of zero but include payouts of USD 20,000."
  )

payout_freq_text_drought <- 
  helpText(
    strong("Exhibit 4 shows the distribution of individual policyholder payout 
      amounts over the course of a year"),
    "E.g., if the red bar shows 90% for a payout 
    of zero, then 90% of the time in the simulations, an individual policyholder 
    will receive a payout of zero. The table below provides some context, 
    displaying the relevant",
    tags$a("percentiles",
           href = "https://oasislmf.github.io/RiskExplorer/components/index_Glossary.html#percentile",
           target = "_blank"), 
    ".",
    br(),br(),
    "Note that where ranges are displayed, these 
    include the higher amount and exclude the lower amount e.g.,0-20,000 USD 
    would exclude payouts of zero but include payouts of USD 20,000."
  )


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
          if(sim_output()$peril == "Drought") {
            sim_output()$data_individual_sim  
          } else {
            sim_output()$data_sim_year
          }
        
        payout_freq_data <- 
            process_payout_freq_data(
              payout_freq_data,
              display_var = display_var, 
              display_fun = display_fun,
              peril = sim_output()$peril,
              value_per_insured = 
                ifelse( sim_output()$peril == "Drought", 
                        sim_output()$value_per_insured,
                        1)
            )

        output$payout_freq_plot <-
          renderPlotly({
            generate_payout_freq_plot(payout_freq_data,
                                      peril = sim_output()$peril,
                                      display_var = display_var)
          })
        
        output$payout_freq_DT <-
          renderDT({
            
            # options(warn = -1)
            
            payout_freq_data |> 
              dplyr::select(-Percentage) |> 
              DT::datatable(rownames = FALSE,
                            callback = 
                              DT::JS("$.fn.dataTable.ext.errMode = 'throw';"))
          })
        
        output$payout_freq_ui <-
          renderUI({
            
            payout_freq_text <-
              if( sim_output()$peril == "Drought"){
                payout_freq_text_drought                  
              } else {
                payout_freq_text_tc                  
              }
            
            tagList(
              h4("Exhibit 4: Payout Frequency Summary"),
              payout_freq_text,
              plotlyOutput(ns("payout_freq_plot")),
              DTOutput(ns("payout_freq_DT"))
            )
            
          })
          
      })
      
    }
  )
}
