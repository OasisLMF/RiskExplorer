calc_intensity_rp <- function(data, intensity_vals, freq_var, intensity_var) {
  
  sapply(
    intensity_vals,
    function(x){
      sum(
        data[[freq_var]][x <= data[[intensity_var]]]
      )
    }
  ) 
}