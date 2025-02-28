convert_rad_deg <- function(value, conversion_measure) {
  
  if (conversion_measure == "rad") {
    value * pi/180
  } else {
    value * 180/pi
  }
  
}
