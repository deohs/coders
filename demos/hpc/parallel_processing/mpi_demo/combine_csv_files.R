library(readr)
library(purrr)
library(dplyr)

fs::dir_ls(".", recurse = TRUE, type = "file", regexp = "rob_cov.*\\.csv") %>% 
  map_dfr(read_csv, .id = "path") %>% write_csv("combined_data.csv")
