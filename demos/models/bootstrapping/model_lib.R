# --------------------------------------------------------------------------
# Functions to perform modeling tasks
# --------------------------------------------------------------------------

get_model_results <- function(.data, .formula, alpha = 0.05) {
  # .data is a list of dataframes of bootstraps, .formula is model formula.
  # Credit: This function was modified from code by Cooper Schumacher.
  .model <- .formula
  .formula <- as.formula(.formula)
  coefs <- do.call('rbind', lapply(.data, function(y) {
    data.frame(t(lm(.formula, y)$coef), check.names = FALSE)
  }))
  
  est <- sapply(coefs, mean)
  LCI <- sapply(coefs, function(z) quantile(z, alpha / 2))
  UCI <- sapply(coefs, function(z) quantile(z, 1 - alpha / 2))
  model <- rep(.model, length(est))
  variable <- names(est)
  df <- data.frame(model = model, variable = variable,
                   cbind(estimate = est, LCI = LCI, UCI = UCI),
                   stringsAsFactors = FALSE)
  rownames(df) <- NULL
  df
}
