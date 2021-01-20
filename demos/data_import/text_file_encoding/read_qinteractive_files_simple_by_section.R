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
    V0 <- c('Section Name', rep(section.names[x], end[x] - start[x]))
    cbind( df[start[x]:end[x], c(1, 3)], V0)
  })
  
  # Subset sections of interest and convert subsets to long format
  keep.sections <- c('RAW SCORES', 'SCALED SCORES', 'SUBTEST COMPLETION TIMES')
  keep.rows <- section.rows[section.names %in% keep.sections]
  sections <- lapply(keep.rows, function(x) {
    df <- data.frame(x[2:nrow(x),], stringsAsFactors = FALSE)
    names(df) <- x[1, ]
    names(df)[3] <- 'Section Name'
    reshape(df, timevar = "variable", v.names = "value", 
            idvar = names(df)[1], varying = names(df)[2], 
            times = names(df)[2], direction = "long")
  })
  
  # Combine section subsets and reshape to wide format
  df.merged <- do.call("rbind", sections)
  row.names(df.merged) <- NULL
  df.merged$`Section Name` <- NULL
  df.merged <- reshape(df.merged, direction = "wide", idvar = 'Subtest', 
                       v.names = "value", timevar = "variable")
  names(df.merged) <- gsub('^value\\.', '', names(df.merged))
  
  # Add filename column
  Filename <- rep(basename(fn), nrow(df.merged))
  cbind(df.merged, Filename)
}

# Get a list of data files
files <- list.files('data', pattern = "\\.csv$", recursive = TRUE, 
                    full.names = TRUE)

# Import data and combine into a single data frame
df <- do.call('rbind', lapply(files, read.qint))

# View the result
df
