generate_hist_dt_drought <- function(table_data, display_var){
  
  table_data <- 
    table_data |> 
    dplyr::group_by(Year) |> 
    dplyr::summarise(Average = mean(!!sym(display_var)),
                     `Full Range Low` = min(!!sym(display_var)),
                     `Full Range High` = max(!!sym(display_var)),
                     `50% Data Range Low` = 
                       quantile(
                         !!sym(display_var), 
                         probs =  0.25,
                         na.rm = TRUE
                       ),
                     `50% Data Range High` = quantile(
                       !!sym(display_var), 
                       probs =  0.75,
                       na.rm = TRUE
                     )
    ) |> 
    dplyr::ungroup() |> 
    dplyr::arrange(Year) |> 
  DT::datatable(
    rownames = FALSE, 
    options = 
      list(
        dom = 'Bfrtip',
        buttons = list('csv')
      )
  ) |> 
  DT::formatCurrency(
    columns = 
      c(
        "Average", 
        "50% Data Range Low", 
        "50% Data Range High", 
        "Full Range Low",
        "Full Range High"
      ),
    currency = "",
    digits = 0
  )
  
}
