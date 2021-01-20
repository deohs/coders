# Simple method to read Q-Interactive files using Base-R.

# Define a function to import a data file given a filename (fn)
read.qint <- function(fn, num.rows = 2) {
  # Read the file
  df <- read.csv(fn, fileEncoding = 'UTF-16LE', skip = 5, header = FALSE,
                      stringsAsFactors = FALSE, na.strings = c('null', '-', ''))
  
  # Set column name patterns to extract
  col.names <- c('Raw score', 'Scaled score', 'Completion Time (seconds)')
  
  # Search for the column names and store the row numbers for their data values
  row.nums <- lapply(col.names, function(pattern) {
    seq(grep(pattern, df$V3, fixed = TRUE)[1] + 1, length.out = num.rows)
  })
  
  # Extract the values from the row numbers and store as columns in a dataframe
  scores.lst <- lapply(row.nums, function(row.nums) as.numeric(df$V3[row.nums]))
  scores.df <- as.data.frame(do.call("cbind", scores.lst))
  names(scores.df) <- col.names
  
  # Combine the dataframe with new columns for the filename and subtest names
  Filename <- rep(basename(fn), num.rows)
  Subtest <- c('Matrix Reasoning', 'Digit Span')
  cbind(Subtest, scores.df, Filename)
}

# Get a list of data files
files <- list.files('data', pattern = "\\.csv$", recursive = TRUE, 
                    full.names = TRUE)

# Import data and combine into a single data frame
df <- do.call('rbind', lapply(files, read.qint))

# View the result
df
