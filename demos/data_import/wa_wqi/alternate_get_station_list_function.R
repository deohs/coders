# Filename: alternate_get_station_list_function.R
# Copyright (c) University of Washington
# License: MIT https://opensource.org/licenses/MIT (See LICENSE file.)
# Repository: https://github.com/deohs/coders

# Get a list of  Washington WQI station IDs and names.

# Clear workspace of all objects and unload all extra (non-base) packages.
rm(list = ls(all = TRUE))
if (!is.null(sessionInfo()$otherPkgs)) {
  res <- suppressWarnings(
    lapply(paste('package:', names(sessionInfo()$otherPkgs), sep=""),
           detach, character.only=TRUE, unload=TRUE, force=TRUE))
}

# Load packages.
if (!require(pacman)) {
  install.packages('pacman', repos = 'http://cran.us.r-project.org')
}
pacman::p_load(dplyr, rvest)

# Read table of water quality stations from a web page.
get_station_list <- function() {
  # Read the page.
  url <- 'https://fortress.wa.gov/ecy/eap/riverwq/regions/state.asp?symtype=1'
  pg <- read_html(url)
  
  # Read the color coding key into a tibble with class and type columns.
  # Use an XPATH expression instead of a CSS selector to get the td tags.
  tds <- pg %>% html_nodes(xpath = "//table[@class='key']//table//td")
  key <- tibble(class = tds %>% html_attr('class'), 
                type  = tds %>% html_text() %>% 
                  gsub('^.?([A-Za-z-]+).*$', '\\1', .))
  
  # Get the list of stations from a two-column HTML table of class "list".
  links <- pg %>% html_nodes("table.list") %>% html_nodes("a")
  df <- as_tibble(t(matrix(links %>% html_text(), nrow = 2)), 
                  .name_repair = 'unique')
  names(df) <- c('station.ID', 'station.name')
  df$class <- t(matrix(links %>% html_attr('class'), nrow = 2))[, 1]
  df$url <- t(matrix(links %>% html_attr('href'), nrow = 2))[, 1]
  
  return(df %>% inner_join(key, by = 'class') %>% select(-class))
}

stations <- get_station_list()
stations
