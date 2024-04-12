assign_display_var <- function(display_type) {
  
  if(display_type == "Currency") {
    "Payout"
  } else if (display_type == "% of Asset Value") {
    "Payout as % of Asset Value"
  } else if (display_type == "Policyholders Impacted") {
    "Insured Impacted"
  } else {
    NULL
  }

}