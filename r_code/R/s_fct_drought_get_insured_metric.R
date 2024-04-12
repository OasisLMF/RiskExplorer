get_insured_metric_for_year <- function(nc_file, 
                                        year_var, 
                                        years, 
                                        measure_var, 
                                        window_start = NA,
                                        window_end = NA) {
  
  if( measure_var == "insured_metric") {
    start_index <- c(1, 1, which(years == year_var))
    count_index <- c(-1, -1, 1)
  } else {
    pentad_range <- window_end - window_start + 1
    start_index <- c(1, 1, window_start, which(years == year_var))
    count_index <- c(-1, -1, pentad_range, 1)
  }
  ncvar_get(nc_file, measure_var, start = start_index, count = count_index)  
}
