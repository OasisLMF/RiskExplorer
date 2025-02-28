range_data_subset <- function(data, var_select, type){
  
  var_select <- eval(var_select)
  
  if(type =="min"){
    data |> 
      dplyr::group_by(Year) |> 
      dplyr::summarise({{var_select}} := min(!!sym(var_select))) 
  }else{
    data |> 
      dplyr::group_by(Year) |> 
      dplyr::summarise({{var_select}} := max(!!sym(var_select)))
  }
  
}