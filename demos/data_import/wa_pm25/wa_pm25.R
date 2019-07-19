# Filename: wa_pm25.R
# Copyright (c) University of Washington
# License: MIT https://opensource.org/licenses/MIT (See LICENSE file.)
# Repository: https://github.com/deohs/coders

# Get PM 2.5 "most recent data" from Washington's Air Monitoring Network*. 
# Combine the tables: Western PM 2.5, Eastern PM 2.5, and Central PM 2.5.
# Append to a file so data can be accumnulated over time.
# * See: https://fortress.wa.gov/ecy/enviwa/

# ---------- Setup --------------

# Clear workspace of all objects and unload all extra (non-base) packages.
rm(list = ls(all = TRUE))
if (!is.null(sessionInfo()$otherPkgs)) {
  res <- suppressWarnings(
    lapply(paste('package:', names(sessionInfo()$otherPkgs), sep=""),
           detach, character.only=TRUE, unload=TRUE, force=TRUE))
}

# Load packages.
if (! suppressPackageStartupMessages(require(pacman))) {
  install.packages('pacman', repos = 'http://cran.us.r-project.org')
}
pacman::p_load(dplyr, rvest, purrr, con2aqi)

# Define variables.
data_dir <- 'data'
time_format <- '%m/%d/%Y %H:%M %p'
tz <- 'America/Los_Angeles'

# Create data folder if it does not exist.
dir.create(data_dir, showWarnings = FALSE)

# Extract PM 2.5 data from web pages, calculate AQI and combine datasets.
df <- bind_rows(lapply(c('81', '109', '110'), function(x) {
  url <- paste0('https://fortress.wa.gov/ecy/enviwa/DynamicTable.aspx?G_ID=', x)
  df <- read_html(url) %>% html_node("table#C1WebGrid1") %>% html_table() %>% 
    .[-(1:2),] %>% mutate_at(-(1:2), as.numeric)
  df %>% mutate(pm25 = rowSums(df[, 3:ncol(df)], na.rm = TRUE)) %>% 
    select(X1, X2, pm25) %>% set_names(c('site', 'timestamp', 'pm25')) %>% 
    mutate(timestamp = as.POSIXct(timestamp, format=time_format, tz = tz)) %>% 
    mutate(aqi = con2aqi('pm25', pm25))
}))

# Append the current PM 2.5 data to a file to accumulate results over time.
wa_pm25_data_path <- file.path(data_dir, 'enviwa_pm25_aqi.csv')

# Write header if data file does not exist.
if (! file.exists(wa_pm25_data_path)) {
  write.table(df, wa_pm25_data_path, sep = ',', row.names = FALSE)
} else {
  # Otherwise, append data to previous records with no header.
  write.table(df, wa_pm25_data_path, append = TRUE, sep = ',', 
              row.names = FALSE, col.names = FALSE)
}

# This can be run hourly with a line in your "crontab" file similar to this:
# 00 * * * * (cd ~/Documents/coders/demos/data_import/wa_pm25; Rscript wa_pm25.R)
