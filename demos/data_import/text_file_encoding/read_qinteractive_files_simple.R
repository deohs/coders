# Simple method to read Q-Interactive files using Base-R.

# Define a function to import a data file given a filename (fn)
read_qint <- function(fn, numrows = 2) {
  # Read the file
  qint_df <- read.csv(fn, fileEncoding = "UTF-16LE", skip = 5, header = FALSE,
                      stringsAsFactors = FALSE, na.strings = c("null", "-", ""))
  
  # Set column name patterns to extract
  col.names <- c('Raw score', 'Scaled score', 'Completion Time')
  
  # Search for the column name patterns and store their row numbers
  rownums <- lapply(col.names, function(pattern) {
    seq(grep(pattern, qint_df$V3)[1] + 1, length.out = numrows)
  })
  
  # Extract the values from the row numbers desired above
  scores.lst <- lapply(rows, function(rownums) as.numeric(qint_df$V3[rownums]))
  scores.df <- as.data.frame(do.call("cbind", scores.lst))
  names(scores.df) <- col.names
  
  # Combine the values with the filename and subtest names
  Filename <- rep(basename(fn), numrows)
  Subtest <- c('Matrix Reasoning', 'Digit Span')
  cbind(Subtest, scores.df, Filename)
}

# Get a list of data files
data_dir <- 'data'
files <- list.files(data_dir, pattern = "\\.csv$", recursive = TRUE, 
                    full.names = TRUE)

# Import data and combine into a single data frame
df <- do.call('rbind', lapply(files, read_qint))
