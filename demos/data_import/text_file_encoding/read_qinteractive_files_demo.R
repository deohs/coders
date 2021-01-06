# Messy data: alternative character encodings

# Read "qinteractive" files, but only the sections for Raw score, Scaled score, 
# and Completion Time. Combine the results for multiple files into a single data
# frame. Compare the results from using base-R and data.table approaches.

# Challenges for this file type:
#
# 1. File suffix is "CSV" but it contains multiple sections and headings.
# 2. File is not encoded as expected (ANSI or UTF-8) for a text file.
# 3- File contains "null-terminated strings" and a "BOM"

# See:
# https://en.wikipedia.org/wiki/Comma-separated_values
# https://en.wikipedia.org/wiki/Character_encoding
# https://en.wikipedia.org/wiki/Null-terminated_string
# https://en.wikipedia.org/wiki/Byte_order_mark

# This means you cannot even view the data as a text file in the RStudio
# text editor. However, you can using Notepad++ (Windows) where you can 
# view the file and change the encoding.

# You can also check the file encoding with readr::guess_encoding() or "file"
#fn <- "data/0001_scores.csv"
#if (require(readr)) readr::guess_encoding(fn)
#system(paste("file", fn), intern = TRUE)   # Requires "file" shell utility

# readr::read_csv() and data.table::fread() do not support this file type.
# However, some base-R functions do: scan(), readLines(), and read.csv().

# So, you can either convert the encoding of your files before you read them 
# into R (with an application like Notepad++ or a shell utility) or you can 
# read the files using one of the R functions which will support the encoding.
# You can also open the file in MS-Excel and "Save as" CSV to change to UTF-8.

# ------
# Setup
# ------

# Install pacman if needed
my_repo <- 'http://cran.r-project.org'
if (!require("pacman")) {install.packages("pacman", repos = my_repo)}

# Load the other packages, installing as needed
pacman::p_load(data.table)

# -----------------
# Define functions
# -----------------

clean_up_names <- function(x) {
  # Remove extra dot (.) characters
  gsub('\\.+', '.', gsub('^\\.*|\\.*$', '', x))
}

qintread_sect_base <- function(df, pattern, nrows = 3, keep = c("V1", "V3")) {
  # Read a section of a file. Assume each section is nrows long, incl. header.
  df_rows <- seq(grep(pattern, df[[keep[2]]])[1], length.out = nrows)
  df_out <- df[df_rows[2:3], keep]
  df_out[, 2] <- as.numeric(df_out[, 2])
  names(df_out) <- df[df_rows[1], keep]
  df_out
}

qintread_base <- function(fn) {
  # Read as CSV, subset, and merge
  
  # read.csv() takes a fileEncoding parameter which allows us to read the file
  na_strings <- c("null", "-", "")
  qint_df <- read.csv(fn, fileEncoding = "UTF-16LE", skip = 5, header = FALSE,
                      stringsAsFactors = FALSE, na.strings = na_strings)
  
  # Import the desired lines into a dataframe
  qint_RAW <- qintread_sect_base(qint_df, "Raw score")
  qint_SCALED <- qintread_sect_base(qint_df, "Scaled score")
  qint_TIME <-qintread_sect_base(qint_df, "Completion Time")
  
  # Return the merged result
  data.frame(merge(merge(qint_RAW, qint_SCALED), qint_TIME), 
             filename = basename(fn), stringsAsFactors = FALSE)
}

qintread_sect_dt <- function(text, skip, nrows = 2, drop = 'V2', 
                             na.strings = c("null", "-", "")) {
  # Read a section of a file. Assume each section has a header & nrows of data.
  fread(text = text, skip = skip, nrows = nrows, header = TRUE, 
        blank.lines.skip = TRUE, na.strings = na.strings, drop = drop, 
        check.names = TRUE)
}

qintread_dt <- function(fn) {
  # Read as string vector, cleanup file lines, read as CSVs, and merge
  # Since data.table::fread() does not support UTF-16LE we use scan(), etc.
  
  # Read the lines into a vector, adjusting for file encoding
  qint <- scan(fn, "raw", fileEncoding = "UTF-16LE", sep = '\n', quiet = TRUE)
  
  # Or you can use readLines(), but you may have to remove the BOM manually
  # See: https://unicode.org/faq/utf_bom.html
  #qint <- readLines(fn, encoding = "UTF-16LE", skipNul = TRUE)
  #qint[1] <- gsub('^\xff\xfe', '', qint[1])        # Remove the BOM
  
  # Or you could do this with a shell utility (on Linux or macOS)
  #qint <- system(paste("cat", fn, "|", "dos2unix"), intern = TRUE)
  #qint <- gsub('\r', '', 
  #             system(paste("iconv -f UTF16LE -t UTF-8", fn, "-"), 
  #                    intern = TRUE))
  
  # Import the desired lines into a dataframe
  qint_RAW <- qintread_sect_dt(text = qint, skip = "Subtest,,Raw score")
  qint_SCALED <- qintread_sect_dt(text = qint, skip = "Subtest,,Scaled score")
  qint_TIME <- qintread_sect_dt(text = qint, skip = "Subtest,,Completion Time")
  
  # Return the merged result
  data.table(merge(merge(qint_RAW, qint_SCALED, by = "Subtest"), qint_TIME),
             filename = basename(fn))
}

# -------------
# Main routine
# -------------

# Prepare a list of files to import
data_dir <- 'data'
files <- list.files(data_dir, recursive = TRUE, full.names = TRUE)

# Import data from files and combine into a single dataframe
df <- do.call("rbind", lapply(files, qintread_base))
dt <- rbindlist(lapply(files, qintread_dt))

# Clean up names by removing extra dot (.) characters
names(df) <- clean_up_names(names(df))
names(dt) <- clean_up_names(names(dt))

# View results
df
dt

# Compare results
all.equal(df, dt, check.attributes = FALSE)
