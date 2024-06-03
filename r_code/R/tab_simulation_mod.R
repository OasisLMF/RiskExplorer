drought_simulation_text <-
  helpText(
    strong(
      "The Simulation tab is where you run your modelling. This process involves 
      \"simulating\" a large number of years of events and losses based on the 
      hazard data you have loaded.",
      "Only run simulations once the exposure, hazard and vulnerability sections 
      are complete. Check you are happy with your inputs, then specify the number 
      of simulations you wish to run before pressing \"Run Simulation\"."
    ),
    br(),
    br(),
    "The more simulations you run, the more stable and reliable your output will 
    be, however a higher number of simulations will take longer to run. Note that 
    larger exposures and more active locations will also increase simulation 
    runtime.",
    strong(
      "For stochastic datasets, it is recommended that you run 10,000 simulations, 
      with this data each simulation represents a given year. However for IBTrACS 
      Historical data, 2,000 sims should be enough to get reliable output as each 
      simulation introduces more variation on account of it representing a full 20+ 
      years of historical data. 
      Drought also includes a large number of historical years as part of a 
      'simulation. Most of the variability here will come from the historical 
      year with a high degree of spatial correlation within a region, as such a 
      much smaller number of sims is needed for convergence. "
    ),
    br(),
    br(),
    tags$a(
      "A more detailed description of the simulation method can be found on the 
      help page",
      href = "https://oasislmf.github.io/RiskExplorer/components/index_SimMethod.html",
      target = "_blank"
    ),
    "however the below bullets give a simple explanation of what is happening during the calculation:",
    br(),
    br(),
    tags$ul(
      tags$li(
        strong(
          "Step 1: Subset CHIRPs data for exposure area and calculate intensity 
          metric values."
        ),
        " The CHIRPs dataset used contains high-resolution prcepitation readings 
        across 5-day time periods for many years at a fine resolution.
        This makes it a large dataset. The first step is to subset the data for 
        the area we are interested in and calculate the relevant intensity values
        for any potential location in the exposure area for each year during the 
        growing season specified"
      ),
      br(),
      tags$li(
        strong(
          "Step 2: Simulate individual policyholders at random locations within 
          the exposure area."
        ),
        " Allocate the number of policyholders specified in the exposure tab to 
        random locations within the exposure for each simulation. This introduces 
        additional variability and in practice these types of schemes will likely 
        not know exactly where policyholders are located. "
      ),
      br(),
      tags$li(
        strong("Step 3: Calculate the payouts for each simulated location and 
               historical year."),
        " Examine the intensity metric and vulnerability curve at each simulation 
        location and use this to derive a payout for each simulation-historic 
        year. This gives a complete simulated history for each location."
      ),
      br(),
      tags$li(
        strong(
          "Step 4: Average across all simulated locations and historic years to 
          calculate expected payout and standard deviation. "
        ),
        " Other calculations will also be performed at this stage to feed the 
        Events and Payouts tabs."
      ),
      br()
    )
  )
  
tc_simulation_text <-
  helpText(
    strong(
      "The Simulation tab is where you run your modelling. This process involves 
      \"simulating\" a large number of years of events and losses based on the 
      hazard data you have loaded.",
      "Only run simulations once the exposure, hazard and vulnerability sections 
      are complete. Check you are happy with your inputs, then specify the number 
      of simulations you wish to run before pressing \"Run Simulation\"."
    ),
    br(),
    br(),
    "The more simulations you run, the more stable and reliable your output will 
    be, however a higher number of simulations will take longer to run. Note that 
    larger exposures and more active locations will also increase simulation 
    runtime.",
    strong(
      "For stochastic datasets, it is recommended that you run 10,000 simulations, 
      with this data each simulation represents a given year. However for IBTrACS 
      Historical data, 2,000 sims should be enough to get reliable output as each 
      simulation introduces more variation on account of it representing a full 20+ 
      years of historical data. 
      Drought also includes a number of historical years as part of a 'simulation',
      most of the variability here will come from the historical year with a high 
      degree of spatial correlation within a region, as such a much smaller 
      number of sims is needed for convergence. "
    ),
    br(),
    br(),
    tags$a(
      "A more detailed description of the simulation method can be found on the 
      help page",
      href = "https://oasislmf.github.io/RiskExplorer/components/index_SimMethod.html",
      target = "_blank"
    ),
    "however the below bullets give a simple explanation of what is happening during the calculation:",
    br(),
    br(),
    tags$ul(
      tags$li(
        strong(
          "Step 1: Random sampling of points within a reasonable distance to your exposure."
        ),
        "Each individual simulation represents one randomly selected area  within 
        a reasonable distance of the exposure.  It may seem odd to do this when 
        these randomly selected locations are different to your exposure, 
        however this is an important step which prevents over-generalising from 
        a limited history and is the founding principle of all catastrophe models. 
        For example, if your exposure is within a very small area or is a single 
        location, you could have been relatively lucky and not had any significant 
        wind events despite a number having just missed in the previous 30 years. 
        If we just used the history at the exposure point, we would assume there 
        is zero risk when this is clearly not the case. Note that the simulation 
        sample area on the hazard map shows the range within which these simulated 
        locations/areas are being selected from (the \"reasonable distance\" 
        mentioned above)."
      ),
      br(),
      tags$li(
        strong(
          "Step 2: Identify the events in the hazard data that would lead to losses."
        ),
        "For each area selected in step 1, the method looks at which events in the 
        historical data would have led to losses based on values of the specified 
        intensity measure in the vulnerability section. Losses for the relevant 
        events in each simulation will then be calculated for each simulation and 
        data-year."
      ),
      br(),
      tags$li(
        strong("Step 3: Average the losses for each year of data and simulation."),
        "This will give you the average loss across the history for each simulation."
      ),
      br(),
      tags$li(
        strong(
          "Step 4: Apply weightings to the losses calculated in each simulation."
        ),
        "In reality, areas closer to the exposure are likely to be more similar 
        in their weather patterns and therefore more applicable to the exposure. 
        We therefore give greater weight to simulations closer to the exposure in 
        the final calculation of the expected loss. The weighting applied here is 
        based on distance of the simulated area to the exposure, so a simulation 
        that falls further away from your exposure gets a lower weighting."
      ),
      br(),
      tags$li(
        strong(
          "Step 5: Calculate the total weighted average loss across all simulations."
        ),
        "A weighted average is calculated for the total loss over the hazard data 
        for all simulations. This should give us a view of the expected loss for 
        this cover which takes into account the variability in the data. In 
        addition to the weighted simulation methodology, the tool will also 
        output results based purely on history at the exposure location and using 
        a non-weighted simulation method for comparison so you can see the impact 
        of the weighting methodology. This is described in more detail in the output 
        section. "
      )
    ),
    br()
  )



tab_simulation_UI <- function(id) {
  ns <- NS(id)
  tagList(
    titlePanel("4.Simulation"),
    display_help_text_UI(ns("help_text_simulation")),
    section_complete_sims_UI(ns("hazard")),
    section_complete_sims_UI(ns("exposure")),
    section_complete_sims_UI(ns("vulnerability")),
    s_run_simulation_UI(ns("sim_run1")),
    page_nav_UI(ns("simulation"))
  )
}

tab_simulation_Server <- function(id, 
                                  parent, 
                                  hazard_data, 
                                  exposure_data, 
                                  vulnerability_data, 
                                  pentad_mappings, 
                                  vulnerability_mappings) {
  moduleServer(
    id,
    function(input, output, session) {
      
      simulation_text <- 
        reactive({
          
          req(hazard_data$selected_hazard_mappings())
          
          if(hazard_data$selected_hazard_mappings()[["peril"]] == "Drought") {
            drought_simulation_text
          } else {
            tc_simulation_text
          }
        
      })
      
      observe({
        
        req(simulation_text())
        
        display_help_text_Server(
          "help_text_simulation",
          text = simulation_text()  
        )
        
      })
      
      section_complete_sims_Server("hazard", 
                                   check_ok = hazard_data$tab_check_ok, 
                                   section =  "Hazard")
      
      section_complete_sims_Server("exposure", 
                                   check_ok = exposure_data$tab_check_ok, 
                                   section =  "Exposure")
      
      section_complete_sims_Server("vulnerability", 
                                   check_ok = vulnerability_data$tab_check_ok, 
                                   section =  "Vulnerability")
      
      sim_output <- 
        s_run_simulation_Server("sim_run1",
                                hazard_data = hazard_data,
                                exposure_data = exposure_data,
                                vulnerability_data = vulnerability_data,
                                vulnerability_mappings = vulnerability_mappings,
                                pentad_mappings = pentad_mappings)
      
      page_nav_Server("simulation",
                      parent = parent,
                      prev_page  = "vulnerability", 
                      next_page = "events")
      
      return(sim_output)
    }
  )
}
