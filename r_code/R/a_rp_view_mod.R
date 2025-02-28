drought_rp_view_text <-
  helpText(
    strong(
      "Exhibit 3 displays the total payout from all policies using a return 
      period metric. Higher return period payouts are more extreme and rarer."
      ),
    "The aim of this plot is to give a representation of how frequently large 
    payout years will typically occur.",
    br(),br(),
    strong("Return Period"), "refers to the average time you would have to wait 
    before observing a total payout / number of people impacted of a given value 
    or above. E.g., a return period of 5 years for a  $100,000 total payout would 
    mean you would wait 5 years to see payouts totalling over $100,000 every 
    on average. Note that this return period is an average and doesn't mean it 
    will always be exactly 5 years.",
  )

tc_rp_view_text <-
  helpText(
    strong(
      "Exhibit 3 gives an estimate of how often storms/earthquakes of each 
      Saffir-Simpson/MMI category occur in the history (if relevant) and 
      simulation output:"
    ),
    br(),
    br(),
    tags$ul(
      tags$li(
        strong("Frequency"),
        " refers to the number of storms/earthquakes of this category or above 
        you would expect to see in a year. A frequency of 1 means that a storm 
        would occur on average once a year."
      ),
      br(),
      tags$li(
        strong("Return Period"),
        "refers to the average time you would have to wait before observing a 
        storm of that category or above, e.g., a return period of 5 years for a 
        cat 2 storm means you would expect to have one storm at cat 2 or above 
        every 5 years on average. "
      )
    ),
    br(),
    "This exhibit should be useful for getting an idea of how common storms of 
    each category are around your area of exposure as well as comparing the 
    results of different simulation methods where available. Of course this is an 
    average, and it is possible to have two 100-year events occur in subsequent 
    years. Another way to think about return periods is the probability of 
    occurrence in any given year. A 10-year return period means there is a 1 in 
    10 (10%) chance of it happening in any given year. Note that the wind 
    speed/pressure denotes where the category \"starts\", so represents a 
    minimum for wind speed and a maximum for pressure.",
    br()
  )

a_rp_view_UI <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("rp_view_ui"))
  )
}

a_rp_view_Server <- function(id, sim_output, display_var, display_fun) {
  moduleServer(
    id,
    function(input, output, session) {
      
      observe({
        
        req(sim_output())
        
        ns <- session$ns
        
        if(sim_output()$peril == "Drought"){
          
          output$rp_view_ui <-
            renderUI({
              tagList(
                h4("Exhibit 3: Return Period Summary"),
                drought_rp_view_text,
                fluidRow(
                  column(width = 9,
                         plotlyOutput(ns("drought_rp_view"))
                    ),
                  column(width = 9,
                         DTOutput(ns("drought_rp_table"))
                  )
                )
              )
            })
          
          sim_rp_calc <- 
            reactive({
              gen_rps(
                sim_output()$data_sim_year, 
                n = nrow(sim_output()$data_sim_year), 
                var  = display_var
              )
            })
          
          output$drought_rp_view <-
            renderPlotly({
              
              req(sim_rp_calc())
              
              max_var <- 
                sim_output()$number_localities *
                ifelse(display_var == "Payout",
                       sim_output()$value_per_insured, 
                       1) 
                     
              generate_rp_plot_drought(
                plot_data = sim_rp_calc(), 
                display_var = display_var,
                display_fun = display_fun,
                max_var = max_var 
              )
            }) 
          
          output$drought_rp_table <-
            renderDT({
              
              req(sim_rp_calc())
              
              data.frame(
                `Return Period` = c(2, 5, 10, 15, 20, 25, 30, 35),
                check.names = FALSE
              ) |>
              dplyr::mutate(
                !!sym(display_var):=
                  approx(
                    sim_rp_calc()$rp, 
                    y = sim_rp_calc()[[display_var]],
                    xout =  c(2, 5, 10, 15, 20, 25, 30, 35)
                  )$y
              ) |> 
              DT::datatable(
                rownames = FALSE,
                options = list(
                  searching = FALSE,  
                  paging = FALSE,
                  ordering = FALSE
                )
              ) |> 
              DT::formatCurrency(
                columns = c(display_var),
                currency = "",
                digits = 0
              )
            })
          
        } else if((sim_output()$peril == "Windstorm" &
                 sim_output()$dataset == "IBTrACS") |
                 sim_output()$dataset == "Stochastic") {
          
          output$rp_view_ui <-  
            renderUI({
              tagList(
                h4("Exhibit 3: Return Period Summary"),
                tc_rp_view_text,
                tableOutput(ns("tc_ibtracs_rp_table"))
              )
            })
          
          output$tc_ibtracs_rp_table <-
            renderTable({
              
              sim_output()$rp_stats |>     
              dplyr::mutate(
                dplyr::across(.cols = dplyr::contains("Frequency"),
                              .fns = ~round(., 4)))|>
              dplyr::mutate(
                dplyr::across(.cols = 
                                dplyr::contains("Return Period")|
                                dplyr::contains("Wind")|
                                dplyr::contains("Pressure")|
                                dplyr::contains("Pressure")
                              ,
                              .fns = ~round(., 1))) |> 
              dplyr::mutate(
                Payout = display_fun(Payout)
              )
                
            })
          
        }
        
      })
    }
  )
}
