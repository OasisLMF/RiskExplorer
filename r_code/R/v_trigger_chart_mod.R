v_graph_generate <- function(data, var, intensity,intensity_unit, curve_type) {
  
  data <- 
    data |> 
    filter(Intensity != ""| Damage_Percentage != "")
  
  if(nrow(data) > 1){
    data <- 
      sapply(data, as.numeric) |> 
      as.data.frame()  
  }else{
    data <- 
      data.frame(Intensity = as.numeric(data[1]),
                 Damage_Percentage = as.numeric(data[2]))
  }
  
  g_data <-  
    rbind(
      if (intensity == "Pressure"|
          intensity == "Percentage of Climatology")
        c(0, max(data$Damage_Percentage)) 
      else c(0, 0), 
      data)
  
  # if(intensity == "Pressure"){
  #   g_data$Damage_Percentage
  # }
  
  if(curve_type == "Linear"){
    
    g_data <- 
      rbind(
        approx(g_data$Intensity, g_data$Damage_Percentage,
               xout = seq(min(g_data$Intensity),max(g_data$Intensity), by = 1)),
        data.frame(x = seq(max(g_data$Intensity),
                           to = 9999),
                   y = if(intensity == "Pressure"|
                          intensity == "Percentage of Climatology")
                     
                     rep(0, length(seq(max(g_data$Intensity), 
                                       to = 9999))) 
                   else
                     rep(max(g_data$Damage_Percentage),
                         length(seq(max(g_data$Intensity),
                                    to = 9999)))))|>
      dplyr::rename(Intensity = x,
                    Damage_Percentage = y)|>
      dplyr::mutate(`Damage_Percentage` = Damage_Percentage / 100) |>
      dplyr::mutate(`Damage Percentage` = percent(Damage_Percentage)) |>
      dplyr::arrange(Intensity)
    
  }else{
    
    g_data <- rbind(g_data,
                    if (intensity == "Pressure"|
                        intensity == "Percentage of Climatology")
                      c(9999, 0) else c(9999, max(data$Damage_Percentage)))|>
      dplyr::mutate(`Damage_Percentage` = Damage_Percentage / 100) |>
      dplyr::mutate(`Damage Percentage` = percent(Damage_Percentage)) |>
      dplyr::arrange(Intensity)
  }
  
  g_label <- 
    "Damage Percentage"
  
  g_min_x <- 0
  
  g <- 
    g_data |>
    ggplot(aes(Intensity, !!sym(var), label = !!sym(g_label))) + 
    theme(panel.background = element_rect(fill = "cornsilk1", 
                                          colour = "cornsilk1"), 
          panel.grid.minor = element_blank(), panel.border = 
            element_rect(colour = "black", fill = NA, linewidth = 0.5), 
          legend.key = element_rect(fill = "cornsilk1"), 
          legend.position = "bottom", text = element_text(size = 12.5))
  
  if(curve_type == "Step"){
    if (intensity == "Pressure"| 
        intensity == "Percentage of Climatology") {
      
      g <- 
        g + geom_step(color = "red2", size = 1.3, alpha = 0.7, 
                      linetype = "solid", direction ='vh') 
      g_min_x <- min(data$Intensity, na.rm = TRUE) * 0.95
    }else{
      g <- g + geom_step(color = "red2", size = 1.3, alpha = 0.7, 
                         linetype = "solid",direction='hv') 
      g_min_x <- 0
    }
  }else{
    if (intensity == "Pressure") {
      g <- g + geom_line(color = "red2", size = 1.3, alpha = 0.7, 
                         linetype = "solid")
      g_min_x <- min(data$Intensity, na.rm = TRUE) * 0.95
    }else{
      g <- g + geom_line(color = "red2", size = 1.3, alpha = 0.7, 
                         linetype = "solid") 
      g_min_x <- 0
    }
  }
  
  
  g <- g + labs(title = "Damage Percentage by Intensity", 
                x = paste(intensity,"(", intensity_unit, ")"), 
                y = "Damage - Percentage of Asset Value") +
    scale_y_continuous(labels = percent) + 
    coord_cartesian(xlim = c(g_min_x, max(data$Intensity, na.rm = TRUE) * 1.05), 
                    ylim = c(0,1.1))
  
  g <- ggplotly(g, tooltip = c("Intensity", "label"))
  
  return(g)
}



v_trigger_chart_UI <- function(id) {
  ns <- NS(id)
  
  uiOutput(ns("chart_ui"))
  
}

v_trigger_chart_Server <- function(id, trigger_payouts, trigger_choices, 
                                   table_ok) {
  moduleServer(
    id,
    function(input, output, session) {
      
      
      observe({
        
        
        ns <- session$ns
        
        if(isTruthy(table_ok$section_ok()) & 
           isTruthy(trigger_payouts()) & 
           isTruthy(trigger_choices$intensity) & 
           isTruthy(trigger_choices$intensity_unit)) {
          
          output$chart_ui <-
            renderUI({
              tagList(
                column(width = 9, 
                       plotlyOutput(ns("structure_plot"))
                )
              )
            })
          
          output$structure_plot <- 
            renderPlotly({
              
              v_graph_generate(data = trigger_payouts(), 
                               var = "Damage_Percentage", 
                               intensity = trigger_choices$intensity,
                               intensity_unit = trigger_choices$intensity_unit,
                               curve_type = trigger_choices$curve_type)  
            })
        
        } else {
          
          output$chart_ui <-
            renderUI({
              tagList(
                br(),
                column(width = 9, 
                       uiOutput(ns("structure_text"))
                ),
                br()
              )
            })
          
          output$structure_text <-
            renderText({
              paste("<span style=\"color:red;font-size:16px; font-weight:bold\">",
                    "Please enter Valid payout and intensity values to display 
                    chart here")
            })
          
        }
        
      })
      
    }
  )
}
