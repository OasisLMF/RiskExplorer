l_generate_sim_summary_plot <- function(plot_data, 
                                        hline_data, 
                                        peril, 
                                        dataset, 
                                        display_var, 
                                        display_fun) {
  
  sim_count <- nrow(plot_data)
  
  display_var <-
    ifelse(display_var == "Payout as % of Asset Value", 
           "Payout", 
           display_var)
  
  if(dataset == "IBTrACS"){
    
    hline_data_hist <- 
      hline_data |>
      dplyr::select(Measure, `Historical Payout`)
    
    hline_data_unweighted <- 
      hline_data |>
      dplyr::select(Measure, `Unweighted Simulation Payout`)
    
    hline_data_weighted <- 
      hline_data |>
      dplyr::select(Measure, `Weighted Simulation Payout`)
    
  } else if (dataset == "Stochastic") {
    
    hline_data_simulated <- 
      hline_data |>
      dplyr::select(Measure, `Simulated Payout`)
  }
  
  plot_data <-
    plot_data |> 
      dplyr::mutate(
        plot_label = 
          paste(
          "<b>",
          "Payout Percentile:",
          "</b>",
          scales::label_percent(accuracy = 0.01)(Percentile),
          "<br>",
          "<b>",
          paste0(display_var,":"),
          "</b>",
          display_fun(plot_data[[display_var]])
        )
      )
  
  g <- 
    plot_data |>
    ggplot2::ggplot(aes(Percentile, !!sym(display_var), label = plot_label)) +
    theme(
      panel.background = element_rect(fill = "cornsilk1",
                                      colour = "cornsilk1"),
      panel.grid.minor = element_blank(),
      panel.border = element_rect(
        colour = "black",
        fill = NA,
        size = 0.5
      ),
      legend.key = element_rect(fill = "cornsilk1"),
      legend.position = "bottom",
      text = element_text(size = 12.5)
    ) +
    ggplot2::geom_line(color = "red2", size = 1.1, alpha = 0.7, linetype = "solid") + 
    ggplot2::scale_x_continuous(labels = scales::label_percent(accuracy = 0.1)) + 
    ggplot2::xlab("Percentile")
    
    g <- g + ggplot2::ylab(paste(display_var)) +
      ggplot2::scale_y_continuous(label = display_fun,
                                  limits = c(0, max(plot_data[[display_var]]))
                                  )
    if (dataset == "IBTrACS") {
      
      g <- 
        plotly::ggplotly(g, tooltip = c('plot_label')) |>
        plotly::add_lines(
          y = rep(hline_data_hist$`Historical Payout`[1], sim_count),
          x = seq(0, 1, by = 0.001),
          name = "Historic Payout",
          text =  ~ display_fun(hline_data_hist$`Historical Payout`[1]),
          hovertemplate = '%{text}'
        ) |>
        plotly::add_lines(
          y = rep(hline_data_unweighted$`Unweighted Simulation Payout`[1], sim_count),
          x = seq(0, 1, by = 0.001),
          text =  ~ display_fun(hline_data_unweighted$`Unweighted Simulation Payout`[1]),
          hovertemplate = '%{text}',
          name = "Unweighted Simulation Payout"
        ) |>
        plotly::add_lines(
          y = rep(hline_data_weighted$`Weighted Simulation Payout`[1], sim_count),
          x = seq(0, 1, by = 0.001),
          text =  ~ display_fun(hline_data_weighted$`Weighted Simulation Payout`[1]),
          hovertemplate = '%{text}',
          name = "Weighted Simulation Payout"
        ) |>
        layout(showlegend = TRUE)
      
    } else if (dataset == "Stochastic") {
      
      g <- 
        plotly::ggplotly(g, tooltip = c('plot_label')) |>
        plotly::add_lines(
          y = rep(hline_data_simulated$`Simulated Payout`[1], sim_count),
          x = seq(0, 1, by = 0.001),
          text =  ~ display_fun(hline_data_simulated$`Simulated Payout`[1]),
          hovertemplate = '%{text}',
          name = "Simulation Payout"
        ) |>
        layout(showlegend = TRUE)
    } else {
      
      hline_var <-
        paste("Expected", display_var)
      
      g <- 
        plotly::ggplotly(g, tooltip = c('plot_label')) |>
        plotly::add_lines(
          y = rep(hline_data[[hline_var]][1], sim_count),
          x = seq(0, 1, by = 0.001),
          name = "Simulation Payout",
          text =  ~ display_fun(hline_data[[hline_var]][1]),
          hovertemplate = '%{text}'
        )
    }
  
  g$x$data[[1]]$text <- gsub("plot_label: ", "", g$x$data[[1]]$text)
  
  return(g)
}
