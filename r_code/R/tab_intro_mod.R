
intro_text <- 
  helpText(h4("General Overview"),
         "Welcome to the IDF Oasis Risk Explorer.",
         strong("The central purpose of this tool is educational, serving as an 
         introduction to the different considerations that go into modelling 
         catastrophe risk with specific applications to parametric insurance."),
         "The tool is broken into six sections excluding the introduction tab.",
         strong("Please ensure you consult the help page which can be accessed 
         using the links on each page. When using the tool it is suggested that 
         you navigate through these tabs going from left to right,"),
         "as this is the order in which they are intended to be completed.",
         br(),
         h4("What do I need to run the model?"),
         strong("All you need to run this model is some idea of the location 
         and value of an asset or property in a region prone to tropical 
         cyclones."),
         " If you do not know this but still wish to run the tool, simply enter
         some made-up values e.g., select a location in the Caribbean gulf or 
         NW Pacific and just enter an arbitrary USD 100,000 asset value.",
         br(),
         br(),
         strong("You do not need access to your own hazard/event sets to run the model 
                      as these are all contained in the tool."),
         br(),
         h4("Tab Guide: Inputs"), 
         "The first three tabs require you to enter inputs specific to the 
         risk you are modelling.",
         strong("These are exposure, hazard and vulnerability and make up the 
         basic building blocks of virtually any catastrophe model."),
         " These are each described in more detail below:", br(), br(),
         tags$ul(
           tags$li(strong("Exposure: What are the assets you want to insure?"),
           " In this tab you will specify the location and total asset 
           value that you want your insurance to cover."),
           br(), 
           tags$li(strong("Hazard: Which types of natural perils are you 
           interested in modelling (e.g. windstorm, 
           earthquake)?"),
           "What data sources will you be using to model these? 
           These data sources could be taken from the history or 
           generated based on scientific knowledge or statistical 
           techniques."),
           br(), 
           tags$li(strong("Vulnerability: How do physical events lead to 
           damage to your asset and financial loss?"),
           "What intensity measure will be used to calculate damage sustained 
           (e.g., wind speed/pressure etc.)? How much damage is caused for each 
           value of the intensity measure? For example, if you have 100km/h 
           winds vs 200km/h winds how much extra damage will you expect to 
           sustain?")),
         h4("Tab Guide: Simulation and Outputs"), "Once inputs have been entered 
         in the previous tabs, you have everything required to run the model. 
         The following three tabs allow you to run the model and look at its 
         outputs. These are each described below:",
         br(), 
         br(),
         tags$ul(
           tags$li(strong("Simulation: This tab is where you run modelling and 
           generate simulation output."),"Based on your entries in the previous 
           sections, the model will generate a large number of simulated years 
           by statistically sampling from the hazard data. This may take a short 
           while to run."),
           br(), 
           tags$li(strong("Event Analysis: This tab allows you to examine the 
           model's output in more detail and get a better sense of the type of 
           events that occur in the simulations."),"This tab provides a range of
           exhibits that aim to answer questions you may have the output. E.g., 
           how often do different events and losses occur? What does a 
           simulation actually look like?"),
           br(), 
           tags$li(strong("Losses: This tab analyses the financial loss and 
           damage generated in your modelling.")," The Loss Analysis tab will 
           show you the financial loss you would expect to see on average for 
           your risk under different calculation methods. It will also show you 
           the full range of simulation losses and other interesting metrics 
           that will help you better understand the risk. This tab also allows 
           you to export modelling results into Microsoft Excel should you wish 
           to do further analysis.")
          ),
      br(),
      br())

tab_intro_UI <- function(id) {
  ns <- NS(id)
    tagList(
             titlePanel("Introduction"),
             tags$a("For more detail see the Help page's Introduction section",
                    href = "https://oasislmf.github.io/RiskExplorer/components/index_UserGuide.html",
                    target = "_blank"),
             br(),
             tags$a("Please see legal disclaimer before running",
                    href = "https://oasislmf.github.io/RiskExplorer/components/index_Disclaimer.html",
                    target = "_blank"),
             column(width = 9, 
                    intro_text),
             page_nav_UI(ns("intro"))
            )
}

tab_intro_Server <- function(id, parent) {
  moduleServer(
    id,
    function(input, output, session) {
      
      page_nav_Server("intro",
                      parent = parent,
                      prev_page  = NULL, 
                      next_page = "hazard")
      
    }
  )
}