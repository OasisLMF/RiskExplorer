gen_rps <- function(df, n = 10000, var) {
  percentile <-
    sort(seq(1 / (n + 1), by = 1 / (n + 1), length.out = n), decreasing = TRUE)
  
  rp <- 1 / (1 - percentile)
  
  df |>
    dplyr::arrange(dplyr::desc(.data[[var]])) |>
    cbind(rp = rp)
}