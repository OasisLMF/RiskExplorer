generate_payout_freq_plot <- function(payout_freq_data, display_var) {
  
  browser()
  if(display_var == "Payout") {
    xlab <- "Individual Yearly Payout"
  } else if( display_var == "Payout as % of Asset Value") {
    xlab <- "Individual Yearly Payout"
  } else {
    xlab <- "Policyholder Impacted?"
  }
  
  g <-
    payout_freq_data |> 
    ggplot(
      aes(
        x = !!sym(xlab), 
        y = `Percentage`, 
        label = `Percentage of Simulated Location Years`
      )
    ) +
    geom_bar(stat = "identity",
             fill = "#D41F29",
             colour = "black") +
    scale_y_continuous(name = "Percentage of Simulated Location Years",
                       labels = scales::percent_format(accuracy = 0.1)) +
    theme(
      panel.background = element_rect(fill = "cornsilk1",
                                      colour = "cornsilk1"),
      panel.grid.minor = element_blank(),
      panel.border = element_rect(
        colour = "black",
        fill = NA,
        size = 0.5
      )
    )
 
  ggplotly(g, tooltip = c(xlab, "label"))
}
