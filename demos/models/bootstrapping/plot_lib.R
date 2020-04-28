# --------------------------------------------------------------------------
# Functions to plot the structure of a list
# --------------------------------------------------------------------------
# From: https://stackoverflow.com/questions/51608378

depth <- function(x) ifelse(is.list(x), 1 + max(sapply(x, depth)), 0)

toTree <- function(x) {
  d <- depth(x)
  if(d > 1) {
    lapply(x, toTree)
  } else {
    children <- lapply(names(x), function(nm) list(name = nm))
  }
}

library(data.tree)
plot_list_structure <- function(x) {
  plot(FromListSimple(toTree(x), nodeName = deparse(substitute(x))))
}
