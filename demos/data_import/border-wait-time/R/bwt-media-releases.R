# Get a list of all national media releases from the CPB site and save as CSV.
# Get articles in the list and save each as a plain text file.

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
links <- doc %>% 
  html_nodes(".views-field-title") %>% 
  html_nodes("a") %>% 
  html_attr(name = "href") %>%
  paste0('https://www.cbp.gov', .)

# Combine into a dataframe and convert data to YYYY-MM-DD (ISO) format
df <- data.frame(date = dates, title = titles, url = links, 
                 stringsAsFactors = FALSE)
df$date <- as.Date(df$date, "%A, %B %d, %Y")

# Save results
write.csv(df, csv, row.names = FALSE)

# Create output folder
out_dir <- 'output'
dir.create(file.path(out_dir), showWarnings=FALSE, recursive=TRUE)

# Get press releases and save as plain-text files
res <- lapply(1:nrow(df), function(x) {
  url <- df$url[x]
  fn <- file.path(out_dir, paste0(df$date[x], "_", basename(url), ".txt"))
  doc <- read_html(url)
  content <- doc %>% 
    html_nodes(".field-items") %>% 
    html_text()
  writeLines(content, fn)
})


