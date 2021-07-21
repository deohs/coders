# -------------
# cor_by_comb.R
# -------------

# Example of calculation of correlation of two variables by combinations 
# of a third (grouping) character (or factor) variable.

# ----------
# Functions
# ----------

res_comb <- function(df, x, y, z, comb) {
  # Filter to only those rows which are for comb[1] or comb[2], etc.
  df <- df[df[[z]] %in% comb, ]
  
  # Use whatever formula and statistic that makes the most sense for you
  fit <- lm(df[[x]] ~ df[[y]] + df[[z]])
  result <- summary(fit)$r.squared
  
  # Return a data frame of results
  data.frame(
    combination = paste(comb, collapse = ","),
    result = result,
    stringsAsFactors = FALSE
  )
}

# ------------
# Main Routine
# ------------

# Get data
data(iris)
df <- iris

# Get correlation of sepal length the width by species
library(dplyr)
df %>% 
  group_by(Species) %>% dplyr::summarize(COR = cor(Sepal.Length, Sepal.Width))

library(ggplot2)
library(dplyr)
data(iris)
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width))+ 
  geom_smooth(method = "lm")  + geom_point() +
  facet_grid(~ Species) 

# Calculate correlation for each group
cors <- iris %>% group_by(Species) %>% 
  summarise(COR = round(cor(Sepal.Length, Sepal.Width), 2))

# Position the correlation label in the lower right corner of the plot
cors <- cors %>%  mutate(x = 0.95 * max(iris$Sepal.Length), 
                         y = 1.05 * min(iris$Sepal.Width))
p + geom_text(data=cors, aes(x=x, y=y, label=paste("r=", COR, sep="")))


# How about correlation by pairs of species?

# Define variables
x <- "Sepal.Length"
y <- "Sepal.Width"
z <- "Species"

# Create a matrix of pairwise combinations of a character or factor variable
m <- t(combn(as.character(unique(df[[z]])), 2))

# Combine list of resulting data frames using bind_rows()
res <- bind_rows(lapply(1:nrow(m), function(i) res_comb(df, x, y, z, m[i,])))

# View results
res
