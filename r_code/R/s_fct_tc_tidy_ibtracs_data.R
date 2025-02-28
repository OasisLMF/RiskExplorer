tidy_ibtracs_data <- function(hazard_data, agency, agencies) {
  
  agency_no <-
    stringr::str_count(
      substr(
        agencies, 
        1, 
        stringr::str_locate(agencies, agency)[1] - 1)
      , agency
    ) + 1 
  
  agency_exclude <-
    paste0(
      "AGENCY",
      setdiff(c(1:3), as.numeric(agency_no))
    )
  
  cols_to_keep <-
    colnames(hazard_data)[
      !(
        grepl(agency_exclude[1], colnames(hazard_data))|
          grepl(agency_exclude[2], colnames(hazard_data))
      )
    ]
  
  hazard_data <- 
    hazard_data |> 
    dplyr::select(cols_to_keep)
  
  colnames(hazard_data) <- 
    gsub(
      paste0("AGENCY", agency_no),
      "SELECTED", 
      colnames(hazard_data)
    )
  
  hazard_data
  
}