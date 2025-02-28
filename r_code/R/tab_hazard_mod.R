# In-App non section specific helptext

hazard_text1 <- 
  helpText(
    strong(
      "What types of natural disasters are you modelling and what data are you
    going to use to do this? The hazard tab is where you specify the nature of
    the events you are interested in modelling as well as what data source you
    will be using to model these events."
    ),
    br(),
    br(),
    strong(
      "Step 1: Choose and load the hazard data to be used. The following fields
    need to be specified before loading the hazard data:"
    ),
    br(),
    br(),
    tags$ul(
      tags$li(
        strong("The peril you are interested in modelling."),
        "A peril is a specific type of disaster e.g., a windstorm or an earthquake."
      ),
      br(),
      tags$li(
        strong("The source of the data used to model your chosen peril."),
        "This could be using historical observation data (e.g., IBTrACS  or 
        CHIRPs data) or simulated (also known as stochastic) data put together 
        by catastrophe modelling experts/vendors (e.g. Oasis, Aon).",
      ),
      br(),
      tags$li(
        strong("The specific region you are interested in modelling."),
        "Note that the region groupings available are likely to differ depending
      on the peril you select. This is due to different perils having their
      roots in different natural phenomena and relying on data sources that may
      approach these groupings slightly differently.",
        strong(
          "Please select the appropriate region on the map provided by clicking 
          on the relevant shape. "
        )
      ),
      br(),
      tags$li(
        strong("The meteorological agency to use as a data source."),
        "For IBTrACS data specifically, several agencies record wind/track
       measurements for each basin. These typically relate to national
       meteorological agencies e.g., TOKYO is the Japanese agency and CMA is the
       Chinese agency. In cases where agencies cover different geographic areas
      within a basin, some advice may appear below the agency box to steer you
      in the right direction.",
        strong("For all non-IBTrACS datasets, simply select N/A here.")
      )
    ),
    br(),
    strong("Step 2 (Optional): Visualise the hazard data you have loaded into 
           the tool."),
    "This is useful for checking you've loaded the correct hazard data and is 
     available for both the historical datasets contained in the tool. For
     IBTrACS data this will also give you a sense of recent losses and how active
     the area around your exposure might be. Note that due to data limitations, 
     only 6-hourly storm tracks and sotrms reaching category 1 or above winds are 
     displayed here for IBTrACS data. As such, tracks displayed will differ 
     slightly from the more precise and extensive tracks used in the tool's 
     calculation engine."
  )

jscode <- 
"shinyjs.collapse = function(boxid) {
  $('#' + boxid).closest('.box').find('[data-widget=collapse]').click();
 }"

tab_hazard_UI <- function(id) {
  ns <- NS(id)
  tagList(
    shiny::titlePanel("1.Hazard"),
    display_help_text_UI(ns("help_text_hazard")),
    br(),
    tags$a(
    "For more detail see the Help page's Hazard user guide",
     href = "https://oasislmf.github.io/RiskExplorer/components/index_Walkthrough.html#exposure",
     target = "_blank"
    ),
    br(),
    br(),
    h_select_peril_data_UI(ns("select_peril1")),
    h_select_region_agency_UI(ns("select_region1")),
    h_load_data_UI(ns("load_data1")),
    br(),
    page_nav_UI(ns("hazard"))
  )
}

tab_hazard_Server <- function(id, parent, h_mappings) {
  moduleServer(id,
               function(input, output, session) {
                 
                 tab_check_ok <- reactiveVal(NULL)
                 
                 display_help_text_Server(
                   "help_text_hazard",
                    text = hazard_text1  
                 )
                 
                 peril_data_choices <-
                   h_select_peril_data_Server("select_peril1",
                                              h_mappings = h_mappings)
                 
                 region_agency_choices <-
                   h_select_region_agency_Server("select_region1",
                                                 h_mappings = h_mappings,
                                                 peril_data_choices =
                                                   peril_data_choices)
                 
                 selected_hazard_mappings <-
                   h_load_data_Server(
                     "load_data1",
                     h_mappings = h_mappings,
                     peril_data_choices = peril_data_choices,
                     region_agency_choices =
                       region_agency_choices
                   )
                 
                 observe({
                   tab_check_ok(FALSE)
                   req(selected_hazard_mappings())
                   tab_check_ok(TRUE)
                 })
                 
                 page_nav_Server("hazard",
                                 parent = parent,
                                 prev_page  = "intro",
                                 next_page = "exposure")
                 
                 return(
                   list(
                     selected_hazard_mappings = selected_hazard_mappings,
                     tab_check_ok = tab_check_ok
                     )
                   )
                 
               })
}