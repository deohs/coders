# Filename: cdc_salmonella.R
# Copyright (c) University of Washington
# License: MIT https://opensource.org/licenses/MIT (See LICENSE file.)
# Repository: https://github.com/deohs/coders

# From CDC website, get "At a Glance" stats for recent salmonella outbreaks 
# and compare with state totals found in tables on "maps" pages.

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
pacman::p_load(dplyr, tidyr, rvest)


# -------- Get Data -----------

# Go to the CDC "Reports of Active Salmonella Outbreak Investigations" page 
# and get the "At A Glance" data for each outbreak.

url <- 'https://www.cdc.gov/salmonella/outbreaks-active.html'
links <- read_html(url) %>% 
  html_nodes(xpath = "//div[@class='syndicate']/ul/li/a") %>% html_attr("href")
lst <- lapply(links, function(x) { 
  read_html(paste('https://www.cdc.gov', x, sep = '/')) %>% 
    html_nodes(xpath = "//div[contains(@class, 'card')]/ul/li") %>% 
    html_text() %>% grep(': \\d+$', ., value = TRUE)})
df <- stack(setNames(lst, gsub('^/salmonella/(.*)/index.html$', '\\1', links)))
df <- df %>% mutate(values = gsub('Case Count', 'Reported Cases', values)) %>% 
  separate(values, c('key', 'value'), sep=": ") %>% spread(key, value) %>% 
  mutate_at(vars(-ind), as.integer) %>% mutate(ind = as.character(ind))

# Get the links to the "map" pages for each outbreak, if link is present.
# This assumes all have map links: links.states <- gsub('index', 'map', links)

links.states <- unlist(lapply(links, function(x) { 
  read_html(paste('https://www.cdc.gov', x, sep = '/')) %>% 
    html_nodes(xpath = "//div[contains(@class, 'card')]//ul//li//a") %>% 
    html_attr("href") %>% grep('map\\.html$', ., value = TRUE)}))

# Get table from "map" page showing state totals for the most recent outbreak.
# Use "html_node" function to only get first table of data (i.e., most recent).
# Use "try" so that a broken link will not prevent processing other links.

lst.states <- lapply(links.states, function(x) {
  try(read_html(paste('https://www.cdc.gov', x, sep = '/')) %>% 
    html_node(xpath = "//div[contains(@class, 'card')]//table") %>%
    html_table())
})

# Convert list to a dataframe, including the outbreak ID as a variable.
# Get the outbreak ID ("ind") from the 3rd element of the split link path.
# Note: "ind" could also be extracted from the links using gsub().

ind <- sapply(strsplit(links.states, '/'), "[[", 3)
df.states <- bind_rows(lapply(1:length(links.states), function(x) { 
  if (class(lst.states[[x]]) == "data.frame") {
    lst.states[[x]] %>% mutate(ind = ind[x]) %>% filter(!is.na(State)) %>% 
      select(1:3)}}))


# ------- Summarize Data ------

# Summarize the state totals to compare with "At A Glace" stats.

df.states.summ <- df.states %>% filter(State != "Total") %>% group_by(ind) %>% 
  summarize(`Reported Cases` = sum(`Ill People`), States = dplyr::n()) %>% 
  arrange(ind)

# Clean up the "At a Glance" stats to be comparable with stats from "maps".

df.summ <- df %>% arrange(ind) %>% select(ind, `Reported Cases`, States) %>%  
  filter(States %in% df.states.summ$States) %>% as_tibble()


# ------- Check Results -------

# Check to see if the stats match.

identical(df.summ, df.states.summ)

