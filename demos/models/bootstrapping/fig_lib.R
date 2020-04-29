# --------------------------------------------------------------------------
# Functions to present figures
# --------------------------------------------------------------------------

show_html_table <- function(x) {
  rownames(x) <- NULL
  x_html <- knitr::kable(x = x, format = 'html')
  kable_styling(x_html, full_width = TRUE, bootstrap_options = 'condensed')
}
