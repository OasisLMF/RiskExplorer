
filter_and_select_column <- function(data, 
                                     vec_type = "character",
                                     unique = TRUE,
                                     column_to_select, ...) {
  
  conditions <- enquos(...)
  
  filtered_data <- data %>% filter(!!!conditions)
  
  selected_column <- 
    filtered_data |> 
    dplyr::select({{ column_to_select }}) 
  
  if(vec_type == "character"){
    selected_column <- 
      selected_column |> 
      unlist() |> 
      as.character(selected_column)
  }
  
  if(unique == TRUE){
    selected_column <- 
      unique(selected_column)
  }
  
  return(selected_column)
}

split_string <- function(string, sep =","){
  
  if(length(string) > 0){
    as.character(
      strsplit(
        string, 
        split = sep)[[1]])
  }
}

