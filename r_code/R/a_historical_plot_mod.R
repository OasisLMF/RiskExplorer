drought_hist_plot_text <-
  helpText(
    strong("Exhibit 1 aims to answer the question of which years of  
          historical observational data would have led to payouts in your area 
          of exposure, and the range of uncertainty around them introduced by 
          the simulation process."),
    "This plot displays the distribution of total payouts to all policyholders  
    across all calendar years and simulations.",
    br(),
    "The red dot represents the average total payout to all policyholders for
    a given calendar year's rainfall. The light grey line shows the full range 
    of simulated values across a given year (i.e. the lowest and highest payouts 
    across all simulations for a calendar year). The black line shows the range 
    within which the 50% of simulations closest to the average fall."
  )

tc_hist_plot_text <-
  helpText(
    strong("Exhibit 1 aims to answer the question of which events in the 
          historical data would have led to losses in your area of exposure,
          leaving aside the simulation modelling."),"The map displays historical 
          tracks for any events that would have led to losses based on the 
          model's assumptions (i.e. would have fallen within the exposure loss 
          radius,",
    tags$a("see help page for more information on this",
           href = "https://oasislmf.github.io/RiskExplorer/components/index_SimMethod.html",
           target = "_blank"),
    "). The table below provides a summary of each event that would have led to losses. Averaging the losses from these events across the number of years should give the 
          Historic Loss shown on the Loss Analysis tab.",strong("This is also sometimes referred to as the \"cat-in-a-box\" or \"cat-in-a-circle\" 
          loss in the insurance industry."),
    br(),
    br(),
    "Note that in many cases tracks are not precise as data is only available 
        at 3-6 hour intervals which requires estimates to be made via 
        interpolation between those points. As such, tracks may not exactly 
        match what you see on the hazard tab map as the storm track data used in 
        this exhibit comes directly from the tool and is more precise."
  )

a_historical_plot_UI <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns('historical_plot_ui'))
  )
}

a_historical_plot_Server <- function(id, sim_output, display_var, display_fun) {
  moduleServer(
    id,
    function(input, output, session) {
     
      observe({
        
        req(sim_output())
        
        ns <- session$ns
        
        if(sim_output()$peril == "Drought") {
          
          output$historical_plot_ui <-
            renderUI({
                tagList(
                  h4("Exhibit 1: Historical Years Payout Summary"),
                  drought_hist_plot_text,
                  tableOutput(ns("drought_hist_summary_table")),
                  plotlyOutput(ns("drought_hist_plot")),
                  DTOutput(ns("drought_hist_DT"))
                )
              })
          
          output$drought_hist_summary_table <-
            renderTable({
              data.frame(
                `Year Start` = as.integer(sim_output()$year_start),
                `Year End` = as.integer(sim_output()$year_end),
                `Number of Years` = 
                  as.integer(
                    sim_output()$year_end - sim_output()$year_start + 1
                  ),
                check.names = FALSE
              )
            })
          
          output$drought_hist_plot <-
            renderPlotly({
              generate_hist_plot_drought(
                plot_data = sim_output()$data_sim_year,
                display_var = display_var,
                display_fun = display_fun
              )
            })
          
          output$drought_hist_DT <-
            renderDT({
              generate_hist_dt_drought(
                table_data = sim_output()$data_sim_year,
                display_var = display_var
              )
            })
          
        } else if(sim_output()$peril == "Windstorm" &
                  sim_output()$dataset == "IBTrACS") {
        
          output$historical_plot_ui <-
            renderUI({
              tagList(
                h4("Exhibit 1: Historical Years Payout Summary"),
                tc_hist_plot_text,
                tableOutput(ns("tc_hist_summary_table")),
                leafletOutput(ns("tc_hist_map")),
                DTOutput(ns("tc_hist_DT"))
              )
            })
          
          output$tc_hist_summary_table <-
            renderTable({
              
              data.frame(
                `Year Start` = as.integer(sim_output()$year_start),
                `Year End` = as.integer(sim_output()$year_end),
                `Number of Years` = 
                  as.integer(
                    sim_output()$year_end - sim_output()$year_start + 1
                  ),
                `Historical Payout` =
                  display_fun(
                    sim_output()$expected_loss_metrics$`Historical Payout`[1]
                  )
                ,
                check.names = FALSE
              )
            })
          
          output$tc_hist_map <-
            renderLeaflet({
              generate_hist_map_tc(
                sim_output()$data_hist_map,
                expo_ll = sim_output()$expo_ll, 
                expo_radius = sim_output()$expo_radius
              )
            })
          
          output$tc_hist_DT <-
            renderDT({
              
              # Turn this into function
              dt_data_hist <-
              sim_output()$data_hist |>
                dplyr::select(
                  Longitude, Latitude, !!sym(sim_output()$intensity_measure), 
                  `Storm Name`, Year, `Storm ID`,Payout 
                )
              
              scaling_factor <-
                ifelse(
                  display_var == "Payout as % of Asset Value",
                  1,
                  sim_output()$expo_value 
                )
              
              dt_format_fun <- 
                if(display_var == "Payout as % of Asset Value") {
                  purrr::partial(
                    formatPercentage, 
                    digits = 2
                  )
                } else {
                  purrr::partial(
                    formatCurrency, 
                    currency = "",
                    digits = 0
                  )
                }
              
                dt_data_hist |> 
                dplyr::arrange(Year) |> 
                dplyr::mutate(Payout = Payout * scaling_factor) |> 
                datatable(rownames = FALSE) |> 
                DT::formatCurrency(
                  columns = c("Longitude", "Latitude"),
                  currency = "",
                  digits = 4
                ) |> 
                DT::formatCurrency(
                  columns = grep("Speed|Pressure", colnames(dt_data_hist)),
                  currency = "",
                  digits = 1
                ) |> 
                dt_format_fun(
                  columns = c("Payout")
                )
              
            })
          
        } else if(sim_output()$dataset == "Stochastic") {
        
          output$historical_plot_ui <-
            renderUI({
              tagList(
                h4("Exhibit 1: Historical Loss Summary"),
                helpText(
                  "There is no historical data available for stochastic sets. To 
                  see a summary of historical events, re-run with IBTrACS data"
                )
              )
            })
        }
      
      })
    }
  )
}
