
generate_hist_plot_drought <- function(plot_data, 
                                       display_var, 
                                       display_fun) {
  
  selected_levels <- 
    as.character(c(1983, 1988, 1993, 1998, 2003, 2008, 2013, 2018))
  
  intervals <- 
    c(0.5) 
  
  quantiles <- 
    c(0.5 - intervals/2, 0.5 + intervals/2) |> 
    sort()
  
  plot_data_iqr <- 
    plot_data |> 
    dplyr::mutate(Year = as.factor(Year)) |> 
    dplyr::group_by(Year) |> 
    dplyr::reframe(
      dplyr::across(!!sym(display_var), 
                    list(~ quantile(., quantiles)), 
                    .names ="{col}")) |> 
    cbind.data.frame(metric_type = "IQR") 
  
  plot_data_range <- 
    plot_data |> 
    dplyr::mutate(Year = as.factor(Year)) |> 
    dplyr::group_by(Year) |>
    dplyr::reframe(
      dplyr::across(!!sym(display_var),
                    list(~range(.)), 
                    .names ="{col}")) |> 
    cbind.data.frame(metric_type = "range") 
  
  plot_mean <- 
    plot_data |> 
    dplyr::mutate(Year = as.factor(Year)) |> 
    dplyr::group_by(Year) |> 
    dplyr::summarise({{display_var}} := mean(!!sym(display_var))) |> 
    dplyr::select(Year, !!sym(display_var)) |> 
    dplyr::mutate(round(!!sym(display_var)))
  
  mean_data_for_tooltip <- display_fun(plot_mean[[display_var]])
  
  tooltip_label_mean <- 
    paste("Simulated Mean", "<br>", 
          "Year:",plot_mean$Year,"<br>", 
          display_var,":", mean_data_for_tooltip)
  
  min_iqr <- range_data_subset(plot_data_iqr, display_var, "min")
  max_iqr <- range_data_subset(plot_data_iqr, display_var, "max")
  min_range <- range_data_subset(plot_data_range, display_var, "min")
  max_range <- range_data_subset(plot_data_range, display_var, "max")
  
  iqr_data_for_tooltip <-
    paste(
      display_fun(min_iqr[[display_var]]), 
      "-", 
      display_fun(max_iqr[[display_var]])
    )
  
  range_data_for_tooltip <-
    paste(
      display_fun(min_range[[display_var]]), 
      "-", 
      display_fun(max_range[[display_var]])
    )
  
  tooltip_label_iqr <- 
    rep(paste("Year:",min_iqr$Year,"<br>",
              "50%", display_var,"Simulation Range:",iqr_data_for_tooltip), 
        each = 2)   
  
  tooltip_label_range <- 
    rep(paste("Year:",min_iqr$Year,"<br>",
              "Full", display_var,"Simulation Range:",range_data_for_tooltip), 
        each = 2)
  
  g  <- ggplot2::ggplot() +
    ggplot2::geom_line(data = plot_data_range, 
                       ggplot2::aes(x = Year, y = !!sym(display_var), 
                                    text = tooltip_label_range), 
                       color = "grey") +
    ggplot2::geom_line(data = plot_data_iqr, 
                       ggplot2::aes(x = Year, y = !!sym(display_var), 
                                    text = tooltip_label_iqr),
                       color = "black")  +
    ggplot2::geom_point(data = plot_mean, 
                        ggplot2::aes(x = Year, y = !!sym(display_var), 
                                     text = tooltip_label_mean), 
                        color = "red2") +
    ggplot2::scale_x_discrete(
      labels = function(x) ifelse(x %in% selected_levels, x, "")
    ) +
    ## Sort out this line
    ggplot2::scale_y_continuous(labels = display_fun()) +
    ggplot2::ylab(paste("Simulated", display_var)) +
    ggplot2::xlab("Year") +
    theme(
      panel.background = element_rect(fill = "cornsilk1",
                                      colour = "cornsilk1"),
      panel.grid.minor = element_blank(),
      panel.border = element_rect(colour = "black", 
                                  fill = NA, 
                                  size = 0.5),
      legend.key=element_rect(fill="cornsilk1"),
      legend.position="bottom",
      text = element_text(size = 12.5))  
  
  plotly::ggplotly(g, tooltip = "text")
  
}