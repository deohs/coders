# --------------------------------------------------------------------------
# Functions to perform modeling tasks
# --------------------------------------------------------------------------

get_model_results <- function(.data, .formula, alpha = 0.05, weights = NULL) {
  # .data is a list of dataframes of bootstraps, .formula is model formula.
  # Credit: This function was modified from code by Cooper Schumacher.
  .model <- .formula
  .formula <- as.formula(.formula)
  coefs <- as.data.frame(matrix(unlist(lapply(.data, function(y) {
    if (!is.null(weights)) lm(.formula, y, weights = weights)$coef
    else lm(.formula, y)$coef
  })), nrow = length(seq_along(.data)), byrow = TRUE))
  colnames(coefs) <- names(lm(.formula, .data[[1]])$coef)
  
  est <- sapply(coefs, mean)
  LCI <- sapply(coefs, function(z) quantile(z, alpha / 2))
  UCI <- sapply(coefs, function(z) quantile(z, 1 - alpha / 2))
  model <- rep(.model, length(est))
  df <- data.frame(model = model, cbind(estimate = est, LCI = LCI, UCI = UCI),
                   stringsAsFactors = FALSE)
  df$variable <- rownames(df)
  rownames(df) <- NULL
  df[, c("model", "variable", "estimate", "LCI", "UCI")]
}
