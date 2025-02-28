ibtracs_basin_agency <- data.frame(BASIN = c("NA", "EP", "WP", 
                                     "NI", "SI", "SP","SA"), 
                                 AGENCY1 = c("USA", "USA", "USA", "NEWDELHI", 
                                             "REUNION", "WELLINGTON","USA"), 
                                 AGENCY2 = c(NA, NA, "TOKYO","USA", 
                                             "BOM", "BOM", NA), 
                                 AGENCY3 = c(NA, NA, "CMA", 
                                             NA, NA, "NADI", NA))

h_load_data_UI <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      column(width = 2,
             actionButton(ns("hazard_data_load"), label = "Load Hazard Data")),
      column(width = 3,
             actionButton(ns("hazard_display"),
                          label = "Visualise Hazard Data (Optional)")
      )
    ),
    br(),
    htmltools::span(uiOutput(ns('hazard_complete'),
                             style="color:green;font-size:16px"))
  )
}

h_load_data_Server <- function(id, 
                               h_mappings, 
                               peril_data_choices, 
                               region_agency_choices,
                               select_region_map_proxy) {
  moduleServer(
    id,
    function(input, output, session) {
      
      selected_data_mappings <- 
        eventReactive(input$hazard_data_load,{
          
          req(peril_data_choices$peril_choice(),
              peril_data_choices$dataset_choice(),
              region_agency_choices$region_choice(),
              region_agency_choices$agency_choice())
          
          h_mappings_selected <-
            filter_and_select_column(h_mappings, 
                                     vec_type = "character", 
                                     column_to_select = colnames(h_mappings), 
                                     unique = FALSE, 
                                     peril == peril_data_choices$peril_choice(),
                                     dataset == peril_data_choices$dataset_choice(),
                                     region_name == region_agency_choices$region_choice())
          
          
          names(h_mappings_selected) <- 
            colnames(h_mappings)
          
          h_mappings_selected <-
            c(h_mappings_selected, 
              agency_selected = region_agency_choices$agency_choice())
          
          h_mappings_selected
        }
        )
      
      observeEvent(input$hazard_data_load,{
        
        req(selected_data_mappings())
        
        h_display_text <- paste(peril_data_choices$peril_choice(),
                                peril_data_choices$dataset_choice(),
                                region_agency_choices$region_choice(),
                                region_agency_choices$agency_choice(), 
                                sep = "/")
        
        output$hazard_complete <- renderText({
          paste(as.character(icon("check-circle")), 
                "Section Complete: Hazard data loaded with following 
                selections made:",
                h_display_text)
        })
        
        showNotification("Hazard Data Loaded")
      })
      
      observeEvent(input$hazard_display, {
        
        req(
          selected_data_mappings(), 
          region_agency_choices$select_region_map_proxy()
        )
        
        if(peril_data_choices$dataset_choice() == "IBTrACS Historical Data") {
          # 
          region_code <-
            h_mappings |> 
            dplyr::filter(
              dataset == "IBTrACS Historical Data",
              region_name == region_agency_choices$region_choice()
            ) |> 
            dplyr::select(region_code)
          
          region_code <-
            gsub("\\\\", "", region_code$region_code[1])
          
          shape_layer <-
            paste0(
              region_code,
              "_",
              region_agency_choices$agency_choice()
            )
          
          shape_data <- 
            sf::st_read(dsn = "./data/hazard_preview_layers",
                        layer = shape_layer)
          
          region_agency_choices$select_region_map_proxy() |> 
            leaflet::clearImages() |> 
            leaflet::clearGroup("hist_data") |> 
            leaflet::addPolylines(
              data = shape_data, 
              group = "hist_data",
              weight = 1, 
              opacity = 1,
              color = "red",
              label = ~name
            )
          
          showNotification("Hazard Preview Displaying Most Recent 10 Years' 
                           Cyclone Activity Loaded on Region Select Map")
          
        } else if (peril_data_choices$dataset_choice() == "CHIRPs Historical Data") {
          
          region_code <-
            h_mappings |> 
            dplyr::filter(
              dataset == "CHIRPs Historical Data",
              region_name == region_agency_choices$region_choice()
            ) |> 
            dplyr::select(region_code)
          
          raster_data <-
            raster::raster(
              paste0("./data/hazard_preview_layers/", region_code, "_drought.tif")
            )
          
          index_bins <-
            c(0, 100, 200, 300, 400, 500, 750, 1000, 1500, 9999 )
          
          index_palette_colors <- RColorBrewer::brewer.pal(9, "Spectral")
          
          map_palette <-
            leaflet::colorBin(palette = index_palette_colors,
                              bins = index_bins,
                              right = FALSE)
          
          crs(raster_data) <- CRS("+proj=longlat +datum=WGS84 +no_defs")
          
          region_sf <- 
            data.frame(
              poly_lng = selected_data_mappings()["poly_lng"],
              poly_lat = selected_data_mappings()["poly_lat"],
              region_name = selected_data_mappings()["region_name"]
            ) |> 
            pull_sf_mapping_data()
          
          raster_data <-
            raster::crop(raster_data, region_sf) |> 
            raster::mask(region_sf)
            
          region_agency_choices$select_region_map_proxy() |> 
            leaflet::clearImages() |> 
            leaflet::removeControl(layerId = "Legend") |> 
            leaflet::clearGroup("hist_data") |> 
            leaflet::addRasterImage(
              raster_data,
              maxBytes = 4 * 1024 * 1024,
              opacity = 0.8,
              colors = map_palette,
              method = "ngb") |> 
            leaflet::addLegend(pal = map_palette,
                               title = "Average Yearly Rainfall (mm)",
                               values = c(index_bins),
                               position = "bottomright",
                               opacity = 0.8,
                               layerId = "Legend")
          
          showNotification("Hazard Preview Loaded on Region Select Map")
          
        } else {
          
          region_agency_choices$select_region_map_proxy() |> 
            leaflet::clearImages() |> 
            leaflet::removeControl(layerId = "Legend") |> 
            leaflet::clearGroup("hist_data")
          
          showNotification("No Hazard Preview Available for Stochastic Sets")
        }
        
      })
      
      return(selected_data_mappings)
      
    }  
  )
}
