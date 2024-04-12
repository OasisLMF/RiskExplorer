drought_text <-
  helpText(
    "This plot displays the climatological index over the exposure area and 
    the payouts received at each simulated location in each year. The map is 
    shaded by the level of drought experienced at each grid cell.",
    br(),
    "The circles represent exposure locations, with bluer shading denoting a 
    higher payout."
  )

tc_ibtracs_text <-
  helpText("Test")


a_individual_sim_UI <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("sim_summary_ui"))
  )
}

a_individual_sim_Server <- function(id, sim_output, display_var, display_fun) {
  moduleServer(
    id,
    function(input, output, session) {
      
      observe({
        
        req(sim_output())
        
        ns <- session$ns
        
        if(sim_output()$peril == "Drought") {
          
          output$sim_summary_ui <-
            renderUI({
              tagList(
                h4("Exhibit 2: Individual Simulation Summary"),
                drought_text,
                fluidRow(
                  column(width = 4,
                    numericInput(ns("sim_no_select"), 
                                label = "Select Simulation Number",
                                value = 1,
                                min = 1,
                                max = sim_output()$sim_count)
                    ),
                  column(width = 4,
                         sliderInput(ns("year_select"),
                                     label = "Select Calendar Year",
                                     min = 1983,
                                     max = 2019,
                                     value = 2019,
                                     step = 1,
                                     round = TRUE)
                    )
                  ),
                column(width = 9,
                  tableOutput(ns("drought_individual_sim_summary_table")),
                  leafletOutput(ns("drought_indiv_sim_map")),
                  DTOutput(ns("drought_indiv_sim_DT"))
                )
              )
            })
          
          individual_sim_data <-
            reactive({
              req(input$sim_no_select, input$year_select)
              
              sim_output()$data_individual_sim |>
                dplyr::filter(Sim == input$sim_no_select,
                              Year == input$year_select)
            })
          
          
          individual_hazard_data <-
            reactive({
              req(input$sim_no_select, input$year_select)
          
              year_index <-
                which(input$year_select == 1983:2019)
          
                sim_output()$one_year_hazard[[year_index]]
            })
          
          
          output$drought_indiv_sim_map <-
            renderLeaflet({
              
              req(individual_hazard_data(), individual_sim_data())
              
              generate_sim_map_drought(
                one_year_hazard_data = individual_hazard_data(), 
                individual_sim_data = individual_sim_data(),
                display_var = display_var,
                index_var = sim_output()$intensity_measure,
                display_fun = display_fun,
                value_per_insured = sim_output()$value_per_insured,
                bbox = sim_output()$raster_bbox)
            })
          
          output$drought_individual_sim_summary_table <-
            renderTable({
              req(input$sim_no_select, input$year_select)
              
              data.frame(
                `Year` = as.integer(input$year_select),
                `Simulation` = as.integer(input$sim_no_select),
                `Average Annual Weather Index Value` = 
                  if(sim_output()$intensity_measure == 
                     "Percentage of Climatology") {
                    scales::percent(
                      mean(individual_hazard_data()),
                      prefix = "",
                      scale = 0.1,
                      accuracy = 1,
                    )  
                  } else {
                    scales::comma(
                      mean(individual_hazard_data()),
                      prefix = "",
                      scale = 1,
                      accuracy = 1,
                    )
                  },
                `Total Annual Loss` = 
                  scales::dollar(
                    sum(individual_sim_data()$Payout),
                    prefix = "",
                    suffix = sim_output()$curr,
                    accuracy = 1
                  ),
                `Policyholders Impacted` = 
                  as.integer(sum(individual_sim_data()$Payout > 0)),
                `Average Loss` = 
                  scales::dollar(
                    mean(individual_sim_data()$Payout),
                    prefix = "",
                    suffix = sim_output()$curr,
                    accuracy = 1
                  ),
                `Growing Season` = sim_output()$growing_season
                ,
                check.names = FALSE
              )
            })
          
          output$drought_indiv_sim_DT <-
            renderDT({
              
              req(input$sim_no_select, input$year_select)
              
              generate_sim_dt_drought(table_data = sim_output()$data_individual_sim, 
                                      display_var = display_var,
                                      index_var = sim_output()$intensity_measure,
                                      year = input$year_select, 
                                      sim = input$sim_no_select, 
                                      display_fun = display_fun)
            })
          
        }else if(sim_output()$peril == "Windstorm" &
                 sim_output()$dataset == "IBTrACS"){
          
          output$sim_summary_ui <-  
            renderUI({
              tagList(
                h4("Exhibit 2: Individual Simulation Summary"),
                tc_ibtracs_text,
                numericInput(ns("tc_ibtracs_sim_no_select"),
                             label = "Select Sim No to Display on Map",
                             value = 1, 
                             min = 1, 
                             max = 10000),
                tableOutput(ns("tc_ibtracs_individual_sim_summary_table")),
                leafletOutput(ns("tc_ibtracs_individual_sim_map"),
                              height = "50vh", 
                              width = "50vw"),
                DTOutput(ns("tc_ibtracs_individual_sim_DT"))
              )
            })
            
            sim_no_selected <- reactive({input$tc_ibtracs_sim_no_select})
            
            sim_no_selected_lagged <- 
              shiny::debounce(sim_no_selected, millis = 1500)
            
            selected_sim_data <- 
              reactive({
                
                req(sim_no_selected_lagged() >=1 &
                      sim_no_selected_lagged() <= sim_output()$sim_count & 
                      sim_no_selected_lagged() %% 1 == 0)
                
                sim_output()$data_individual_sim |>
                  dplyr::filter(`Sim No` == sim_no_selected_lagged())%>%
                  mutate(Label = paste(`Storm Name`, Year ,
                                       "Loss:", percent(Payout)))
              })
          
          selected_sim_summary <-
            reactive({
              
              req(sim_no_selected_lagged() >=1 &
                    sim_no_selected_lagged() <= sim_output()$sim_count & 
                    sim_no_selected_lagged() %% 1 == 0)
              
              sim_output()$data_sim |>
                dplyr::filter(`Sim Number` == sim_no_selected_lagged()) |>
                dplyr::select(Longitude, Latitude, `Distance to Exposure`, 
                              Weight, `Simulation Average Loss`, 
                              `Average Event Count`)
            })
          
          
          output$tc_ibtracs_individual_sim_summary_table <-
            renderTable({
              
              req(selected_sim_summary())
              
              selected_sim_summary() |>
                dplyr::mutate(
                  `Simulation Average Loss` = 
                    display_fun(`Simulation Average Loss`),
                  Weight = label_percent(0.1)(Weight),
                  Longitude = label_comma(accuracy = 0.0001)(Longitude),
                  Latitude = label_comma(accuracy = 0.0001)(Latitude),
                  `Distance to Exposure` = 
                    label_currency(suffix = "km", prefix = "")(`Distance to Exposure`)
                ) 
            })
          
          output$tc_ibtracs_individual_sim_DT <-
            renderDT({
              req(selected_sim_data())
              
              selected_sim_data() |>
                dplyr::select( -`Sim No`, -Weight, 
                               -Frequency, -`Weighted Frequency`, -Label) |>
                dplyr::mutate(
                  Longitude = label_comma(accuracy = 0.0001)(Longitude),
                  Latitude = label_comma(accuracy = 0.0001)(Latitude),
                  Payout = display_fun(Payout)
                ) |> 
                dplyr::mutate(
                  dplyr::across(
                    dplyr::contains("Speed")|
                    dplyr::contains("Pressure"),
                    ~label_comma(accuracy = 0.01)(.)
                    )
                )|> 
                datatable(rownames = FALSE)
            })
          
          output$tc_ibtracs_individual_sim_map <-
            renderLeaflet({
              
              req(selected_sim_data(), selected_sim_summary())
              
              generate_sim_map_tc(
                individual_sim_data = selected_sim_data(), 
                sim_summary_data = selected_sim_summary(), 
                expo_ll = sim_output()$expo_ll, 
                expo_radius = sim_output()$expo_radius
              )
              
            })
          
        }else if(sim_output()$dataset == "Stochastic"){
          
          
        }
        
        
      })
      
      
    }
  )
}
