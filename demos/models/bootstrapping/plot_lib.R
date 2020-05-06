# --------------------------------------------------------------------------
# Functions to plot the structure of a list
# --------------------------------------------------------------------------
# From: https://stackoverflow.com/questions/51608378

treeDepth <- function(x) ifelse(is.list(x), 1 + max(sapply(x, depth)), 0)

toTree <- function(x) {
  d <- treeDepth(x)
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

show_example <- function() {
  UW <- list(SPH = list(
    OoD = 0,
    depts = data.frame(
      BIOST = 1,
      DEOHS = 2,
      DGH = 3,
      EPI = 4,
      HS = 5
    ),
    Nutr = 6
  ))
  #str(UW)
  plot_list_structure(UW)
}
