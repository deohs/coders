# Unruly Data Example: CSV file with atypical character encoding and sections.
#
# Read Q-Interactive files and combine results. Only read sections RAW SCORES, 
# SCALED SCORES and SUBTEST COMPLETION TIMES. Get the first and last 
# columns for each of these sections and combine into a single "wide" format 
# dataframe. Include the filename as an additional column in order to track 
# which rows came from which files. The column names will be Subtest, Raw score, 
# Scaled score, Completion Time (seconds) and filename.

# Load packages, installing as needed
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyr, dplyr, stringr, purrr)

# -----------------
# Define functions
# -----------------

# Store lines of a character vector into a list by section name
create_section_list <- function(lines, 
    pattern = '^[A-Z: -]*$|Additional Measures|Composite Score') {
  section_row_num <- str_which(lines, pattern)
  section_names <- lines[section_row_num]
  section_num_rows <- diff(c(section_row_num, length(lines)+1))
  map2(section_row_num, section_num_rows, ~lines[(.x + 1):(.x + .y - 1)]) %>%
  set_names(section_names)
}

# Read a section of a file stored as a vector of character strings as a CSV
read_section <- function(x) {
  read.csv(text = x, na.strings = c("null", "-"), check.names = FALSE)
}

# Read a Q-Interactive file into a vector of character strings
scan_file <- function(x) {
  scan(x, what = "raw", fileEncoding = "UTF-16LE", sep = '\n', quiet = TRUE)
}

# Read all sections of all CSV files into a nested list of dataframes
read_files <- function(files) {
  sections_lst <- map(files, ~ {
    scan_file(.x) %>% create_section_list() %>% map(., read_section) }) %>%
    set_names(basename(files))
}

# From each dataframe in the nested list, select variables, reshape, & combine
combine_dataframes <- function(df_lst, sections, col_nums = c(1, 3)) {
  map(names(df_lst), ~ { 
    map(df_lst[[.x]][sections], ~ .x[, col_nums] %>% pivot_longer(-1)) %>% 
      bind_rows() %>% pivot_wider() %>% mutate(filename = .x) }) %>% bind_rows()
}

# -------------
# Main routine
# -------------

# Read in CSV files as a nested list of dataframes
files <- list.files('data', pattern = "\\.csv$", full.names = TRUE)
df_lst <- read_files(files)

# Combine results from desired sections
sections <- c('RAW SCORES', 'SCALED SCORES', 'SUBTEST COMPLETION TIMES')
df <- combine_dataframes(df_lst, sections)

# -------------
# View results
# -------------

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

