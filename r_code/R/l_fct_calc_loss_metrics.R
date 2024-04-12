# Not my finest work...
calc_loss_metrics <- function(metrics_data, peril, methods, total_value, display_fun ){
  
  if(peril == "Drought"){
    metrics_data <- 
    metrics_data |>
      dplyr::summarise(`Expected Payout` = mean(`Payout`),
                       `Standard Deviation Payout` = stats::sd(`Payout`),
                       `Expected Insured Impacted` = mean(`Localities Paid`),
                       `Standard Deviation Insured Impacted` = 
                         stats::sd(`Localities Paid`))  
    
    metrics_data |>  
      dplyr::mutate(Method = methods[1])
    
  }
   
}
