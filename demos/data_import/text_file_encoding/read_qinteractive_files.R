# Unruly Data Example: CSV file with atypical character encoding and sections.
#
# Read Q-Interactive files and combine results. Only read sections RAW SCORES, 
# SCALED SCORES and SUBTEST COMPLETION TIMES, and only read the first instance 
# of each section if there are more than one present. Get the first and last 
# columns for the first two rows of each section and combine into a single 
# "wide" format dataframe. Include the filename as an additional column in 
# order to track which rows came from which files. The column names will be 
# Subtest, Raw score, Scaled score, Completion Time (seconds) and filename.

library(tidyr)
library(dplyr)
library(stringr)

sections <- c('RAW SCORES', 'SCALED SCORES', 'SUBTEST COMPLETION TIMES')

df <- list.files('data', pattern = "\\.csv$", recursive = T, full.names = T) %>%
    lapply(function (fn) {
      lines <- scan(fn, "raw", fileEncoding = "UTF-16LE", sep = '\n', quiet = T)
      row_nums <- sapply(sections, function(x) str_which(lines, fixed(x))[1])
      lapply(row_nums, function(n) { 
        read.csv(text = lines[n + 1:3], na.strings = c("null", "-"), 
                 check.names = F) %>% select(1, 3) %>% pivot_longer(-Subtest)
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
