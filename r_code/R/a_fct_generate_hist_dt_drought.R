generate_hist_dt_drought <- function(table_data, display_var){
  
  table_data <- 
    table_data |> 
    dplyr::group_by(Year) |> 
    dplyr::summarise(Average = mean(!!sym(display_var)),
                     data_min = min(!!sym(display_var)),
                     data_max = max(!!sym(display_var)),
                     fifty_percent_min = 
                       quantile(
                         !!sym(display_var), 
                         probs =  0.25,
                         na.rm = TRUE
                       ),
                     fifty_percent_max = quantile(
                       !!sym(display_var), 
                       probs =  0.75,
                       na.rm = TRUE
                     )
    ) |> 
    dplyr::ungroup() |> 
    dplyr::mutate(
      `Average` = scales::label_comma(accuracy = 1)(Average), 
      `50% Data Range Low` = scales::label_comma(accuracy = 1)(fifty_percent_min), 
      `50% Data Range High` = scales::label_comma(accuracy = 1)(fifty_percent_min),
      `Full Range Low` = scales::label_comma(accuracy = 1)(data_min),
      `Full Range High` = scales::label_comma(accuracy = 1)(data_max)
      )|>  
    dplyr::select(-(data_min:fifty_percent_max)) |> 
    dplyr::arrange(Year)
  
  DT::datatable(
    table_data, 
    rownames = FALSE, 
    options = 
      list(
        dom = 'Bfrtip',
        buttons = list('csv')
      )
  )
  
}