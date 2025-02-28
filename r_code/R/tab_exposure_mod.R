
exposure_text_ws <-
  helpText(
    strong(
      "Where are the asset(s) you want to insure? The exposure tab is where you 
      will specify the single location or area that you wish to model. You will 
      also specify the total value of the asset(s) you are interested in 
      insuring. Individual locations and circular areas can be entered in 
      the tool."
    ),
    br(),
    br(),
    "There are three main inputs that you need to define here:",
    br(),
    br(),
    tags$ul(
      tags$li(
        strong(
          "Step 1: The latitude/longitude co-ordinates of the location or centre
        of the area you are interested in covering."
        ),
        " If you do not know these, you can either use the address search or click
        on any location on the map and these will be retrieved in the app. Where
        you are looking to cover a larger area (e.g. a whole island), it is worth
        selecting a location that is close to the centre of the area you wish to
        cover in order to ensure you aren't covering a larger area than
        necessary. The table below the map will show you the currently selected
        latitude and longitude values."
      ),
      br(),
      tags$li(
        strong("Step 2: The area over which your assets are located."),
        " If you are looking to model a single location, you will be able to skip
        this step as the area around the location being covered is simply zero.
        If you are looking at modelling assets over a wider area rather than a
        single location, you will specify the radius of a circle in this section.
        This will define the total area to be modelled. You can easily experiment
        with different circle sizes using the map below."
      ),
      br(),
      tags$li(
        strong(
          "Step 3: Enter the total value of the assets you are covering and select
        an appropriate currency."
        ),
        "This can be thought of as the total cost of re-building your assets and
        could also include any further economic loss from a catastrophe (e.g.,
        lost revenue from business interruption)."
      )
    )
  )

exposure_text_drought <-
  helpText(
    strong(
      "Where are the policyholder(s) you want to insure? The exposure tab is 
      where you will specify the area which your drought policy will cover. 
      You will also specify the total number of policyholders covered as well as 
      the maximum payout amount under each individual policy. 
      Any square or rectangular area covering less than 3m square kilometres and 
      having sides of at least  8km long may be entered"
    ),
    br(),
    br(),
    "There are three main inputs that you need to define here:",
    br(),
    br(),
    tags$ul(
      tags$li(
        strong(
          "Step 1: The latitude/longitude co-ordinates of the location or centre
        of the area you are interested in covering."
        ),
        " If you do not know these, you can either use the address search or click
        on any location on the map and these will be retrieved in the app. Where
        you are looking to cover a larger area (e.g. a whole island), it is worth
        selecting a location that is close to the centre of the area you wish to
        cover in order to ensure you aren't covering a larger area than
        necessary. The table below the map will show you the currently selected
        latitude and longitude values."
      ),
      br(),
      tags$li(
        strong("Step 2: The area over which your policy will provide coverage/ 
        your policyholders may be located."),
        "You will specify a rectangular shape in this section which will define 
        the area to be modelled. You can easily experiment with different 
        shape sizes using the map below. Your selected exposure area must fall 
        within the area of hazard data you have loaded."
      ),
      br(),
      tags$li(
        strong(
          "Step 3: Enter the maximum individual policy value, select 
          an appropriate currency and specify the number of individual 
          policyholders.", 
        ),
        "
        The total value of the individual policies will be calculated as well 
        by scaling the number of policyholders with the individual policy value. 
        The individual policy value can be thought of as the financial cost of 
        compensating a policyholder for the economic or humanitarian loss of a 
        drought (e.g., the cost of importing alternative crops for food and/or 
        the lost revenue from a poor harvest)."
      )
    )
  )


tab_exposure_UI <- function(id) {
  ns <- NS(id)
    tagList(
      titlePanel("2.Exposure"),
      shiny::conditionalPanel(
        shinyjs::useShinyjs(),
        condition = "output.display_exposure_tab",
        ns = ns,
        display_help_text_UI(ns("help_text_exposure")),
        br(),
        tags$a(
          "For more detail see the Help page's Exposure user guide",
          href = "https://oasislmf.github.io/RiskExplorer/components/index_Walkthrough.html#exposure",
          target = "_blank"
        ),
        e_location_select_UI(ns("location_select1")),
        e_polygon_select_UI(ns("polygon_select1")),
        e_exposure_value_UI(ns("exposure_value1"))),
      shiny::conditionalPanel(
        condition ="!output.display_exposure_tab",
        ns = ns,
        helpText(strong("Please return to Hazard tab and load valid hazard 
                        data"),
        br(),
        br())),
      section_complete_page_UI(ns("section_exposure1")),
      page_nav_UI(ns("exposure"))
    )
}

tab_exposure_Server <- function(id, 
                                parent, 
                                selected_hazard_mappings, 
                                curr_codes) {
  moduleServer(
    id,
    function(input, output, session) {
      
      tab_check_ok <- reactiveVal(FALSE)
      
      exposure_text <- reactive({
        
        req(selected_hazard_mappings())
        
        if(selected_hazard_mappings()["peril"] == "Drought") {
          exposure_text_drought
        } else {
          exposure_text_ws
        }
        
      })
      
      observe({
        req(exposure_text())
        
        display_help_text_Server(
          "help_text_exposure",
          text = exposure_text()  
        )
        
      })
      
      output$display_exposure_tab <- reactive({
        tryCatch({
          isTruthy(selected_hazard_mappings())
        },
        shiny.silent.error = function(e) {
          FALSE
        })
      })
      
      observeEvent(input$button, {
        
        if(input$show_help %% 2 == 1){
          shinyjs::hide(id = "help_box")
        }else{
          shinyjs::show(id = "help_box")
        }
      })
      
      
      outputOptions(output, "display_exposure_tab", suspendWhenHidden = FALSE)
      
      location_choices <- 
        e_location_select_Server("location_select1",
                                 selected_hazard_mappings =
                                  selected_hazard_mappings)
      
      shape_choices <-
        e_polygon_select_Server("polygon_select1", 
                                location_choices$proxy_input_map,
                                location_choices$ll_vals,
                                location_choices$map_poly_data,
                                selected_hazard_mappings)
      
      value_choices <-
        e_exposure_value_Server("exposure_value1", 
                                selected_hazard_mappings,
                                curr_codes)
      
      observe({
        
        tab_check_ok(FALSE)
        req(location_choices$section_ok(),
            shape_choices$section_ok(),
            value_choices$section_ok())
        
        tab_check_ok(TRUE)
      })
      
      section_complete_page_Server("section_exposure1",
                                    check_ok = tab_check_ok,
                                    section = "Exposure")
      
      page_nav_Server("exposure",
                      parent = parent,
                      prev_page  = "hazard", 
                      next_page = "vulnerability")
      
      return(list(location_choices = location_choices,
                  shape_choices = shape_choices,
                  value_choices = value_choices,
                  tab_check_ok = tab_check_ok))
      
    }
  )
}
