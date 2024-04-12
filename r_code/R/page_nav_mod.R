page_nav_UI <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    fluidRow(
      column(width = 3, shiny::uiOutput(ns("prev_page_ui"))),
      column(width = 3, shiny::uiOutput(ns("next_page_ui")))
      )
  )
}

page_nav_Server <- function(id, parent, prev_page_name, next_page_name) {
  moduleServer(
    id,
    function(input, output, session) {
      
      shiny::observe({
        
        shiny::req(prev_page_name)
        output$prev_page_ui <- shiny::renderUI({
          ns <- session$ns
          tagList(
            shiny::actionButton(ns('prev_page'), 
                                label = 'Go to Previous Page')
          )
        })
      })
      
      shiny::observe({
        
        shiny::req(next_page_name)
        output$next_page_ui <- renderUI({
          ns <- session$ns
          tagList(
            shiny::actionButton(ns('next_page'), 
                                label = 'Go to Next Page')
          )
        })
      })
      
      shiny::observeEvent(input$next_page, {
        
        shinyjs::js$button()
        shiny::updateTabsetPanel(session = parent, 
                                 inputId = "tabset",
                                  selected = next_page_name)
      })
      
      shiny::observeEvent(input$prev_page, {
        
        shinyjs::js$button()
        shiny::updateTabsetPanel(session = parent,
                                 inputId =  "tabset",
                                 selected = prev_page_name)
      })
      
      
      
    }
  )
}