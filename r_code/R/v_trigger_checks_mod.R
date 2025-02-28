v_trigger_checks_UI <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("table_warning_text"),
             style = "color:red;font-size:16px")
  )
}

v_trigger_checks_Server <- function(id, trigger_payouts, trigger_choices) {
  moduleServer(
    id,
    function(input, output, session) {
      
      section_ok <- reactiveVal(FALSE)
      table_ok <- reactiveVal(0)
      
      observe({
        
        req(trigger_payouts(), trigger_choices)
        
        table_check <- 
          trigger_payouts() |>
          dplyr::filter(Intensity!=""|
                          Damage_Percentage!="")
        
        if(nrow(table_check) > 1){
          table_check <- 
            sapply(table_check, as.numeric) |>
            as.data.frame()  
        }else{
          table_check <- 
            data.frame(Intensity = as.numeric(table_check[1]),
                       Damage_Percentage = as.numeric(table_check[2]))
        }
        
        if(any(is.na(table_check))){
          table_ok(FALSE)
          
        } else {
      
          v_check <- 
            --((nrow(table_check) > if (trigger_choices$curve_type == "Step") {
              0
            } else{
              1
            })&
              !is.unsorted(table_check$Damage_Percentage, strictly = TRUE) &
              !is.unsorted(if (trigger_choices$intensity == "Pressure" |
                               trigger_choices$intensity == "Percentage of Climatology" ) {
                -table_check$Intensity
              } else{
                table_check$Intensity
              }, strictly = TRUE) &
              all(table_check$Intensity > 0) &
              all(table_check$Damage_Percentage >= 0) &
              all(table_check$Damage_Percentage <= 100))
        
          table_ok(v_check)
        }
        
        if (table_ok() == 1) {
          output$table_warning_text <- 
            renderText({""})
        } else {
          output$table_warning_text <- 
            renderText({
              
              paste("Check table values. Note that all damage percentages must be 
                between 0 and 100%. Damage percentages must",
              ifelse(trigger_choices$intensity == "Pressure" |
                     trigger_choices$intensity == "Percentage of Climatology", 
                     "decrease", 
                     "increase"),
              "for higher values of the intensity metric. 
              No damage values should exceed 100% and any intensity values 
              filled in should have a corresponding damage percentage.")
            })
        }
      })
      
      observe({
        
        section_ok(FALSE)
        req(table_ok())
        
        if(table_ok() == 1){
          section_ok(TRUE)      
        }
        
      })
      
      
      return(list(table_ok = table_ok,
                  section_ok = section_ok))
      
    }
  )
}

