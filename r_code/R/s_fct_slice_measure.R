slice_measure <- function(data, 
                          intensity_var, 
                          intensity_measure) {
  
  if(intensity_measure == "Pressure") {
    
      data |>
      dplyr::slice_min(
        !!sym(paste0(intensity_var)),
        with_ties = FALSE
      )
    
  } else {
    
  
      data |>
      dplyr::slice_max(
        !!sym(paste0(intensity_var)),
        with_ties = FALSE
      )
  }
  
}