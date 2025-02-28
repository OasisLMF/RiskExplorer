vulnerability_payout_text <-
  helpText(
    strong(
      "The values for the intensity measure  or damage percentage in the table 
      below are editable by double-clicking on the table. After making your 
      edits, press Ctrl + Enter to save these and exit the table's edit mode.
    Make sure the intensity measures and damage percentages are entered 
    in ascending order (except for pressure or % of Climatology, where damage 
    values should only be entered in descending order).",
    style = "color:red"),
    "Note that you do not need to use all six rows here if you wish to specify 
    a simpler curve, and can leave any rows at the bottom blank."
    ,
    br(), 
    br(),
    "The default values in the table for Windstorm reflect the Saffir-Simpson 
    Hurricane categories ranging from Tropical Storm to Category 5 Hurricane and  
    are loosely based on realistic assumptions for a parametric cover for the 
    other perils. 
    You can also experiment with different intensity measure values and damage 
    percentages here. You may want to edit the damage percentages to reflect 
    what you know about the cost of previous events for your area of exposure. 
    The graph below illustrates how much damage will be sustained for different 
    intensity measure values based on the figures you have entered in the table 
    and the curve selected in Step 2.",
    br(),
    br()
    )

v_trigger_payouts_UI <- function(id) {
  ns <- NS(id)
  tagList(
    h4("Step 3: Specify your vulnerability function"),
    vulnerability_payout_text,
    DTOutput(ns("structure_DT"))
  )
}

v_trigger_payouts_Server <- function(id, trigger_choices, v_mappings) {
  moduleServer(
    id,
    function(input, output, session) {
      
      
      # Holds updated values from user DT edits
      updated_structure_tbl <- 
        reactiveValues(data = NULL)
      
      # Default values. Re-update when intensity unit/measure is changed.
      initial_structure <- 
        reactive({
          
          req(trigger_choices$intensity, trigger_choices$intensity_unit)
          
          data.frame(Intensity = as.numeric(
            v_mappings[v_mappings$unit == 
                         trigger_choices$intensity_unit, 
                       c("T0","T1", "T2", "T3", 
                         "T4", "T5")]), 
            Damage_Percentage = as.numeric(
              v_mappings[v_mappings$unit == 
                           trigger_choices$intensity_unit, 
                         c("P0","P1", "P2", "P3", 
                           "P4", "P5")]))
        })
      
      observe({
        
        req(initial_structure())
        updated_structure_tbl$data <- initial_structure()
      })
      
      # Stores all user inputted values in updated structure table
      observeEvent(input$structure_DT_cell_edit, {
        
        info <- 
          input$structure_DT_cell_edit |>
          filter(col %in% c(1, 2))
        
        for (x in 1:6) {
          updated_structure_tbl$data[x, 1] <- 
            as.numeric(info[info$row == x & info$col == 1, "value"])
          updated_structure_tbl$data[x, 2] <- 
            as.numeric(info[info$row == x & info$col == 2, "value"])
        }
        
        updated_structure_tbl$data <- 
          updated_structure_tbl$data |> 
          mutate(across(everything(), 
                        ~replace_na(as.character(.x), "")))
        
      })
      
      # Renders DT after user edits. Only displays after all necessary
      # inputs filled in.
      output$structure_DT <- 
        renderDT({
          
          req(trigger_choices$intensity, trigger_choices$intensity_unit)
          
          updated_structure_tbl$data |>
            DT::datatable(updated_structure_tbl$data, 
                          options = list(dom = "t",ordering = F), 
                          editable = list(target = "all", 
                                          disable = list(columns = c(0,3)))) |>
            DT::formatCurrency("Damage_Percentage",
                               currency = "%",
                               digits = 1,
                               before = FALSE) |>
            DT::formatCurrency("Intensity", 
                               digits = 1, 
                               currency = trigger_choices$intensity_unit,
                               before = FALSE) |>
            DT::formatStyle(c("Intensity", "Damage_Percentage"), 
                            color = "white",
                            backgroundColor = "#D41F29", 
                            fontWeight = "bold")
        })
      
      return(reactive(updated_structure_tbl$data))
    }
  )
}