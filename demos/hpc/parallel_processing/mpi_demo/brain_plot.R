# From: https://stackoverflow.com/questions/51608378

# Load packages
library(data.tree)

# Define functions
treeDepth <- function(x) ifelse(is.list(x), 1 + max(sapply(x, treeDepth)), 0)

toTree <- function(x) {
  d <- treeDepth(x)
  if(d > 1) {
    lapply(x, toTree)
  } else {
    children <- lapply(names(x), function(nm) list(name = nm))
  }
}

# Create list containing cluster structure
`deohs-brain` <- list(
  all.q = list(
    mesa.q = list(
      `compute-0-0` = c(slots = 48, mem = 376),
      `compute-0-1` = c(slots = 48, mem = 376),
      `compute-0-2` = c(slots = 48, mem = 376),
      `compute-0-3` = c(slots = 48, mem = 376)
    ),
    edge.q = list(
      `compute-0-4` = c(slots = 48, mem = 376),
      `compute-0-5` = c(slots = 48, mem = 376),
      `compute-0-6` = c(slots = 48, mem = 376)
    ),
    cuilab.q = list(
      `compute-0-7` = c(slots = 48, mem = 376)),
    sheppardlab.q = list(
      `compute-0-8` = c(slots = 64, mem = 376)),
    student.q = list(
      `compute-0-9` = c(slots = 64, mem = 503))
  ))

# Convert list to tree
deohs_brain.tree <- FromListSimple(toTree(`deohs-brain`), 
                                   nodeName = deparse(substitute(`deohs-brain`)))

# Write text tree to file
fn <- 'deohs_brain_tree.txt'
txt <- gsub('^c\\(|[\",]*|)$', '', 
            gsub(',', ',\n', as.character(print(deohs_brain.tree))))
write(txt, fn)

# Create tree graph
SetGraphStyle(deohs_brain.tree, rankdir = "LR")
SetEdgeStyle(deohs_brain.tree, arrowhead = "vee", color = "DimGray", 
             penwidth = 2)
SetNodeStyle(deohs_brain.tree, 
             style = "filled,rounded", shape = "box", fontcolor = "DarkGray", 
             fillcolor = "Pink", fontname = "helvetica", penwidth = "2px",
             color = "DimGray")
            
SetNodeStyle(deohs_brain.tree$all.q, fillcolor = "Tan")

fillcolors <- c(mesa.q        = "LightCoral",
                edge.q        = "Goldenrod",
                cuilab.q      = "PaleGreen",
                sheppardlab.q = "LightBlue",
                student.q     = "Plum")

res <- sapply(names(fillcolors), function(q){
  SetNodeStyle(deohs_brain.tree$all.q[[q]], fillcolor = fillcolors[[q]])
})

# Plot the graph
plot(deohs_brain.tree)
              
