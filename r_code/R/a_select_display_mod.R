a_select_display_UI <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("loss_display"), choices = NULL, label = "Select Display")
  )
}

a_select_display_Server <- function(id, sim_output) {
  moduleServer(
    id,
    function(input, output, session) {
      
      observe({
        req(sim_output())
        updateSelectInput(session = session,
                          inputId = "loss_display",
                          selected = sim_output()$display_type[1],
                          choices = sim_output()$display_type)
      })
      
      return(reactive({input$loss_display}))
      
    }
  )
}