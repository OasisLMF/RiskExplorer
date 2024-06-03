stochastic_individual_sim_text <-
  helpText(
    strong(
    "Exhibit 2 allows you to look at the results of any individual 
     simulation by selecting the relevant simulation number in the input 
     box."
    ),
    "The table immediately below gives a summary of the main outputs of the 
    simulation. The map and corresponding table display the events in the 
    dataset that would have led to losses for each simulation. Events are 
    displayed as markers at the location where their maximum intensity values 
    (minimums for pressure) were recorded.",
    br(),
    br()
  )

drought_individual_sim_text <-
  helpText(
    strong(
      "Exhibit 2 allows you to look at the results of any individual simulation
       and historical year by selecting the relevant simulation number and year
       from the input box/slider."
    ),
    "You can vary the year and simulation count to get a better sense of how 
    the simulation approach works and to investigate individual years using the 
    map and accompanying table.",
    br(),br(),
    "The map is shaded by the value of the drought measure 
    recorded at each grid cell.",
    "The circles represent simulated policyholders, with darker shadings 
    denoting higher payout/policyholders impacted values.",
    "The table immediately below gives a summary of the drought measure 
    reading and corresponding payout at each simulated policyholder 
    location."
  )

tc_individual_sim_text <-
  helpText(
    strong(
      "Exhibit 2 allows you to look at the results of any individual simulation 
       by selecting the relevant simulation number in the input box."
      ),
      "The table immediately below gives a summary of the main outputs of the 
       simulation. The map and corresponding table display the events in the 
       history that would have led to losses at each simulated location. 
       Note that loss triggering events are displayed as markers rather than 
       tracks as in Exhibit 1. Only the track locations with the maximum 
       intensity values (minimums for pressure) are displayed due to the 
       memory limitations imposed by loading tracks for thousands of 
        simulations.",
    br(),
    br()
  )

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
                drought_individual_sim_text,
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
                      mean(individual_hazard_data(), na.rm = TRUE),
                      prefix = "",
                      scale = 1,
                      accuracy = 0.1,
                    )  
                  } else {
                    scales::comma(
                      mean(individual_hazard_data(), na.rm = TRUE),
                      prefix = "",
                      scale = 1,
                      accuracy = 0.1,
                    )
                  },
                `Total Annual Payout` = 
                  scales::dollar(
                    sum(individual_sim_data()$Payout),
                    prefix = "",
                    suffix = sim_output()$curr,
                    accuracy = 1
                  ),
                `Policyholders Impacted` = 
                  as.integer(sum(individual_sim_data()$Payout > 0)),
                `Average Payout` = 
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
                tc_individual_sim_text,
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
                      sim_no_selected_lagged() %% 1 == 0,
                    display_var)
                
                temp_data <-
                  sim_output()$data_individual_sim |>
                    dplyr::filter(`Sim No` == sim_no_selected_lagged()) 
                
                # 
                # if(display_var == "Payout as % of Asset Value") {
                #   temp_data |> 
                #     mutate(Label = paste(`Storm Name`, Year ,
                #                          "Loss:", display_fun(Payout)))  
                # } else {
                  temp_data |> 
                    mutate(Label = paste(`Storm Name`, Year ,"<br>",
                                         "Payout:", 
                                         display_fun(Payout)))
                                         
                # }
                
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
                    label_currency(suffix = "km", prefix = "", scale = 0.001)(`Distance to Exposure`)
                ) 
            })
          
          output$tc_ibtracs_individual_sim_DT <-
            renderDT({
              req(selected_sim_data())
              
              
              # Messy. Re-factor this when have time. Had to change whole approach 
              # last min as can only retain numeric sorting with DT if use 
              # formatCurrency, not scales:: functions
            
              dt_data <-
                selected_sim_data() |>
                  dplyr::select( -`Sim No`, -Weight, 
                                 -Frequency, -`Weighted Frequency`, -Label) 
              
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
                
                dt_data |> 
                dplyr::arrange(Year) |> 
                dplyr::mutate(Payout = Payout * scaling_factor) |> 
                datatable(rownames = FALSE) |> 
                DT::formatCurrency(
                  columns = c("Longitude", "Latitude"),
                  currency = "",
                  digits = 4
                ) |> 
                DT::formatCurrency(
                  columns = grep("Speed|Pressure", colnames(dt_data)),
                  currency = "",
                  digits = 1
                ) |> 
                dt_format_fun(
                  columns = c("Payout")
                )
                
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
          
          output$sim_summary_ui <-  
            renderUI({
              tagList(
                h4("Exhibit 2: Individual Simulation Summary"),
                stochastic_individual_sim_text,
                numericInput(ns("st_sim_no_select"),
                             label = "Select Sim No to Display on Map",
                             value = 1, 
                             min = 1, 
                             max = 10000),
                tableOutput(ns("st_individual_sim_summary_table")),
                leafletOutput(ns("st_individual_sim_map"),
                              height = "50vh", 
                              width = "50vw"),
                DTOutput(ns("st_individual_sim_DT"))
              )
            })
          
          st_selected_sim_data <- 
            reactive({
              
              req(input$st_sim_no_select >=1 &
                  input$st_sim_no_select <= sim_output()$sim_count & 
                  input$st_sim_no_select %% 1 == 0)
              
              temp_data_st <-
                sim_output()$data_individual_sim |>
                  dplyr::filter(`Sim No` == input$st_sim_no_select)
              
              #Currency showing 0 here, is it missing scaling?
              
                temp_data_st |> 
                  mutate(Label = 
                           paste(
                             "Event ID:", `Event ID`, "<br>", "Payout:", 
                             display_fun(Payout)
                             )
                         )
              
            })
          
          st_selected_sim_summary <-
            reactive({
              
              req(input$st_sim_no_select >=1 &
                    input$st_sim_no_select <= sim_output()$sim_count & 
                    input$st_sim_no_select %% 1 == 0)
              
              sim_output()$data_sim_year |>
                dplyr::filter(`Sim No` == input$st_sim_no_select)
            })
          
          
          output$st_individual_sim_summary_table <-
            renderTable({
              
              req(st_selected_sim_summary())
              
              st_selected_sim_summary() |>
                dplyr::mutate(
                  `Payout` = 
                    display_fun(`Payout`)
                ) 
            })
          
          output$st_individual_sim_DT <-
            renderDT({
              
              req(st_selected_sim_data())
              
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
              
              dt_data <-
                st_selected_sim_data() |>
                dplyr::select( -`Sim No`, -Frequency, -Label)
              
              dt_data |> 
                dplyr::mutate(Payout = Payout * scaling_factor) |> 
                datatable(rownames = FALSE) |> 
                DT::formatCurrency(
                  columns = c("Longitude", "Latitude"),
                  currency = "",
                  digits = 4
                ) |> 
                DT::formatCurrency(
                  columns = grep("Speed|Pressure|Peak", 
                                 colnames(dt_data)),
                  currency = "",
                  digits = 1
                ) |> 
                dt_format_fun(
                  columns = c("Payout")
                )
            })
          
          output$st_individual_sim_map <-
            renderLeaflet({
              
              req(st_selected_sim_data(), st_selected_sim_summary())
              
              icon_type <- 
                ifelse(sim_output()$peril == "Earthquake", "water", "cloud")
              
              generate_sim_map_st(
                individual_sim_data = st_selected_sim_data(), 
                sim_summary_data = st_selected_sim_summary(), 
                expo_ll = sim_output()$expo_ll, 
                expo_radius = sim_output()$expo_radius,
                icon_type = icon_type
              )
              
            })

        }
        
        
      })
      
      
    }
  )
}
