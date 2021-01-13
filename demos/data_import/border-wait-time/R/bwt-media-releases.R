# Get a list of all national media releases from the CPB site and save as CSV

# Load packages, installing as needed
if (!require("pacman")) install.packages("pacman")
pacman::p_load(xml2, rvest)

# Create data folder
data_dir <- 'data'
dir.create(file.path(data_dir), showWarnings=FALSE, recursive=TRUE)

# Define variables
url <- 'https://www.cbp.gov/newsroom/media-releases/all?title=&field_newsroom_type_tid_1=81'
csv <- file.path(data_dir, "media_releases.csv")

# Get data
doc <- read_html(url)

# Extract dates and titles
dates <- doc %>% 
  html_nodes(".field-content .date-display-single") %>% 
  html_text()
titles <- doc %>% 
  html_nodes(".views-field-title") %>% 
  html_nodes("a") %>% 
  html_text()

# Combine into a dataframe and convert data to YYYY-MM-DD (ISO) format
df <- data.frame(date = dates, title = titles)
df$date <- as.Date(df$date, "%A, %B %d, %Y")

# Save results
write.csv(df, csv, row.names = FALSE)

