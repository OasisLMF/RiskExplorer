library(bslib)
library(shinyWidgets)
library(raster)
library(shinyjs)
library(Hmisc)
library(readr)
library(dplyr)
library(data.table)
library(purrr)
library(scales)
library(shiny)
library(shinyBS)
library(ggplot2)
library(plotly)
library(htmltools)
library(DT)
library(tidyr)
library(leaflet)
library(leaflet.extras)
library(tictoc)
library(lubridate)
library(sf)
library(sp)
library(data.table)
library(geosphere)
library(here)
library(reticulate)
library(abind)
library(runjags)
library(ncdf4)
library(tidync)
library(RColorBrewer)

# options(shiny.trace=TRUE)
options(shiny.sanitize.errors = FALSE, scipen = 999)

# Read in mapping csvs

mappings <- list(
  curr_mappings = read.csv("./data/mappings/curr_codes.csv"),
  hazard_mappings = read.csv("./data/mappings/hazard_mappings.csv"),
  vulnerability_mappings = read.csv("./data/mappings/vulnerability_mappings.csv"),
  pentad_mappings = read.csv("./data/mappings/pentad_mappings.csv")
)

# Source UI functions


# Set Theme
theme <- bslib::bs_theme(bg = "#FFFFFF", fg = "black", primary = "#D41F29",
                         secondary = "#D41F29", base_font = font_google("Raleway"))

# Set up page HTML,toolbar and pull in individual tabs from UI script.
ui <- fluidPage(
  title = "Oasis Risk Explorer",
  tags$style(type = "text/css",
             " 
             .navbar {position: sticky; top:0;}
             .container-fluid { --bs-gutter-x: 0rem}
             .tab-content {padding-left: 20px; padding-right: 20px }
             .nav-underline{--bs-nav-underline-gap: 0.5rem}"),
  navbarPage(title = div(img(src = "OasisIcon.png",
                             height = 40, 
                             width = 141.03, 
                             position = "fixed-top" ), 
                         "Risk Explorer",
                         img(src = "IDFIcon.png", 
                             height = 40, 
                             width = 163.25), 
                         img(src = "maxinfoIcon.png",
                             height = 40, 
                             width = 124.44),
                         style = "float:left"),
             position = "fixed-top", 
             id = "tabset",
             theme = theme,
             shiny::tabPanel(title = "Intro",
                             icon = icon("door-open"),
                             value = "intro",
                             tab_intro_UI('intro1')),
             shiny::tabPanel("1.Hazard",
                             icon = shiny::icon("cloud-showers-heavy"),
                             value = "hazard",
                             tab_hazard_UI('hazard1')),
             shiny::tabPanel("2.Exposure",
                             icon = icon("building"),
                             value="exposure",
                             tab_exposure_UI('exposure1')),
             shiny::tabPanel("3.Vulnerability",
                             icon = shiny::icon("ruler-vertical"),
                             value = "vulnerability",
                             tab_vulnerability_UI('vulnerability1')),
             shiny::tabPanel("4.Simulation",
                             icon = shiny::icon("calculator"),
                             value = "simulation",
                             tab_simulation_UI('simulation1')),
             shiny::tabPanel("5.Events",
                             icon = shiny::icon("poll"),
                             value = "events",
                             tab_events_UI('events1')),
             shiny::tabPanel("6.Payouts",
                             icon = shiny::icon("bullseye"),
                             value = "losses",
                             tab_payouts_UI('losses1'))
  )
)

server <- function(input, output, session) {
  
  tab_intro_Server('intro1', parent = session) 
  
  hazard_data <- tab_hazard_Server('hazard1', 
                                   h_mappings = mappings$hazard_mappings,
                                   parent = session)
  
  exposure_data <- tab_exposure_Server('exposure1',
                                       selected_hazard_mappings = 
                                         hazard_data$selected_hazard_mappings, 
                                       curr_codes = 
                                         mappings$curr_mappings$Code,
                                       parent = session)
  
  vulnerability_data <- tab_vulnerability_Server('vulnerability1',
                                                 selected_hazard_mappings = 
                                                   hazard_data$selected_hazard_mappings,
                                                 v_mappings = 
                                                   mappings$vulnerability_mappings,
                                                 parent = session)
  
  sim_output <- 
    tab_simulation_Server(
      'simulation1',
      hazard_data = hazard_data,
      exposure_data = exposure_data,
      vulnerability_data = vulnerability_data,
      pentad_mappings = mappings$pentad_mappings,
      vulnerability_mappings = mappings$vulnerability_mappings,
      parent = session
    )
  
  display_type <-
    tab_events_Server('events1', 
                      sim_output = sim_output,
                      parent = session)
  
  tab_payouts_Server('losses1', 
                     sim_output = sim_output,
                     display_type = display_type,
                     parent = session)
  
}

shinyApp(ui = ui, server = server)
