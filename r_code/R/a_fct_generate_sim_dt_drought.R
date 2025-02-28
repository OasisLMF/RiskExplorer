generate_sim_dt_drought <- function(table_data, 
                                    display_var, 
                                    index_var,
                                    year, 
                                    sim, 
                                    display_fun){

  table_data <-
    table_data |>
    dplyr::filter(Sim == sim,
                  Year == year) |> 
    dplyr::select(Location, Longitude, Latitude, Index, !!sym(display_var)) 
  
  
    if(index_var == "Number of Dry Spell Days") {
      dt_format_fun <- 
        purrr::partial(
          DT::formatCurrency, 
          currency = "",
          digits = 0
        )
    } else {
      dt_format_fun <- 
        purrr::partial(
          DT::formatPercentage, 
          digits = 1
        )
      
      table_data <-
        table_data |> 
        dplyr::mutate(Index = Index / 100)
      
    }
  
  DT::datatable(table_data, 
                rownames = FALSE, 
                options = 
                  list(
                    dom = 'Bfrtip',
                    buttons = list('csv')
                  )) |> 
    DT::formatCurrency(
      columns = c("Longitude", "Latitude"),
      currency = "",
      digits = 4
    ) |> 
    dt_format_fun(
      columns = "Index"
    ) |> 
    DT::formatCurrency(
      columns = display_var,
      currency = "",
      digits = 0
    )
  
}

