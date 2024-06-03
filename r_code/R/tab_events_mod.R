
events_text <-
  helpText(
    strong(
    "The Event Analysis tab displays outputs once hazard, exposure and 
    vulnerability have been completed and simulations have been run.
    This tab aims to provide more detailed information on the model's 
    output and to show the type of events that occur in the simulations. 
    The toggle allows you to view payout or policyholders impacted information 
    in different formats where appropriate."
    )
  )

tab_events_UI <- function(id) {
  ns <- NS(id)
   tagList(
    shiny::titlePanel("5.Event Analysis"),
    conditionalPanel(condition = "output.sim_run_success",
                     ns = ns,
                     events_text,
                     br(),
                     a_select_display_UI(ns('display1')),
                     br(),
                     a_historical_plot_UI(ns('plot1')),
                     a_individual_sim_UI(ns('sim_summary1')),
                     a_rp_view_UI(ns('rp_view1'))),
    page_nav_UI(ns("events"))
   )
}

tab_events_Server <- function(id, parent, sim_output) {
  moduleServer(
    id,
    function(input, output, session) {
      
      output$sim_run_success <-
        reactive({
          FALSE
          req(sim_output())
          TRUE
        })
      
      outputOptions(output, "sim_run_success", suspendWhenHidden = FALSE)  
      
      display_type <-
        a_select_display_Server('display1', 
                                 sim_output = sim_output)
      observe({
        req(display_type())
        display_var <- assign_display_var(display_type())
        
        display_fun <- 
          return_display_format(display_type(), 
                                sim_output()$curr,
                                sim_output()$peril,
                                sim_output()$expo_value)
      
      a_historical_plot_Server('plot1', 
                               sim_output = sim_output, 
                               display_var = display_var,
                               display_fun = display_fun)
      
      a_individual_sim_Server('sim_summary1',
                              sim_output = sim_output,
                              display_var = display_var,
                              display_fun = display_fun)

      a_rp_view_Server('rp_view1',
                       sim_output = sim_output,
                       display_var = display_var,
                       display_fun = display_fun)
      
      })
      
      page_nav_Server("events",
                      parent = parent,
                      prev_page  = "simulation", 
                      next_page = "losses")
      
      return(display_type)
    }
  )
}