intensity_to_loss_calc <- function(intensity_data, 
                                   vul_table, 
                                   vul_measure, 
                                   vul_curve_type){
  
  vul_table$loss_factor <- 0
  payout <- c(0)
  if(vul_curve_type == "Linear"){
    
    for (i in 2:(nrow(vul_table)-1)){
      
      vul_table$loss_factor[i] <-
        (vul_table$loss[i + 1] - vul_table$loss[i]) /
        (vul_table$intensity[i + 1] - vul_table$intensity[i])
    }
  }
  
  if(vul_measure == "Pressure"|
     vul_measure == "Percentage of Climatology"){
    
    for (i in 1:length(intensity_data)) {
      
      row_select <- 
        sum(vul_table$intensity >= intensity_data[i])
      
      payout[i] <- 
        vul_table$loss[row_select] +
        (intensity_data[i]- vul_table$intensity[row_select]) *
        vul_table$loss_factor[row_select]
    }
    
  }else{
    
    for (i in 1:length(intensity_data)) { 
      
      row_select <- 
        sum(vul_table$intensity <= intensity_data[i])
      
      payout[i] <- 
        vul_table$loss[row_select] +
        (intensity_data[i] - vul_table$intensity[row_select])*
        vul_table$loss_factor[row_select]
    }
  }
  
  payout[is.na(payout)] <- 0
  
  return(payout)   
}
