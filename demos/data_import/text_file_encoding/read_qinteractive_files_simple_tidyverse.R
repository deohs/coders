# Read "Q-Interactive" files, but only the sections for Raw score, Scaled score, 
# and Completion Time. Combine the results for multiple files into a single data
# frame. Use scan() to read the files as lines then read_csv() to extract lines 
# into data frames, and finally bind_rows() to combine into a single data frame.

# Install pacman if needed
my_repo <- 'http://cran.r-project.org'
if (!require("pacman")) {install.packages("pacman", repos = my_repo)}

# Load the other packages, installing as needed
pacman::p_load(readr, tidyr, dplyr)

qintread_df <- function(fn, skip.strings) {
  # Read file into a string vector, read sections as CSVs, and combine
  q <- scan(fn, 'raw', fileEncoding = 'UTF-16LE', sep = '\n', quiet = TRUE)
  
  # Find start and end row numbers to extract for each section of interest
  sect.rows <- grep('^[A-Z: -]*$|Additional Measures', q)
  skip <- sapply(skip.strings, function(x) grep(x, q, fixed = TRUE)[1])
  nrows <- sapply(skip, function(x) sect.rows[which(sect.rows > x)][1] - x - 1)
  
  # Extract sections, combine, and reshape
  lapply(skip.strings, function(x) {
    read_csv(q, skip = skip[x], n_max = nrows[x], skip_empty_rows = TRUE, 
             na = c("null", "-", ""), col_names = c('Subtest', 'X2', x)) %>% 
      select(-X2) %>% 
      pivot_longer(-Subtest)
  }) %>% 
    bind_rows() %>% 
    pivot_wider() %>% 
    mutate(Filename = basename(fn)) %>% 
    arrange(desc(Subtest))
}

# Prepare a list of files to import
data_dir <- 'data'
files <- list.files(data_dir, pattern = "\\.csv$", recursive = TRUE, 
                    full.names = TRUE)

# Import data from files and combine into a single dataframe
skip.strings <- c('Raw score', 'Scaled score', 'Completion Time (seconds)')
df <- bind_rows(lapply(files, qintread_df, skip.strings))

# View the result
df
