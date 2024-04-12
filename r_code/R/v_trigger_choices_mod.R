extract_choices_vec <- function(vec){
  unname(
    c(
      unlist(
        unique(vec)
      )
    )
  )
}

v_trigger_choices_UI <- function(id) {
  ns <- NS(id)
  tagList(
    h4("Step 1: Choose your trigger measure and response basis"),
    helpText(
      strong("Note that changing the intensity measure selection/unit 
      will re-load the defaults and clear any edits you have already made to the 
      table below")),
    fluidRow(
      column(width = 4,
             selectInput(ns("intensity"),
                         label = "Intensity Measure Selection",
                         choices = NULL,
                         selected = "")),
      column(width = 4,
             selectInput(ns("intensity_unit"),
                         label = "Intensity Measure Unit",
                         choices = NULL,
                         selected = "km/h"))),
    conditionalPanel(condition = "output.drought_peril",
                     ns = ns,
                     helpText("Please select an appropriate growing season for 
                              your modelling location. This slider will 
                              auto-populate with placeholder values for each 
                              hazard region."),
                       column(width = 6,
                              sliderInput(ns("growing_season"),
                                          label = "Input Growing Season",
                                          min = as.Date("2024-01-01","%Y-%m-%d"),
                                          max = as.Date("2025-04-30","%Y-%m-%d"),
                                          value = c(as.Date("2024-01-01",
                                                            format = "%Y-%m-%d"),
                                                    as.Date("2024-04-29",
                                                            format = "%Y-%m-%d")),
                                          timeFormat = "%Y-%m-%d")),
                       htmltools::span(
                         shiny::uiOutput(ns("growing_season_warning"), 
                                         style = "color:red;font-size:16px")),
                       htmltools::span(
                         shiny::uiOutput(ns("growing_season_info"), 
                                         style = "color:red;font-size:16px"))),
                       conditionalPanel(
                         ns = ns,
                         condition = "input.intensity == 'Number of Dry Spell Days'",
                         fluidRow(
                         column(width = 3,
                           sliderInput(ns("dry_days_threshold"),
                                       label = "Dry Day Percentage of 
                                       Climatology",
                                       min = 10,
                                       max = 100,
                                       value = 80)),
                         column(width = 3,
                           selectInput(ns("dry_days_qualify"),
                                       label = "Dry Days Qualifying Spell",
                                       choices = c("10 Days", 
                                                   "15 Days", 
                                                   "20 Days",
                                                   "25 Days",
                                                   "30 Days"),
                                       selected = "15 Days")
                        )
                       )
                     ),
    h4("Step 2: Choose your vulnerability curve"),
    selectInput(ns("curve_type"),
                label = "Select Curve Type",
                choices = c("Step", "Linear"),
                selected = "Step")
  )
}

v_trigger_choices_Server <- function(id, selected_hazard_mappings, v_mappings) {
  moduleServer(
    id,
    function(input, output, session) {
      
      section_ok <- reactiveVal(NULL)
      
      trigger_choices <-
        reactiveValues(
          intensity = NULL,
          intensity_unit = NULL,
          growing_season = NULL,
          dry_days_threshold = NULL,
          curve_type = NULL)
      
      
      output$drought_peril <- 
        reactive({
          tryCatch({
            
            isTruthy(selected_hazard_mappings()["peril"]) 
            if(selected_hazard_mappings()["peril"] == "Drought"){
              TRUE
            }else{
              FALSE
            }
          },
          shiny.silent.error = function(e) {
            FALSE
          })
        })
      
      outputOptions(output, 
                    name = "drought_peril", 
                    suspendWhenHidden = FALSE)  
      
      observe({
        
        req(selected_hazard_mappings())
        
        intensity <-
          v_mappings |>
          dplyr::filter(peril == selected_hazard_mappings()[["peril"]]) |>
          dplyr::select(measure) |>
          extract_choices_vec()
        
        season_start <- 
          as.Date(selected_hazard_mappings()[["season_start"]], 
                  format = "%d/%m/%Y")
        
        season_end <- 
          as.Date(selected_hazard_mappings()[["season_end"]], 
                  format = "%d/%m/%Y")
        
        output$growing_season_info <-
          renderText({
            paste("<span style=\"color:red;font-size:16px\">",
                  selected_hazard_mappings()[["region_name"]], "region selected.",
                  "Default Assumption for growing season is from", season_start,
                  "to", season_end)
            
          })
        
        updateSelectInput(session = session,
                          inputId = "intensity",
                          choices = intensity,
                          selected = "")
        
        updateSliderInput(session = session,
                          inputId = "growing_season",
                          value = c(season_start, season_end))
      })
      
      observe({
        req(input$intensity, selected_hazard_mappings())
        
        intensity_units <-
          v_mappings |>
          dplyr::filter(peril == selected_hazard_mappings()[["peril"]]&
                          measure == input$intensity) |>
          dplyr::select(unit) |>
          extract_choices_vec()
        
        updateSelectInput(session = session,
                          inputId = "intensity_unit",
                          choices = intensity_units,
                          selected = NULL)
      })
      
      
      observe({
        req(input$intensity, input$intensity_unit, input$curve_type)
        
        trigger_choices$intensity  <- 
          input$intensity
        
        trigger_choices$intensity_unit <- 
          input$intensity_unit
        
        trigger_choices$curve_type <- 
          input$curve_type
        
      })
      
      observe({
        req(input$dry_days_threshold, input$dry_days_qualify)
        
        trigger_choices$dry_days_threshold <- 
          input$dry_days_threshold
        
        trigger_choices$dry_days_qualify <- 
          input$dry_days_qualify
      })
      
      observe({
        req(input$growing_season)
        
        trigger_choices$growing_season <- 
          if(input$growing_season[2] - input$growing_season[1] <= 366 &
             input$growing_season[2] - input$growing_season[1] >= 12 ) {
            
            output$growing_season_warning <- NULL
            
            c(input$growing_season[1], input$growing_season[2])
            
          } else {
            output$growing_season_warning <- 
              renderText({
                "Please select a growing season of less than a year and 
                 greater than 12 days"
              })
            
            NULL
          }
      })
      
      observe({
        
        section_ok(FALSE)
        req(selected_hazard_mappings(),
            trigger_choices$intensity,
            trigger_choices$intensity_unit,
            trigger_choices$curve_type)
            
            if (selected_hazard_mappings()["peril"] == "Drought") {
              req(trigger_choices$growing_season)
              
              if (trigger_choices$intensity == "Number of Dry Days") {
                req(trigger_choices$dry_days_threshold,
                    trigger_choices$dry_days_qualify)
                section_ok(TRUE)
              } else {
                section_ok(TRUE)
              }
            } else {
              section_ok(TRUE)
            }
      })
      
      return(list(trigger_choices = trigger_choices,
                  section_ok = section_ok))
      
    }
  )
}
