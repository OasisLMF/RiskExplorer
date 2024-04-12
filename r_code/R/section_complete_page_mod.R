section_complete_page_UI <- function(id) {
  ns <- NS(id)
  tagList(
    htmlOutput(ns("section_complete"),
                  style = "color:green;font-size:16px")
  )
}

section_complete_page_Server <- function(id, check_ok, section) {
  moduleServer(
    id,
    function(input, output, session) {
      
      observe({
      
      output$section_complete <- 
        renderText({""})
      
      req(check_ok())
      
      output$section_complete <- 
        renderText({
          paste(
            as.character(
              icon("check-circle")
              ),
            "Section Complete:", 
            section, 
            "Information Entered")
          })      
      })
      
    }
  )
}



