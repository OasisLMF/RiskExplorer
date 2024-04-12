drought_text <-
  helpText(
    "This plot displays the distribution of payouts received in each calendar 
    year across all simulated policyholder locations within the exposure area",
    br(),
    "The red dot represents the average total payout across all policyholders for
    a given calendar year's rainfall. The red lines show the minimum and maximum 
    across all simulations and the range within which the closest to the median 
    fall"
  )

tc_ibtracs_text <-
  helpText("test")

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
                  drought_text,
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
                tc_ibtracs_text,
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
              sim_output()$data_hist |>
                dplyr::select(
                  Longitude, Latitude, !!sym(sim_output()$intensity_measure), 
                  `Storm Name`, Year, `Storm ID`,Payout 
                )|>
                dplyr::mutate(
                  Payout = display_fun(Payout),
                   Longitude = label_comma(accuracy = 0.0001)(Longitude), 
                   Latitude = label_comma(accuracy = 0.0001)(Latitude),
                  !!sym(sim_output()$intensity_measure) :=
                    label_comma(accuracy = 0.1)(!!sym(sim_output()$intensity_measure))
                )|>
                DT::datatable(rownames = FALSE)
            })
          
        } else if(sim_output()$dataset == "Stochastic") {
          
          tagList(
            h4("Exhibit 1: Historical Loss Summary")
          )
          
        }
      
      }) 
    }
  )
}
