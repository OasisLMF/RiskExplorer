
display_help_text_UI <- function(id) {
  ns <- NS(id)
  tagList(
    shinydashboard::box(
      actionButton(ns('hide_text'),
                   label = "Display Help",
                   icon = icon('question'))),
    br(),
    uiOutput(ns("help_text_ui"))
  )
}

display_help_text_Server <- function(id, text) {
  moduleServer(
    id,
    function(input, output, session) {
      
      display_help <- reactiveVal(FALSE)
      
      ns <- session$ns
      
      output$help_text_ui <-
        shiny::renderUI({
          
          shiny::req(display_help())
          shinydashboard::box(id = ns("help_text"), 
                              text, 
                              width = 12)
        })
      
      observeEvent(input$hide_text,{
        
        if(display_help()){
          display_help(FALSE)
        } else {
          display_help(TRUE)
        }
        
      })
      
    }
  )
}
