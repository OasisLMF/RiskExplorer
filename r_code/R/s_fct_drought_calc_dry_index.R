calc_dry_index <- function(vec, threshold, pentad_adj = TRUE){
  
  scaling_factor  <- ifelse(pentad_adj == TRUE, 5, 1 )
  
  rle_return <-
    rle(vec >= 1)$lengths[rle(vec >= 1)$values == TRUE]  
  
  sum(rle_return[rle_return >= threshold]) * scaling_factor
  
}