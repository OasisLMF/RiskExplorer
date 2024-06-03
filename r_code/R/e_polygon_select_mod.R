e_polygon_select_UI <- function(id) {
  ns <- NS(id)
  tagList(
    conditionalPanel(
      condition = "output.circle_shape",
      ns = ns,
      h4("Step 2: Specify the size of the area around the chosen 
      location that you wish to be covered."),
      helpText("This can be entered as a circle with the radius specified in 
      km or miles. If you are only interested in a single location then just 
      select zero here."),
      br(),
      radioButtons(ns("circle_units"),
                   label = "Select units",
                   choices = c("km", "miles"),
                   selected = "km"),
      numericInput(ns("circle_radius"),
                   label = "Radius in km or miles",
                   value = ""),
      htmltools::span(uiOutput(ns("circle_warning"),
                      style = "color:red;font-size:16px"))),
    conditionalPanel(
      condition = "output.rectangle_shape",
      ns = ns,
      h4("Step 2: Specify the area you wish to cover"),
      helpText("This may be entered as a box with each side length specified in 
      km or miles."),
      br(),
      radioButtons(ns("rectangle_units"),
                   label = "Select units",
                   choices = c("km", "miles"),
                   selected = "km"),
      fluidRow(
        column(width = 4, 
               numericInput(ns("rectangle_length"),
                     label = "Shape Length in km or miles",
                     min = 0,
                     value = 10)),
        column(width = 4, 
               numericInput(ns("rectangle_width"),
                     label = "Shape Width in km or miles",
                     min = 0,
                     value = 10))
      ),
      htmltools::span(uiOutput(ns("rectangle_warning")),
                      style = "color:red;font-size:16px"))
  )
}

e_polygon_select_Server <- function(id, 
                                    proxy_input_map, 
                                    ll_vals,
                                    map_poly_data,
                                    selected_hazard_mappings) {
  moduleServer(
    id,
    function(input, output, session) {
      
      #Debug issues reading shape_type, is this a conditionalPanel UI thing?!
      section_ok <- reactiveVal(NULL)
      
      shape_parameters <- 
        reactiveValues(
          shape = NULL,
          radius = NULL,
          rect_coords = NULL)
      
      circle_error_rv <- reactiveVal(NULL)
      rectangle_error_rv <- reactiveVal(NULL)
      
      observe({
        
        req(rectangle_error_rv())
        
        output$rectangle_warning <- 
          renderText({
            rectangle_error_rv()
          })
        
      })
      
      observe({
        
        req(circle_error_rv())
        
        output$circle_warning <- 
          renderText({
            circle_error_rv()
          })
        
      })
      
      
      output$circle_shape <- 
        reactive({
          tryCatch({
            
            isTruthy(selected_hazard_mappings()["shape"]) 
            if(selected_hazard_mappings()["shape"] == "circle"){
              shape_parameters$shape <- selected_hazard_mappings()["shape"]
              TRUE
            }else{
              FALSE
            }
          },
          shiny.silent.error = function(e) {
            FALSE
          })
        })
      
      output$rectangle_shape <- 
        reactive({
          tryCatch({
            
            isTruthy(selected_hazard_mappings()["shape"]) 
            if(selected_hazard_mappings()["shape"] == "rectangle"){
              shape_parameters$shape <- selected_hazard_mappings()["shape"]
              TRUE
            }else{
              FALSE
            }
          },
          shiny.silent.error = function(e) {
            FALSE
          })
        })
      
      outputOptions(output, "circle_shape", suspendWhenHidden = FALSE)  
      outputOptions(output, "rectangle_shape", suspendWhenHidden = FALSE)
      
      unit_correction <-
        reactive({
          req(shape_parameters$shape)
          
          if(shape_parameters$shape == "circle"){
            ifelse(input$circle_units == "km", 1, 1.60934)  
          }else{
            ifelse(input$rectangle_units == "km", 1, 1.60934)  
          }
        })
      
      observe({
        
        req(shape_parameters$shape == "circle",
            input$circle_radius,
            nrow(ll_vals$vals)!=0,
            unit_correction())
        
        radius_m <- input$circle_radius * unit_correction() * 1000
        
        proxy_input_map() |> 
          removeShape(layerId = "circles") |>
          removeShape(layerId = "rectangles") |>
          addCircles(lat = ll_vals$vals$lat,
                     lng = ll_vals$vals$lng,
                     radius = radius_m,
                     layerId = "circles")
        
        if(radius_m > 150*1000){
          circle_error_rv(
            "Please ensure radius is less than 150 km or 93 miles. Sizes above 
            this can cause issues with the calculations."
          )                        
        }else{
          circle_error_rv(NULL)
        }
        
        shape_parameters$radius <- radius_m 
      })
      
      observe({
        
        req(shape_parameters$shape == "rectangle",
            input$rectangle_length,
            input$rectangle_width,
            nrow(ll_vals$vals)!=0,
            unit_correction())
        
        length_km <- input$rectangle_length * unit_correction()
        width_km <- input$rectangle_width * unit_correction()
        
        if(length_km < 8 | 
           width_km < 8) {
          
          proxy_input_map() |> 
            leaflet::removeShape(layerId = "circles") |>
            leaflet::removeShape(layerId = "rectangles")
          
          rectangle_error_rv("Length and Width must be at least 8km or 
                             4.97 miles")
          
        } else {
          
          rectangle_error_rv(NULL)
          area_km <- length_km * width_km
          
          rect_sf <- 
            get_rectangle_sf(
              centroid = c(ll_vals$vals$lng, ll_vals$vals$lat),
              length_km = length_km,
              width_km = width_km
            )
          
          rect_coords <- sf::st_coordinates(rect_sf) 
          
          rect_coords <- 
            data.frame(
              lng = c(min(rect_coords[, 1]), max(rect_coords[, 1])),
              lat = c(min(rect_coords[, 2]), max(rect_coords[, 2]))
            )
          
          proxy_input_map() |> 
            leaflet::removeShape(layerId = "circles") |>
            leaflet::removeShape(layerId = "rectangles") |>
            leaflet::addPolygons(
              data = rect_sf, 
              label = "Exposure Area", 
              layerId = "rectangles"
            )
          
          overlap_check <-
            shape_in_poly(rect_sf, map_poly_data())
          
          if(overlap_check == FALSE){
            rectangle_error_rv(
              "
              Some of your exposure is outside the modelled area. Please revise 
              your exposure so all of it is contained within the model area or 
              return to the hazard tab to load a new model area
              "
            )
          } else if(area_km > 3e6) {
            rectangle_error_rv(
              "Please ensure area is less than 3,000,000 square kilometres or 
              1,158,306 square miles. Sizes above this can cause issues with the 
              calculations."                        
            )
          }else {
            rectangle_error_rv(NULL)
            shape_parameters$rect_coords <- rect_coords
          }
          
        }
      })
      
      observe({
        section_ok(FALSE)
        req(shape_parameters$shape)
        
        if(shape_parameters$shape == "rectangle" &
           !is.null(shape_parameters$rect_coords) &
           is.null(eval(rectangle_error_rv()))){
          
          section_ok(TRUE)
          
        }
        
        if(shape_parameters$shape == "circle" &
           !is.null(shape_parameters$radius)  &
           is.null(eval(circle_error_rv()))) {
          
          section_ok(TRUE)
          
        } 
        
      })
      
      return(list(shape_parameters = shape_parameters,
                  section_ok = section_ok))
      
    }
  )
}
