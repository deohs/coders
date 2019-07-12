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
pacman::p_load(dplyr, purrr, rvest)

# Read table of water quality stations from a web page.
get_station_list <- function() {
  # Read the page.
  url <- 'https://fortress.wa.gov/ecy/eap/riverwq/regions/state.asp?symtype=1'
  pg <- read_html(url)
  
  # Read the color coding key into a tibble with class and type columns.
  xmlns.td <- pg %>% html_nodes(xpath = "//table[@class='key']//table//td")
  key <- tibble(class = xmlns.td %>% html_attr('class'), 
                type  = xmlns.td %>% html_text() %>% 
                  gsub('(\\D+).*$', '\\1', .))
  
  # Get the list of stations from a two-column HTML table of class "list".
  xmlns.table <- pg %>% html_nodes(xpath = "//table[@class='list']")
  df.values <- xmlns.table %>% html_table() %>% bind_rows() %>% 
    as_tibble(.name_repair = 'universal') %>% select(station.ID, station.name)
  
  # Extract attributes "class" and "href" from the hyperlinks ("a" tags).
  # As this will result in duplicates, remove these with "distinct()".
  # Get the station.ID from the link text, filtered with a regular expression.
  xmlns.a <- xmlns.table %>% html_nodes("a")
  df.attr <- xmlns.a %>% html_attrs() %>% bind_cols() %>% t() %>% 
    as_tibble(.name_repair = 'universal') %>% 
    set_names(c('class', 'url')) %>% distinct() %>% 
    mutate(station.ID = xmlns.a %>% html_text() %>% 
             grep('^[A-Z0-9]+$', ., value = TRUE))
  
  # Merge table data and attributes variables into a single dataset.
  # Merge with "key" to translate CSS "class" attribute into station type.
  df <- df.values %>% inner_join(df.attr, by = 'station.ID') %>% 
    inner_join(key, by = 'class') %>% select(-class)
  
  return(df)
}

stations <- get_station_list()
stations
