drought_text <-
  helpText(
    "This plot displays the total loss from all policies using a return period 
    metric. Higher return periods represent less frequenct and more extreme 
    outcomes",
  )

tc_ibtracs_text <-
  helpText("Test")

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
                drought_text,
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
                `Return Period` = c(2, 5, 10, 15, 20, 25, 30, 40, 50),
                check.names = FALSE
              ) |>
              dplyr::mutate(
                !!sym(display_var):=
                  approx(
                    sim_rp_calc()$rp, 
                    y = sim_rp_calc()[[display_var]],
                    xout =  c(2, 5, 10, 15, 20, 25, 30, 40, 50)
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
          
        }else if(sim_output()$peril == "Windstorm" &
                 sim_output()$dataset == "IBTrACS") {
          
          output$rp_view_ui <-  
            renderUI({
              tagList(
                h4("Exhibit 3: Return Period Summary"),
                tc_ibtracs_text,
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
                                dplyr::contains("Pressure"),
                              .fns = ~round(., 1))) |> 
              dplyr::mutate(
                Payout = display_fun(Loss)
              )
                
            })
          
        }else if(sim_output()$dataset == "Stochastic"){
          
          tagList(
            h4("Exhibit 1: Historical Loss Summary")
          )
          
        }
        
        
      })
    }
  )
}
