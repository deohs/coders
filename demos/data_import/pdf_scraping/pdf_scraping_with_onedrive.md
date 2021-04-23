---
title: "PDF Scraping WA Covid Data using OneDrive"
output: 
  html_document:
    keep_md: true
editor_options: 
  chunk_output_type: console
---

# Setup

Load packages and setup a data folder in OneDrive, assuming you have already configured OneDrive sync client using the defaults.


```r
# Load packages
if (!require(pacman)) install.packages("pacman")
```

```
## Loading required package: pacman
```

```r
pacman::p_load(readr, dplyr, httr, tabulizer)

# Construct data folder path. Use the environment variable "OneDrive" if 
# available, otherwise guess the location using the "HOME" variable.
onedrive_path <- ifelse(Sys.getenv('OneDrive') != "", Sys.getenv('OneDrive'), 
  file.path(gsub('[\\/]+Documents', '', Sys.getenv('HOME')), 'OneDrive'))
data_dir <- file.path(onedrive_path, 'coders', 'data')

# Create data folder if it does not already exist
if (!dir.exists(data_dir)) {
  dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
}
```

# Get PDF File

See: https://www.doh.wa.gov/Emergencies/COVID19/DataDashboard#downloads


```r
# Download file
filename <- "Weekly-COVID-19-Long-Term-Care-Report.pdf"
filepath <- file.path(data_dir, filename)
if (!file.exists(filepath)) {
  url <- paste0('https://www.doh.wa.gov/Portals/1/Documents/1600/coronavirus/',
                'data-tables/', filename)
  
  # Download with httr::GET() and save with httr::write_disk().
  # Base-R alternative would be: download.file(url, filepath, method = "curl")
  response_msg <- GET(url, write_disk(filepath, overwrite = TRUE))
}
```

# Extract Data from PDF File


```r
txt <- extract_text(file = filepath)
lines <- read_lines(txt)
lines <- c('county;deaths;cases', 
           grep('^[A-Z].*[0-9,]+\\s+[0-9,]+\\s*$', lines, value = TRUE))
lines <- gsub('\\s+(\\d)', ';\\1', lines) %>% gsub(',', '', .)
df <- read_delim(lines, delim = ';', trim_ws = TRUE)
```

# View Data


```r
knitr::kable(df)
```



|county       | deaths| cases|
|:------------|------:|-----:|
|Adams        |      4|    55|
|Asotin       |     11|    78|
|Benton       |     90|   672|
|Chelan       |     29|   351|
|Clallam      |      2|    52|
|Clark        |     96|   962|
|Columbia     |      0|     5|
|Cowlitz      |     37|   302|
|Douglas      |      4|    65|
|Ferry        |      0|     7|
|Franklin     |     20|   208|
|Grant        |     15|   126|
|Grays Harbor |     19|   138|
|Island       |     21|   178|
|Jefferson    |      1|    11|
|King         |    850|  5425|
|Kitsap       |     56|   574|
|Kittitas     |     24|   166|
|Klickitat    |      0|     1|
|Lewis        |     29|   315|
|Lincoln      |      1|    23|
|Mason        |     18|   110|
|Okanogan     |     10|    46|
|Pacific      |      1|    21|
|Pend Oreille |      1|    37|
|Pierce       |    320|  2521|
|Skagit       |     39|   310|
|Skamania     |      0|     2|
|Snohomish    |    301|  2236|
|Spokane      |    342|  2282|
|Stevens      |      8|    92|
|Thurston     |     30|   418|
|Walla Walla  |     30|   312|
|Whatcom      |     46|   351|
|Whitman      |     36|   242|
|Yakima       |    153|  1295|
