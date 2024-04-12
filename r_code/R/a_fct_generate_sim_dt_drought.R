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
    dplyr::select(Location, Longitude, Latitude, Index, !!sym(display_var)) |> 
    dplyr::mutate(Longitude = label_currency(accuracy = 0.0001, 
                                             prefix = "")(Longitude),
                  Latitude = label_currency(accuracy = 0.0001, 
                                            prefix = "")(Latitude),
                  Index = 
                    if(index_var == 
                       "Percentage of Climatology") {
                        label_currency(accuracy = 0.1, 
                                             prefix = "")(Index)
                    } else {
                      label_currency(accuracy = 1, prefix = "")(Index)
                    },
                  !!sym(display_var) := display_fun(!!sym(display_var))
                  )
  
  DT::datatable(table_data, 
                rownames = FALSE, 
                options = 
                  list(
                    dom = 'Bfrtip',
                    buttons = list('csv')
                  )) 
  
  
}