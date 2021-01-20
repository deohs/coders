# Read "Q-Interactive" files, but only the sections for Raw score, Scaled score, 
# and Completion Time. Combine the results for multiple files into a single data
# frame. Use scan() to read the files as lines then fread() to extract lines 
# into data frames, and finally rbindlist() to combine into a single data frame.

# Install pacman if needed
my_repo <- 'http://cran.r-project.org'
if (!require("pacman")) {install.packages("pacman", repos = my_repo)}

# Load the other packages, installing as needed
pacman::p_load(data.table)

qintread_dt <- function(fn) {
  # Read file into a string vector, read sections as CSVs, and combine
  qint <- scan(fn, 'raw', fileEncoding = 'UTF-16LE', sep = '\n', quiet = TRUE)
  skip.strings <- c('Raw score', 'Scaled score', 'Completion Time (seconds)')
  dt <- dcast.data.table(rbindlist(lapply(skip.strings, function(x) {
    dt <- fread(text = qint, skip = x, nrows = 2, header = TRUE, drop = 'V2',
          blank.lines.skip = TRUE, na.strings = c("null", "-", ""),
          check.names = TRUE, col.names = c('Subtest', x))
    melt.data.table(dt, id.vars = 1, measure.vars = 2)
  })), formula = 'Subtest ~ variable')  
  
  # Add filename variable and sort
  dt[, Filename := basename(fn)][order(-Subtest)]
}

# Prepare a list of files to import
data_dir <- 'data'
files <- list.files(data_dir, pattern = "\\.csv$", recursive = TRUE, 
                    full.names = TRUE)

# Import data from files and combine into a single dataframe
dt <- rbindlist(lapply(files, qintread_dt))

# View the result
dt
