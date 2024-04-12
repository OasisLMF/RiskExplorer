

return_display_format <- function(display_type, curr, peril, insured_value) {
  
  format_display <- function(x = NA) {
    
    if(display_type == "Currency") {
      
      scale_factor <-
        ifelse(peril == "Windstorm", insured_value, 1)
      
      if(is.na(x[1])){
        label_comma(suffix = paste0(curr," "), accuracy = 1)
      } else {
        label_comma(suffix = paste0(curr," "), accuracy = 1)(x * scale_factor) 
      }
    } else if (display_type == "% of Asset Value") {
      if(is.na(x[1])){
        label_percent(accuracy = 0.01)
      } else {
        label_percent(accuracy = 0.01)(x)
      }
    } else {
      if(is.na(x[1])){
        label_comma()
      } else {
        label_comma()(x)
      }
    }
    
  }
  
  return(format_display)
}

