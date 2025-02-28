pop_sample <- function(flag, 
                       no_localities, 
                       no_insured){
  
  if (flag == 1) {
    # Check if this definitely works
    pop_sample <- 
      sample(1:no_localities, 
             size = no_insured, 
             replace = TRUE) |> 
      vctrs::vec_count() |>
      tidyr::complete(key = 1:no_localities, 
                      fill = list(count = 0)) |>
      dplyr::arrange(key)
    
    no_people <- c(pop_sample$count)
  } else {
    no_people <- rep(round(no_insured / no_localities), 
                     no_localities)
  }
  
  return(no_people)
}
