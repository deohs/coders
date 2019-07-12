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
  tds <- pg %>% html_nodes(xpath = "//table[@class='key']//table//td")
  key <- tibble(class = tds %>% html_attr('class'), 
                type  = tds %>% html_text() %>% 
                  gsub('^.?([A-Za-z-]+).*$', '\\1', .))
  
  # Get the list of stations from a two-column HTML table of class "list".
  # Extract all needed variables from the hyperlinks ("a" tags).
  a <- pg %>% html_nodes(xpath = "//table[@class='list']//td//a")
  df <- a %>% html_text() %>% matrix(nrow = 2) %>% t() %>% 
    as_tibble(.name_repair = 'unique') %>% 
    set_names(c('station.ID', 'station.name'))
  df.attr <- a %>% html_attrs() %>% t() %>% do.call("rbind", .) %>% 
    as_tibble() %>% set_names(c('class', 'url')) %>% distinct()
  df <- df %>% bind_cols(df.attr)
  
  # Merge with "key" to translate CSS "class" attribute into station type.
  return(df %>% inner_join(key, by = 'class') %>% select(-class))
}

stations <- get_station_list()
stations
