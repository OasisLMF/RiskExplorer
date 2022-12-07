
observeEvent(input$r_prevpage, {
  updateTabsetPanel(session, "tabset",
                    selected = "analysis")
})


# 0.Tab specific Function for generating vulnerability graph
# (long-term move these to their own section)

r_graph_by_drop_generate<-function(data=r_graph_data_by_drop_dist,display=input$r_output_display,hline_data,IBTRACS=s_sim_ok_ibtracs){


  data<-data%>%mutate(`loss currency`=dollar(`SIMULATION AVERAGE LOSS`,accuracy=1,prefix=s_curr))%>%
    mutate(`loss percentage`=percent(`SIMULATION AVERAGE LOSS`,accuracy=0.01))
  
  hline_data<-hline_data%>%mutate(`loss currency`=dollar(y,accuracy=1,prefix=s_curr))%>%
    mutate(`loss percentage`=percent(y,accuracy=0.01))
  
  g_label<-ifelse(display=="Currency", "loss currency" ,"loss percentage")
  
  # g_label<-ifelse(display=="Currency","loss Percentage", "loss Currency")
  
  g<-data%>%
    ggplot(aes(rank,`SIMULATION AVERAGE LOSS`,label=!!sym(g_label)))+
    theme(
      panel.background = element_rect(fill = "cornsilk1",
                                      colour = "cornsilk1"),
      panel.grid.minor = element_blank(),
      panel.border = element_rect(colour = "black", fill=NA, size=0.5),
      legend.key=element_rect(fill="cornsilk1"),
      legend.position="bottom",
      text = element_text(size=12.5))+
    geom_line(color="red2",size=1.1,alpha=0.7,linetype="solid")+scale_x_reverse()+xlab("Simulated Loss Rank: Lowest Average Loss to Highest")
  
  if(display=="Currency"){
    g<-g+ylab(paste("Loss in",s_curr))+
      scale_y_continuous(label=scales::label_comma(suffix=s_curr),limits=c(0,max(data$`SIMULATION AVERAGE LOSS`)))
    
    if(IBTRACS==TRUE){
      g<-ggplotly(g,tooltip=c('rank','label'))%>%
        add_lines(y=rep(hline_data$y[1],s_sims_n),x=-s_sims_n:-1,name="Historic Loss",
                  text=~hline_data$`loss currency`[1], hovertemplate='%{text}')%>%
        add_lines(y=rep(hline_data$y[2],s_sims_n),x=-s_sims_n:-1,text=~hline_data$`loss currency`[2], 
                  hovertemplate='%{text}',name="Unweighted Simulation Loss")%>%
        add_lines(y=rep(hline_data$y[3],s_sims_n),x=-s_sims_n:-1, text=~hline_data$`loss currency`[3], 
                  hovertemplate='%{text}',name="Weighted Simulation Loss")%>%
        layout(showlegend=TRUE)
    }else{
      g<-ggplotly(g,tooltip=c('rank','label'))%>%
        add_lines(y=rep(hline_data$y[1],s_sims_n),x=-s_sims_n:-1,name="Simulation Loss",
                  text=~hline_data$`loss currency`[1], hovertemplate='%{text}')
    }
      
  }else{
    
    g<-g+ylab("Loss % of Asset Value")+scale_y_continuous(label=scales::label_percent(accuracy=0.01),limits=c(0,max(data$`SIMULATION AVERAGE LOSS`)))
    
    if(IBTRACS==TRUE){
      
    g<-ggplotly(g,tooltip=c('rank','label'))%>%
      add_lines(y=rep(hline_data$y[1],s_sims_n),x=-s_sims_n:-1,name="Historic Loss",
                text=~hline_data$`loss percentage`[1], hovertemplate='%{text}')%>%
      add_lines(y=rep(hline_data$y[2],s_sims_n),x=-s_sims_n:-1,text=~hline_data$`loss percentage`[2], 
                hovertemplate='%{text}',name="Unweighted Simulation Loss")%>%
      add_lines(y=rep(hline_data$y[3],s_sims_n),x=-s_sims_n:-1, text=~hline_data$`loss percentage`[3], 
                hovertemplate='%{text}',name="Weighted Simulation Loss")%>%
      layout(showlegend=TRUE)
    }else{
      g<-ggplotly(g,tooltip=c('rank','label'))%>%
        add_lines(y=rep(hline_data$y[1],s_sims_n),x=-s_sims_n:-1,name="Simulation Loss",
                  text=~hline_data$`loss percentage`[1], hovertemplate='%{text}')
    }
  }
  return(g)
}

r_graph_by_sim_generate<-function(data=s_output_values$yearly_loss_info,display=input$r_output_display){
  
  
  data<-data%>%mutate(`loss currency`=dollar(`Yearly Loss`,accuracy=1,prefix=s_curr))%>%
    mutate(`loss percentage`=percent(`Yearly Loss`,accuracy=0.01))
  
  
  
  g_label<-ifelse(display=="Currency", "loss currency" ,"loss percentage")
  head(data)
  
  g<-data%>%
    ggplot(aes(Percentile,`Yearly Loss`,label=!!sym(g_label)))+
    theme(
      panel.background = element_rect(fill = "cornsilk1",
                                      colour = "cornsilk1"),
      panel.grid.minor = element_blank(),
      panel.border = element_rect(colour = "black", fill=NA, size=0.5),
      legend.key=element_rect(fill="cornsilk1"),
      legend.position="bottom",
      text = element_text(size=12.5))+
    geom_line(color="red2",size=1.1,alpha=0.7,linetype="solid")+xlab("Percentile")
  
  if(display=="Currency"){
    g<-g+ylab(paste("Loss in",s_curr))+
      scale_y_continuous(label=scales::label_comma(suffix=s_curr),limits=c(0,max(data$`Yearly Loss`)))+
      scale_x_continuous(label=scales::label_percent(accuracy=0.1),limits=c(0,1))
    
    g<-ggplotly(g,tooltip=c('Percentile','label'))
    
  }else{
    
    g<-g+ylab("Loss % of Asset Value")+scale_y_continuous(label=scales::label_percent(accuracy=0.01),limits=c(0,max(data$`Yearly Loss`)))+
      scale_x_continuous(label=scales::label_percent(accuracy=0.1),limits=c(0,1))
    
    g<-ggplotly(g,tooltip=c('Percentile','label'))
    
  }
}


# 2. Exhibit 1: Expected loss and distribution metrics

# Table displaying EL and SD under the different methods


observe({
  
  req(input$s_simulation_run,input$r_output_display)
  
    if(s_sim_ok==TRUE&s_sim_ok_ibtracs==TRUE){
  
      output$r_el_table<-renderTable({
        
        r_el_table<-cbind(Measure=s_output_values$el[,"Measure"],
                          r_output_display_conversion*s_output_values$el[,c("Historical_Loss","Unweighted_Simulation_Loss","Weighted_Simulation_Loss")])
        
        if(input$r_output_display=="Currency"){
          r_el_table%>%mutate(Historical_Loss=dollar(Historical_Loss,prefix="",accuracy=1,suffix=s_curr),
                              Unweighted_Simulation_Loss=dollar(Unweighted_Simulation_Loss,prefix="",accuracy=1,suffix=s_curr),
                              Weighted_Simulation_Loss=dollar(Weighted_Simulation_Loss,prefix="",accuracy=1,suffix=s_curr))
        }else{
          r_el_table%>%mutate(Historical_Loss=sprintf("%0.2f%%",100*Historical_Loss),
                              Unweighted_Simulation_Loss=sprintf("%0.2f%%",100*Unweighted_Simulation_Loss),
                              Weighted_Simulation_Loss=sprintf("%0.2f%%",100*Weighted_Simulation_Loss))
        }
        
        
      },
      bordered=TRUE)
      
      # Plotly object with full distribution of results
      
      
      r_graph_data_by_drop_dist<-s_output_values$sims_by_loc%>%arrange(`SIMULATION AVERAGE LOSS`)%>%mutate(rank=seq(s_output_values$sims_n,1,by=-1),
                                                                                                       `SIMULATION AVERAGE LOSS`=`SIMULATION AVERAGE LOSS`*r_output_display_conversion)
      
      r_graph_data_hline<-data.frame(y=r_output_display_conversion*c(s_output_values$el$Historical_Loss[1],
                                                                     s_output_values$el$Unweighted_Simulation_Loss[1],
                                                                     s_output_values$el$Weighted_Simulation_Loss[1]),
                                     type=factor(c(1,2,3)),stringsAsFactors = FALSE)
      
      r_graph_by_drop_dist_output<-r_graph_by_drop_generate(r_graph_data_by_drop_dist,input$r_output_display,r_graph_data_hline,s_sim_ok_ibtracs)
      
      output$r_graph_by_drop_dist<-renderPlotly({
        r_graph_by_drop_dist_output                
      })
    
      output$r_downloadDataYearData <- downloadHandler(
        filename = function() {
          paste('Risk_Explorer_datayear_output_data-', Sys.Date(),'.csv', sep='')
        },
        content = function(con) {
          write.csv(s_output_values$sims_by_datayear, con)
        })
    
  }else if (s_sim_ok==TRUE&s_sim_ok_ibtracs==FALSE){
      
      output$r_el_table<-renderTable({
        
        r_el_table<-data.frame(Measure=s_output_values$el[,"Measure"],
                               Simulation_Loss=as.numeric(r_output_display_conversion*s_output_values$el[,c("Simulation_Loss")]))
        
        if(input$r_output_display=="Currency"){
          r_el_table%>%mutate(Simulation_Loss=dollar(Simulation_Loss,prefix="",accuracy=1,suffix=s_curr))
        }else{
          r_el_table%>%mutate(Simulation_Loss=sprintf("%0.2f%%",100*Simulation_Loss))
        }
      },
      bordered=TRUE)
        
        r_graph_data_by_drop_dist<-s_output_values$sims_by_loc%>%arrange(`SIMULATION AVERAGE LOSS`)%>%mutate(rank=seq(s_output_values$sims_n,1,by=-1),
                                                                                                               `SIMULATION AVERAGE LOSS`=`SIMULATION AVERAGE LOSS`*r_output_display_conversion)
        r_graph_data_hline<-data.frame(y=r_output_display_conversion*c(s_output_values$el$Simulation_Loss[1]),
                                       type=factor(c(1)),stringsAsFactors = FALSE)
        
        r_graph_by_drop_dist_output<-r_graph_by_drop_generate(r_graph_data_by_drop_dist,input$r_output_display,r_graph_data_hline,s_sim_ok_ibtracs)
        
        output$r_graph_by_drop_dist<-renderPlotly({
          r_graph_by_drop_dist_output                
        })
  }
  
  if (s_sim_ok==TRUE){ 
  
        a_loss_table<-reactive({
          
          
          if(s_curve_type=="Linear"){
            
            levels(s_output_values$yearly_loss_info$`Yearly Loss`)<-if(input$r_output_display=="Currency"){
              s_labels_curr
            }else{
              s_labels_percent
            }
            
            a_loss_table<-s_output_values$yearly_loss_info
            
          }else{
            
            a_loss_table<-s_output_values$yearly_loss_info%>%
              mutate(`Yearly Loss`=`Yearly Loss`*r_output_display_conversion)
            
            if(input$r_output_display=="Currency"){
              a_loss_table<-a_loss_table%>%mutate(`Yearly Loss`=factor(scales::dollar(`Yearly Loss`,prefix=s_curr),
                                                                             levels=scales::dollar(sort(`Yearly Loss`),prefix=s_curr)))
            }else{
              a_loss_table<-a_loss_table%>%mutate(`Yearly Loss`=factor(scales::percent(`Yearly Loss`,accuracy=0.1),
                                                                             levels=scales::percent(sort(`Yearly Loss`),accuracy=0.1)))
            }
            
          }
        })
        
        output$a_loss_freq_DT<-renderDataTable({
          
          if(s_sim_ok_ibtracs==TRUE){
            a_loss_table()%>%datatable()%>%
              formatPercentage(columns=3:5,digits=2)%>%formatCurrency(columns=2,currency="",digits=0)
          }else{
            a_loss_table()%>%
              datatable()%>%
              formatPercentage(columns=3:4,digits=2)%>%formatCurrency(columns=2,currency="",digits=0)
          }
          
        })
        
        output$a_loss_freq_chart<-renderPlotly({
          
          # Subtle difference in percentage label variable name as would not accept duplicates to get tooltips to work
          g<-a_loss_table()%>%mutate(`Percentage of Simulated Years`=percent(`Percentage of Simulation Years`,accuracy=0.01))%>%
            ggplot(aes(x=`Yearly Loss`,y=`Percentage of Simulation Years`,label=`Percentage of Simulated Years`))+
            geom_bar(stat="identity",fill="#D41F29",colour="black")+
            scale_y_continuous(name="Percentage of Simulation-Years",
                               labels = percent_format(accuracy = 0.1))+
            theme(
              panel.background = element_rect(fill = "cornsilk1",
                                              colour = "cornsilk1"),
              panel.grid.minor = element_blank(),
              panel.border = element_rect(colour = "black", fill=NA, size=0.5))
          
          ggplotly(g,tooltip=c("Yearly Loss", "label"))
          
        })
        
        outputOptions(output, "a_loss_freq_chart", suspendWhenHidden = FALSE)

        output$r_downloadCircleDropData <- downloadHandler(
          filename = function() {
            paste('Risk_Explorer_sim_output_data-', Sys.Date(),'.csv', sep='')
          },
          content = function(con) {
            write.csv(s_output_values$sims_by_loc, con)
          }
        )
        
        
    }
  })




        # 
        # output$r_downloadDataYearData <- downloadHandler(
        #   filename = function() {
        #     paste('Risk_Explorer_datayear_output_data-', Sys.Date(),'.csv', sep='')
        #   },
        #   content = function(con) {
        #     write.csv(s_output_values$sims_by_, con)
        #   })
    
  # if(s_curve_type=="Step"){
    

  #   
  # }else{
  #   
  #   a_payout_table<-reactive({
  #     
  #     a_payout_table<-s_output_values$yearly_payout_info%>%
  #       mutate(`Yearly Payout`=`Yearly Payout`*r_output_display_conversion)
  #     
  #     if(input$r_output_display=="Currency"){
  #       a_payout_table<-a_payout_table%>%mutate(`Yearly Payout`=dollar(`Yearly Payout`,prefix=s_curr,accuracy = 1))
  #     }else{
  #       a_payout_table<-a_payout_table%>%mutate(`Yearly Payout`=percent(`Yearly Payout`,accuracy=0.1))
  #                                                                      
  #     }
  #     
  #   })
  #   
  #   r_graph_data_by_sim_dist<-s_output_values$yearly_payout_info%>%mutate(`Yearly Payout`=`Yearly Payout` *r_output_display_conversion)
  #                                                                                                          
  #   output$a_payout_freq_DT<-renderDataTable({
  #     
  #     a_payout_table()%>%arrange(desc(Percentile))%>%datatable()%>%
  #       formatPercentage(columns=1,digits=1)
  #     
  #   })
  #   
  #   
  #   output$a_payout_freq_chart<-renderPlotly({
  #     
  #     r_graph_by_sim_generate(r_graph_data_by_sim_dist,input$r_output_display)
  #   })
  #   
  #   
  #   }



