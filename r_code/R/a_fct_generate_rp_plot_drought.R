generate_rp_plot_drought <- function(plot_data, 
                                     display_var, 
                                     display_fun, 
                                     max_var) {

  g <- ggplot(data = plot_data) + 
       geom_line(aes(x = rp, y = !!sym(display_var)), color = "red2") + 
        scale_y_continuous(label = display_fun(),
                           limits = c(0, max_var)) +
        scale_x_log10(limits = c(1, 50)) +
        theme(
          panel.background = element_rect(fill = "cornsilk1",
                                          colour = "cornsilk1"),
          panel.grid.minor = element_blank(),
          panel.border = element_rect(colour = "black", fill=NA, size=0.5),
          legend.key = element_rect(fill = "cornsilk1"),
          legend.position = "bottom",
          text = element_text(size = 12.5))
  
  ggplotly(g)
  
}
