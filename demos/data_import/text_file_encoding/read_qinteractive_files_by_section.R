# Unruly Data Example: CSV file with atypical character encoding and sections.
#
# Read Q-Interactive files and combine results. Only read sections RAW SCORES, 
# SCALED SCORES and SUBTEST COMPLETION TIMES. Get the first and last 
# columns for each of these sections and combine into a single "wide" format 
# dataframe. Include the filename in an additional column in order to track 
# which rows came from which files. The column names will be Subtest, Raw score, 
# Scaled score, Completion Time (seconds) and filename.

# Load packages, installing as needed
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyr, dplyr, stringr, purrr)

# -----------------
# Define functions
# -----------------

# Split a file stored as a character string into a list by section
as_section_list <- function(txt) {
  patterns <- c('[A-Z: -]+', 'Additional Measures [^\n]*', 'Composite Score')
  pattern <- paste0('\n', patterns, collapse = '|', '\n')
  section_names <- unlist(str_trim(unlist(str_extract_all(txt, pattern))))
  strsplit(txt, pattern)[[1]][-1] %>% set_names(section_names)
}

# Read a section of a file stored as a character string as a CSV
read_section <- function(txt) {
  read.csv(text = txt, na.strings = c("null", "-"), check.names = FALSE)
}

# Read a Q-Interactive file and combine sections into a list of dataframes
scan_file <- function(x) {
  scan(x, what = "raw", fileEncoding = "UTF-16LE", sep = '\n', quiet = TRUE) %>%
    paste(collapse = "\n") %>% as_section_list() %>% map(read_section)
}

# Read all sections of all CSV files into a nested list of dataframes
read_files <- function(files) {
  sections_lst <- map(files, scan_file) %>% set_names(basename(files))
}

# From each dataframe in the nested list, select variables, reshape, & combine
combine_dataframes <- function(df_lst, sections, col_nums = c(1, 3)) {
  map_dfr(df_lst, ~ { 
    map_dfr(.x[sections], ~ {
      .x[, col_nums] %>% pivot_longer(-1) }) %>% pivot_wider() }, .id = "File")
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
# File              Subtest          `Raw score` `Scaled score` `Completion Time (seconds)`
# <chr>             <fct>                  <dbl>          <dbl>                       <dbl>
# 1 0001_scores.csv Matrix Reasoning          12              7                        243.
# 2 0001_scores.csv Digit Span                18              8                         NA 
# 3 0002_scores.csv Matrix Reasoning          18             NA                        239.
# 4 0002_scores.csv Digit Span                28             NA                        718.