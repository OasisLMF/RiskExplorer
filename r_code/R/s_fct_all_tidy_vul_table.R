tidy_vul_table <- function(vul_table, vul_intensity ){
  
  vul_table <- 
    vul_table|>  
    dplyr::filter(Intensity != ""|
                    Damage_Percentage != "")
  
  if(nrow(vul_table) > 1){
    vul_table <- 
      sapply(vul_table,as.numeric) |> 
      as.data.frame()  
  }else{
    vul_table <-
      data.frame(Intensity = as.numeric(vul_table[1]),
                 Damage_Percentage = as.numeric(vul_table[2]))
  }
  
  vul_table <-
    rbind(
      if(vul_intensity == "Pressure" | 
         vul_intensity == "Percentage of Climatology"){
        c(999999,0)
      }else{
        c(0, 0)
      }, 
      vul_table) |> 
    dplyr::rename(intensity = Intensity, loss = Damage_Percentage) %>%
    dplyr::mutate(loss = loss/ 100) |> 
    tidyr::drop_na()
  
  return(vul_table)
}
