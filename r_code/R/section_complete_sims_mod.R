


section_complete_sims_UI <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("section_complete"))
  )
}

section_complete_sims_Server <- function(id, check_ok, section) {
  moduleServer(
    id,
    function(input, output, session) {
      
      observe({
        
        output$section_complete <- 
          renderUI({
            if(check_ok() == FALSE){
              HTML(
                paste(
                  "<span style=\"color:red;font-size:16px\">",
                  as.character(icon("times-circle")),
                  section,
                  "Section Incomplete: Revisit This Tab Before 
                    Running Simulation"
                )
              )
            }else if(check_ok() == TRUE){
              HTML(
                paste(
                  "<span style=\"color:green;font-size:16px\">",
                  as.character(icon("check-circle")),
                  "Section Complete:" ,
                  section,
                  "Information Entered"
                )
              )
            }
          })
      })
      
    }
  )
}



