process_payout_freq_data <- function(sim_data, 
                                     display_var, 
                                     display_fun, 
                                     value_per_insured) {
  browser()
  if(display_var == "Payout") {
    payout_breaks <-
      c(-Inf,0,0.2,0.4,0.6,0.8,1) * value_per_insured  
    xlab <- "Individual Yearly Payout"
      
  } else if( display_var == "Payout as % of Asset Value") {
    payout_breaks <-
      c(-Inf,0,0.2,0.4,0.6,0.8,1)
    xlab <- "Percentage of Asset Value"
    
  } else {
    payout_breaks <- c(-Inf, 0.5, Inf)
    xlab <- "Policyholder Impacted?"
    
  }
  
  label_breaks <- character(0)
  
  if( display_var != "Insured Impacted") {
    
    for (i in 2:(length(payout_breaks) - 1) ){
      label_breaks[i] <-
        paste(
          display_fun(payout_breaks[i]),
          "-",
          display_fun(payout_breaks[i + 1])
        )
    }
    
    label_breaks[1] <- "No Loss"
    
  } else {
    
    label_breaks[1] <- "Not Impacted"
    label_breaks[2] <- "Impacted"
    
  }
  
  total_sim_locs <- nrow(sim_data)
  
  payout_freq_data <- 
    sim_data |> 
    dplyr::mutate(
      !!sym(xlab) := 
        cut(
          Payout,
          breaks = payout_breaks,
          labels = label_breaks,
          right = TRUE
        )
    ) |> 
    dplyr::group_by(!!sym(xlab)) |> 
    dplyr::summarise(
      `Percentage` =  n() / total_sim_locs,
      `Number of Simulated Location Years` =  n()
    ) |> 
    dplyr::ungroup() |> 
    dplyr::mutate(
      Percentile = cumsum(`Percentage`),
      `Number of Simulated Location Years` = 
        scales::dollar(
          `Number of Simulated Location Years`,
          prefix = "",
          accuracy = 1
        )
    ) |> 
    dplyr::mutate(
      `Percentage of Simulated Location Years` = 
        percent(
          `Percentage`, 
          accuracy = 0.01
        ),
      `Percentile` = 
        percent(
          `Percentile`, 
          accuracy = 0.01
        )
    )
  
}
