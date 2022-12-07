helptextUI <- function(return_text) {
  
  # Returns page-specific helptext. All in one place so easier to
  # edit and track. Note some smaller sections are in tabsUI
  # however all the main descriptions at the top of pages can be
  # found in here.
  
  text_to_print <- if (return_text == "intro") {
    helpText(h4("General Overview"), "Welcome to the IDF Oasis Risk Explorer.",
             strong("The central purpose of this tool is educational, serving as an introduction to the different 
                    considerations that go into modelling catastrophe risk with specific applications to parametric 
                    insurance."),
             "The tool is broken into six sections excluding the introduction tab.",
             strong("Please ensure you consult the help page which can be accessed using the links on each page.
             When using the tool it is suggested that you navigate through these tabs going from 
              left to right,"),"as this is the order in which they are intended to be completed.",br(),
             h4("What do I need to run the model?"),
             strong("All you need to run this model is some idea of the location and value of an asset or property in a region 
                      prone to tropical cyclones.")," If you do not know this but still wish to run the tool, simply enter
                      some made-up values e.g., select a location in the Caribbean gulf or NW Pacific and just enter an
                      arbitrary USD 100,000 asset value.",br(),br(),
                      strong("You do not need access to your own hazard/event sets to run the model 
                      as these are all contained in the tool."),
             br(),
             h4("Tab Guide: Inputs"), "The first three tabs require you to enter inputs specific to the risk you are modelling.",
             strong("These are exposure, hazard and vulnerability and make up the basic building blocks of virtually any catastrophe model."),
             " These are each described in more detail below:", br(), br(),
             tags$ul(
               tags$li(strong("Exposure: What are the assets you want to insure?"),
             " In this tab you will specify the location and total asset value that you want your insurance to cover."),
             br(), tags$li(strong("Hazard: Which types of natural perils are you interested in modelling (e.g. windstorm, earthquake)?"),
             "What data sources will you be using to model these? These data sources could be taken from the history or generated based 
             on scientific knowledge or statistical techniques."),
             br(), tags$li(strong("Vulnerability: How do physical events lead to damage to your asset and financial loss?"),
             "What intensity measure will be used to calculate damage sustained (e.g., wind speed/pressure etc.)? How much
             damage is caused for each value of the intensity measure? For example, if you have 100km/h winds vs 200km/h 
             winds how much extra damage will you expect to sustain?")),
             h4("Tab Guide: Simulation and Outputs"), "Once inputs have been entered in the previous tabs, 
             you have everything required to run the model. The following three tabs allow you to run the model and look at its outputs.
             These are each described below:",
             br(), br(),tags$ul( tags$li(strong("Simulation: This tab is where you run modelling and generate simulation output."),
             "Based on your entries in the previous sections, the model will generate a large number of
             simulated years by statistically sampling from the hazard data. This may take a short while to run."),
             br(), tags$li(strong("Event Analysis: This tab allows you to examine the model's output in more detail and get a better sense of 
             the type of events that occur in the simulations."),"This tab provides a range of exhibits that aim to answer questions you may have 
             the output. E.g., how often do different events and losses occur? What does a simulation actually 
             look like?"),
             br(), tags$li(strong("Losses: This tab analyses the financial loss and damage generated in your modelling.")," The Loss Analysis tab
             will show you the financial loss you would expect to see on average for your risk under different calculation methods.
             It will also show you the full range of simulation losses and other interesting metrics that will help you better understand the risk. 
             This tab also allows you to export modelling results into Microsoft Excel should you wish to do further analysis.")),
             br(),br())
  } else if (return_text == "exposureinput") {
    helpText(strong("Where is the asset you want to insure? The exposure tab is where you will specify the single location or area that you wish to model. You will also specify 
             the total value of the asset(s) you are interested in insuring. Individual locations and circular areas can be entered in the tool."),
             br(), br(), "There are three main inputs that you need to define here:",
             br(), br(),tags$ul(tags$li(strong("Step 1: The latitude/longitude co-ordinates of the location or centre of the area you are interested in covering."),
             " If you do not know these, you can either use the address search or click on any location on the map and these will be retrieved in the app. 
             Where you are looking to cover a larger area (e.g. a whole island), it is worth selecting a location that is close 
             to the centre of the area you wish to cover in order to ensure you aren't covering a larger area than necessary. The table below the map will show you 
             the currently selected latitude and longitude values."),
             br(), tags$li(strong("Step 2: The area over which your assets are located."),
             " If you are looking to model a single location, you will be able to skip this step as the area around the location being 
             covered is simply zero. If you are looking at modelling assets over a wider area rather than a single location, you will specify the radius of a circle in this section.
             This will define the total area to be modelled. You can easily experiment with different circle sizes using the 
             map below. Once both steps have been completed you can move on to the next tab."),
             br(),tags$li(strong("Step 3: Enter the total value of the assets you are covering and select an appropriate currency."),
              "This can be thought of as the total cost of re-building your assets and could also include any further economic loss from a catastrophe 
              (e.g., lost revenue from business interruption).")))
  } else if (return_text == "hazard1") {
    helpText(strong("What types of natural disasters are you modelling and what data are you going to use to do this? The hazard tab is where you specify the nature of the 
             events you are interested in modelling as well as what data source you will be using to model these events."),br(),br(),
             strong("Step 1: Choose and load the hazard data to be used. The following fields need to be specified before loading the hazard data:"),
             br(),br(), tags$ul(tags$li(strong("The perils you are interested in modelling."),
             "A peril is a specific type of disaster e.g., a windstorm or an earthquake."),
             br(), tags$li(strong("The source of the data used to model your chosen peril."),
             "This could be using historical observation data (e.g. IBTrACS data) or simulated (also known as stochastic) data put together by catastrophe modelling experts (e.g. Oasis, Aon).",
             ),
             br(), tags$li(strong("The specific region you are interested in modelling."),
             "Note that the region groupings available are likely to differ depending on the peril you select. This is due to different perils having 
             their roots in different natural phenomena and relying on data sources that may approach these groupings slightly differently.",
             strong("Based on your inputs in the exposure tab, the model should provide a suitable recommendation for which region to select here.")),
             br(), tags$li(strong("The meteorological agency to use as a data source."),"For IBTrACS data, several agencies record wind/track 
             measurements for each basin. These typically relate to national meteorological agencies e.g., TOKYO is the Japanese agency and CMA is the Chinese agency. 
             In cases where agencies cover different geographic areas within a basin, some advice may appear below the agency box to steer you in the right direction.",strong("For stochastic
                           datasets, simply select N/A here."))),
             br(), strong("Step 2: Visualise the hazard data you have loaded into the tool."),
             "This is useful for checking you've loaded the correct hazard data. For IBTrACS data this will also give you a sense of recent losses and how active the area 
             around your exposure is. Note that due to data limitations, only 6-hourly storm tracks and category 1 or above winds are displayed here for IBTrACS data. As such, 
             tracks displayed will differ slightly from the more precise and extensive tracks used in the tool's calculation engine. For stochastic hazard data, the exposure and area that 
             the model covers will be displayed.")
   } else if (return_text == "hazard2") {
    helpText(strong('Start with the peril box and work your way down the page, bearing in mind any recommendations the tool makes regarding
                    your selections.'), "Once you are happy with your selections click on ",strong("Load Hazard Data"),"before moving to the 
                    next step.",
             br(),br(),'Worldwide tropical cyclone can be modelled using IBTrACS data. Stochastic hazard sets are also available for a limited range 
             of regions.',strong(" Note that at present stochastic datasets are only available for Bangladesh and the Ginoza region in Japan for tropical cyclone. There is also a stochastic event set
                                 available for Karachi in Pakistan"), 
             ' Future versions of this tool will look to cover additional perils and datasets.',br(),br())
   } else if (return_text == "vulnerability1") {
    helpText(strong("How much damage do different events cause? In the Vulnerability tab you define how physical events translate into damage to 
            your exposure. You will define this as a relationship between your intensity measure (e.g., wind speed) and a damage percentage. 
            In the Risk Explorer, damage is measured as a percentage of the total asset value. It is assumed this directly corresponds to the financial cost of repairing any 
            damage. Note that this direct relationship between the intensity measure and financial loss also applies for parametric insurance covers, so this tab can effectively be used to model these."),
            br(), br(), tags$ul(tags$li(strong("Step 1: Specify your intensity measure."), "The intensity measure is a hazard intensity parameter that should be closely related to the likely damage caused by an event. 
             For example, wind speed or pressure would be suitable measures for a storm, as they closely relate to the amount of damage likely to be 
             caused. Recordings of the intensity measure within your defined exposure area will determine the damage sustained in an event."),
             br(),tags$li(strong("Step 2: Specify your vulnerability curve type."), " The curve type you enter determines how the damage percentages you specify change as the intensity measure increases/decreases. 
                          You can choose from a stepped or linear vulnerability curve. It is worth choosing both options and consulting the graph below to see how this works in practice.",br(),br(),
                          tags$ul(tags$li(strong("Step:"),"This curve replicates how most parametric covers work. The damage generated increases in \"steps\" corresponding to the highest specified 
                                          intensity measure exceeded. For example, with the default values in the grid below (these will appear once you've completed the first step), it would be 
                                          assumed that you would sustain damage amounting to 20% of your asset's value if wind speeds greater than 119km/h are recorded at your chosen exposure. However, 
                                          if winds exceeding 154km/h were recorded you would sustain damage amounting to 40% of your asset's value."),br(),
                                  tags$li(strong("Linear:"),"This curve is closer to the approach used in catastrophe modelling, where a more detailed approach is used to specify the damage generated at each 
                                          value of the intensity measure. The damage generated increases linearly for the values you enter in the grid. For example, with the default values below, it would be 
                                          assumed that you would sustain damage amounting to 20% of your asset's value if wind speeds of 119km/h are recorded and 40% of your asset's value if winds of 154km/h 
                                          were recorded. For wind speeds between these two points, it is assumed damage increases linearly with wind speed. For example, winds of 136.5km/h would lead to a 30% 
                                          damage whereas in the step function example, this would still be 20%."))),
             br(),tags$li(strong("Step 3: Enter your damage percentage at each selected level of intensity."),"This section determines how much damage is sustained at each point of the intensity measure you specify. 
                   The values you specify here and your Step 2 selection will determine the overall shape of the intensity-to-damage curve. Note that you can enter anywhere between one and six separate intensity-damage
                          rows here.")))
    } else if (return_text == "vulnerability2") {
      helpText(strong("The values for the intensity measure  or damage percentage in the table below are editable by double-clicking on the table.
               After making your edits, press Ctrl + Enter to save these and exit the table's edit mode.", style = "color:red"),strong("Make sure the intensity measures and damage percentages are entered in 
               ascending order (except for pressure, where damage values should only be entered in descending order)."),
               "Note that you do not need to use all six rows here if you wish to specify a simpler curve, and can leave any rows at the bottom blank.",br(),br(),
               "The default values in the table reflect the Saffir-Simpson Hurricane categories ranging from Tropical Storm to Category 5 Hurricane. You can also experiment with different intensity measure values 
               and damage percentages here. You may want to edit the damage percentages to reflect what you know about the cost of previous events for your area of exposure. 
               The graph below illustrates how much damage will be sustained for different intensity measure values based on the figures you have entered in the table and the curve selected in Step 2.",
               br(),br())  
    } else if (return_text == "sims") {
      helpText(strong("The Simulation tab is where you run your modelling. This process involves \"simulating\" a large number of years of events and losses 
                      based on the hazard data you have loaded.","Only run simulations once the exposure, hazard and vulnerability sections are complete. Check you are happy with your inputs, then 
              specify the number of simulations you wish to run before pressing \"Run Simulation\"."),
               br(),br(),
               "The more simulations you run, the more stable and reliable your output will be, however a higher number of simulations will take longer to run. Note that larger
             exposures and more active locations will also increase simulation runtime.", strong(" For stochastic datasets, it is recommended that you run 10,000 simulations, with this
             data each simulation represents a given year. However for IBTrACS Historical data, 2,000 sims should be enough to get reliable output as each simulation introduces more variation 
             on account of it representing a full 20+ years of historical data."), br(), br(),
               tags$a("A more detailed description of the simulation method can be found on the help page",
                      href="https://oasislmf.github.io/RiskExplorer/components/index_SimMethod.html",
                      target="_blank"),
               "however the below bullets give a simple explanation of what is happening during the calculation:",
             br(),br(), tags$ul(tags$li(strong("Step 1: Random sampling of points within a reasonable distance to your exposure."),
             "Each individual simulation represents one randomly selected area  within a reasonable distance of the exposure.  It may seem odd to do this when these randomly selected 
             locations are different to your exposure, however this is an important step which prevents over-generalising from a limited history and is the founding 
             principle of all catastrophe models. For example, if your exposure is within a very small area or is a single location, you could have been relatively 
             lucky and not had any significant wind events despite a number having just missed in the previous 30 years. If we just used the history at the exposure point, 
             we would assume there is zero risk when this is clearly not the case. Note that the simulation sample area on the hazard map shows the range within which these 
             simulated locations/areas are being selected from (the \"reasonable distance\" mentioned above)."),
             br(), tags$li(strong("Step 2: Identify the events in the hazard data that would lead to losses."),
             "For each area selected in step 1, the method looks at which events in the historical data would have led to losses based on values of the specified intensity measure in the vulnerability 
             section. Losses for the relevant events in each simulation will then be calculated for each simulation and data-year."),
             br(), tags$li(strong("Step 3: Average the losses for each year of data and simulation."),"This will give you the average loss across the history for each simulation."),  
             br(), tags$li(strong("Step 4: Apply weightings to the losses calculated in each simulation."),
             "In reality, areas closer to the exposure are likely to be more similar in their weather patterns and therefore
             more applicable to the exposure. We therefore give greater weight to simulations closer to the exposure in the final calculation of 
             the expected loss. The weighting applied here is based on distance of the simulated area to the exposure, so a simulation that falls further 
             away from your exposure gets a lower weighting."),
             br(), tags$li(strong("Step 5: Calculate the total weighted average loss across all simulations."),
             "A weighted average is calculated for the total loss over the hazard data for all simulations.
             This should give us a view of the expected loss for this cover which takes into account the variability in the data.In addition to the weighted simulation methodology, 
             the tool will also output results based purely on history at the exposure location and using a non-weighted simulation method for comparison so you can see the impact of the 
             weighting methodology. This is described in more detail in the output section. ")),br())
    }else if (return_text == "sims2") {
      helpText(strong("The Simulation tab is where you run your modelling. This process involves \"simulating\" a large number of years of events and losses 
                      based on the hazard data you have loaded.","Only run simulations once the exposure, hazard and vulnerability sections are complete. Check you are happy with your inputs, then 
              specify the number of simulations you wish to run before pressing \"Run Simulation\"."),
              br(),br(),
            "The more simulations you run, the more stable and reliable your output will be, however a higher number of simulations will take longer to run. Note that larger
             exposures and more active locations will also increase simulation runtime.", strong(" For stochastic datasets, it is recommended that you run 10,000 simulations, however for 
            IBTrACS Historical data, 2,000 should be enough to get reliable output as each simulation introduces more variation on account of it 
            really representing 20+ years of historical data."), br(), br(),
            tags$a("A more detailed description of the simulation method can be found on the help page",
                   href="https://oasislmf.github.io/RiskExplorer/components/index_SimMethod.html",
                   target="_blank"),
            "however the below bullets give a simple explanation of what is happening during the calculation:",
             br(),br(),tags$ul(tags$li(strong("Step 1: Filter the events in the stochastic dataset that are relevant to your exposure."),
             "The stochastic dataset is made up of a large number of simulated years, each with their own specific events. The first step of the calculation 
             excludes events that are too far away to impact your exposure area. Only events that occur within your exposure area are used in the subsequent calculations."),
             br(),tags$li(strong("Step 2: Randomly select years from the dataset for each simulation."),"The selected years from the stochastic data and their 
                          corresponding events will then be used to calculate losses in later steps. Note that as the years in the stochastic data are selected at random,
                          it is possible that certain years may repeat for a large number of simulations."), 
             br(),tags$li(strong("Step 3: Identify the events in each simulation that would lead to losses."),"This step looks at which events in your simulations would have 
             led to losses based on values of the specified intensity measure in the vulnerability section. These losses are then summed up across each simulation-year and capped at 
             your total asset value."),
             br(),tags$li(strong("Step 4: Average across losses by simulation to give an overall expected loss."),"Each simulation should have a total loss associated with it calculated 
             in step 3. This step averages across all of these simulation losses to give an overall expected loss.")))
  } else if (return_text == "help") {
    helpText("The link below will take you to the help site where you can read about the tool and how it works in more detail. It is strongly advised that 
             you look at these pages before attempting to run the model.")
  } else if (return_text == "analysis_summary") {
    helpText(strong("The Evant Analysis tab displays outputs once hazard, exposure and vulnerability have been completed and simulations have been run.
             This tab aims to provide more detailed information on the model's output and to show the type of events that occur in the simulations."))
  } else if (return_text == "analysis_ex1") {
    helpText(strong("Exhibit 1 aims to answer the question of which events in the historical data would have led to losses in your area of exposure,
             leaving aside the simulation modelling."),"The map displays historical tracks for any events that would have led to losses 
             based on the model's assumptions (i.e. would have fallen within the exposure loss radius,",
             tags$a("see help page for more information on this",
                    href="https://oasislmf.github.io/RiskExplorer/components/index_SimMethod.html",
                    target="_blank"),
             "). The table below provides a summary of each event that would have led to losses. Averaging the losses from these events across the number of years should give the 
             Historic Loss shown on the Loss Analysis tab.",strong("This is also sometimes referred to as the \"cat-in-a-box\" or \"cat-in-a-circle\" 
             loss in the insurance industry."),
             br(),br(),"Note that in many cases tracks are not precise as data is only available at 3-6 hour intervals which requires estimates to be made via 
             interpolation between those points. As such, tracks may not exactly match what you see on the hazard tab map as the storm track data used in this 
             exhibit comes directly from the tool and is more precise.")
  } else if (return_text == "analysis_ex2") {
    helpText(strong("Exhibit 2 allows you to look at the results of any individual simulation by selecting the relevant simulation number in the input box."),
            "The table immediately below gives a summary of the main outputs of the simulation. The map and corresponding table display the events in the history that would have led to losses
             at each simulated location. Note that loss triggering events are displayed as markers rather than tracks as in Exhibit 1. Only the track locations
             with the maximum intensity values (minimums for pressure) are displayed due to the memory limitations imposed by loading tracks for thousands of simulations.",br(),br())
  } else if (return_text == "analysis_ex2_2") {
    helpText(strong("Exhibit 2 allows you to look at the results of any individual simulation by selecting the relevant simulation number in the input box."),
            "The table immediately below gives a summary of the main outputs of the simulation. The map and corresponding table display the events in the dataset that 
            would have led to losses for each simulation. Events are displayed as markers at the location where their maximum intensity values (minimums for pressure) were recorded.",br(),br())
  } else if (return_text == "analysis_ex3") {
    helpText(strong("Exhibit 3 gives an estimate of how often storms of each Saffir-Simpson category occur in the history (if relevant) and simulation output:"),
             br(),br(), tags$ul(tags$li(strong("Frequency"), " refers to the number of storms of this category or above you would expect to see in a year. A frequency of 1 means that a 
                           storm would occur on average once a year."),
             br(), tags$li(strong("Return Period"), "refers to the average time you would have to wait before observing a storm of that category or above, e.g., a return 
             period of 5 years for a cat 2 storm means you would expect to have one storm at cat 2 or above every 5 years on average. ")),
             br(), "This exhibit should be useful for getting an idea of how common storms of each category are around your area of exposure as well as comparing the results of different
             simulation methods where available. Of course this is an average, and it is possible to have two 100-year events occur in subsequent years. Another way to think about return periods is the probability of occurrence in 
             any given year. A 10-year return period means there is a 1 in 10 (10%) chance of it happening in any given year. Note that the wind speed/pressure denotes where
             the category \"starts\", so represents a minimum for wind speed and a maximum for pressure.",br())
  } else if (return_text == "analysis_ex4") {
    helpText(strong("Exhibit 4 shows how likely you are to sustain different loss amounts over the course of a year (note this excludes the impact of weightings for IBTrACS data)."),"E.g., if the red bar shows 90% for a loss of zero, 
            then 90% of simulation-years lead to a total loss of zero. The table below provides some more context, displaying the relevant",
             tags$a("percentile",
                     href="https://oasislmf.github.io/RiskExplorer/components/index_Glossary.html#percentile",
                     target="_blank"), 
            "and weighting (where relevant). Note that for linear vulnerability curves where ranges are displayed, these include the higher amount and exclude the lower amount e.g.,
            0-20,000 USD would exclude losses of zero but include losses of USD 20,000.")
  } else if (return_text == "results_summary") {
    helpText(strong("The Loss Analysis tab displays outputs once hazard, exposure and vulnerability have been completed and simulations have been run.","The tab's purpose is to give you an idea
             of the range of losses generated by the model and how much loss to expect in an average year."))
  } else if (return_text == "results_1") {
    helpText("Exhibit 5 shows estimates of the expected loss under different calculation methods as well as the full distribution of the simulation output.
             The distribution shown on the graph by the solid red line orders the simulations from the highest to lowest loss so you can see the range of outcomes you 
             might expect.",strong("Note that for IBTrACS each simulation is the average across all data-years in the history so there will be individual years with much higher/lower 
             losses than the averages displayed in the graph."),"By contrast, for stochastic datasets, each simulation represents an individual simulation-year.","The expected loss under different 
             methods is also displayed by horizontal lines on the graph. The text below the graph describes what each method means and how it works.",
             br())
  } else if (return_text == "results_2") {
    helpText(tags$ul(tags$li(strong("Historical Loss: "), "This method takes an average over the history for your exposure point or area. Simulations don't factor in to this method
             at all and this method can simply be thought of as an annual average of the losses sustained over the period."),
             br(), tags$li(strong("Unweighted Simulation Loss: "), "This is the average annual loss across all your simulations with no weighting for proximity 
             to the exposure applied.",tags$a("More detail on the simulation approach can be found on the help page.",
                                              href="https://oasislmf.github.io/RiskExplorer/components/index_SimMethod.html",
                                              target="_blank")), 
             br(), tags$li(strong("Weighted Simulation Loss: "), "This is the average annual loss across all your simulations including the weighting for 
             proximity to the exposure applied.",tags$a("More detail on the simulation approach can be found on the help page.",
                                                         href="https://oasislmf.github.io/RiskExplorer/components/index_SimMethod.html",
                                                         target="_blank")),
             br()), "The table also shows the standard deviation which gives an estimate of the variability of the loss. The higher the standard deviation, the more variability 
             there is in losses across years/simulations. This variability is often equated with uncertainty and is one of the additional factors considered when structuring 
             and pricing insurance contracts.")
  } else if (return_text == "results_2_2") {
    helpText(tags$ul(tags$li(strong("Simulation Loss:"),"This is the only method of calculating the expected loss when using Stochastic hazard sets. It simply represents the average 
                                    annual loss across all simulations.")),
             br(), "The table also shows the standard deviation which gives an estimate of the variability of the loss. The higher the standard deviation, the more variability 
             there is in losses across years/simulations. This variability is often equated with uncertainty and is one of the additional factors considered when structuring 
             and pricing insurance contracts.")
  } else if (return_text == "results_3") {
    helpText("This section allows the user to export the results of the simulation model to an Excel file. There are two output files that
              can be downloaded:",br(),br(),
             tags$ul(tags$li(strong("Output by Simulation:"), "Each row in this file represents an individual simulated location/area on the map. The file gives the total
             loss averaged across all the historical years of data for each simulation, as well as the weighting that it is given
             in the final simulation calculation. The further away the simulated area is from the area of exposure, the lower the weighting given."),
             br(), tags$li(strong("Output by Simulation/Sim-Year:"), "Each row in this file represents the loss for a given year of the history for each simulation.")),
             br(), br())
  } else if (return_text == "results_3_2") {
    helpText("This section allows the user to export the results of the simulation model to an Excel file. There is one output file that
              can be downloaded:",br(),br(),
             tags$ul(tags$li(strong("Output by Simulation:"), "Each row in this file represents an individually simulated year from the hazard dataset. The file gives
                             the total loss for each simulated year of data.")),br())
  }
  text_to_print
  
}


