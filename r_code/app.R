library(bslib)
library(shinyWidgets)
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
library(rgeos)
library(geosphere)

# options(shiny.trace=TRUE)
options(shiny.sanitize.errors = FALSE,scipen = 999)

# Read in mapping csvs
curr_cd <<- read.csv("./data/mappings/curr_codes.csv")
h_mappings <<- read.csv("./data/mappings/hazard_mappings.csv")
v_intensity_mappings <<- read.csv("./data/mappings/intensity_mappings.csv")

# Source UI functions
source("./ui/functionsUI.R")
source("./ui/tabsUI.R")

# Set Theme
theme <- bslib::bs_theme(bg = "#FFFFFF", fg = "black", primary = "#D41F29",
                         secondary = "#D41F29", base_font = font_google("Raleway"))

# Set up page HTML,toolbar and pull in individual tabs from UI script.
ui <- fluidPage(title="Oasis Risk Explorer",list(
                tags$head(HTML("<link rel=\"icon\", href=\"MyIcon.png\",
                                     type=\"image/png\" />"))),
                tags$style(type = "text/css", "body {padding-top: 20px;}
                           .navbar{max-height:55px;}"),
                div(style = "padding: 1px 0px;",
                titlePanel(title = "", windowTitle = "My Window Title")), 
                tags$script(
                  '$(".sidebar-toggle").on("click", function() { $(this).trigger("shown"); });'
                ),
                  navbarPage(title = div(img(src = "OasisIcon.png",height = 40, width = 141.03), "Risk Explorer",
                                         img(src = "IDFIcon.png",height = 40, width = 163.25), 
                                         img(src = "maxinfoIcon.png",height = 40, width = 124.44)),
                                         position = "fixed-top", 
                                         id="tabset",
                                         theme = theme,
                                         intro_tab, 
                                         exposure_tab, 
                                         hazard_tab, 
                                         vulnerability_tab,
                                         simulation_tab, 
                                         analysis_tab,
                                         results_tab))

server <- function(input, output, session) {
  
  observeEvent(input$i_nextpage, {
    updateTabsetPanel(session, "tabset",
                      selected = "exposure")
  })
  
  source("./server/exposureServer.R", local = TRUE)
  source("./server/hazardServer.R", local = TRUE)
  source("./server/vulnerabilityServer.R", local = TRUE)
  source("./server/simulationServer.R", local = TRUE)
  source("./server/analysisServer.R", local = TRUE)
  source("./server/resultsServer.R", local = TRUE)
  
}

shinyApp(ui = ui, server = server)
