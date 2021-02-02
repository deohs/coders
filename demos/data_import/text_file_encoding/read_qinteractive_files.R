# Read Q-Interactive files and combine results. Only read sections containing
# the columns: Raw score, Scaled score, or Completion Time (seconds), and only 
# read the first section of these if there are more than one present.

library(tidyr)
library(dplyr)
library(stringr)

df <- list.files('data', pattern = "\\.csv$", recursive = T, full.names = T) %>%
    lapply(function (fn) {
      lines <- scan(fn, "raw", fileEncoding = "UTF-16LE", sep = '\n', quiet = T)
      col_names <- c('Raw score', 'Scaled score', 'Completion Time (seconds)')
      row_nums <- sapply(col_names, function(x) str_which(lines, fixed(x))[1])
      lapply(row_nums, function(n) { 
        read.csv(text = lines[n:(n + 2)], na.strings = c("null", "-"), 
                 check.names = F) %>% select(1, 3) %>% 
          pivot_longer(-Subtest) %>% mutate(value = as.numeric(value))
      }) %>% bind_rows() %>% pivot_wider() %>% mutate(filename = basename(fn))
    }) %>% bind_rows()

df

# Expected Output
#
# A tibble: 4 x 5
# Subtest          `Raw score` `Scaled score` `Completion Time (seconds)` filename       
# <fct>                  <dbl>          <dbl>                       <dbl> <chr>          
# 1 Matrix Reasoning        12              7                        243. 0001_scores.csv
# 2 Digit Span              18              8                         NA  0001_scores.csv
# 3 Matrix Reasoning        18             NA                        239. 0002_scores.csv
# 4 Digit Span              28             NA                        718. 0002_scores.csv
