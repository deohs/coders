# Reading Q-Interactive files using Base-R where you select sections by name

# Define a function to import a data file given a filename (fn)
read.qint <- function(fn) {
  # Read the file
  df <- read.csv(fn, fileEncoding = 'UTF-16LE', skip = 5, header = FALSE,
                 stringsAsFactors = FALSE, na.strings = c('null', '-', ''))
  
  # Find section names using a pattern match
  section.row.nums <- grep('^[A-Z: -]*$|Additional Measures', df[, 1])
  section.names <- df[section.row.nums, 1]
  
  # Find start and end row numbers for section rows
  start <- section.row.nums + 1
  end <- start + c(diff(start), length(start)) - 2
  
  # Find section rows
  section.rows <- lapply(1:length(start), function(x) {
    df[start[x]:end[x], c(1, 3)]
  })
  
  # Find sections
  sections <- lapply(section.rows, function(x) {
    df <- data.frame(x[2:nrow(x),], stringsAsFactors = FALSE)
    names(df) <- x[1, ]
    df
  })
  
  # Merge sections
  names(sections) <- section.names
  df.merged <- merge(merge(sections[['RAW SCORES']], 
    sections[['SCALED SCORES']], by = 'Subtest'),
    sections[['SUBTEST COMPLETION TIMES']], by = 'Subtest')
  
  # Add filename column
  Filename <- rep(basename(fn), nrow(df.merged))
  cbind(df.merged, Filename)
}

# Get a list of data files
files <- list.files('data', pattern = "\\.csv$", recursive = TRUE, 
                    full.names = TRUE)

# Import data and combine into a single data frame
df <- do.call('rbind', lapply(files, read.qint))
