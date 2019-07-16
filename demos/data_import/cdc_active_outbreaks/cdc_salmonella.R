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
links <- read_html(url) %>% html_nodes("div.syndicate") %>% 
  html_nodes("ul") %>% html_nodes("a") %>% html_attr("href")
lst <- lapply(links, function(x) { 
  read_html(paste('https://www.cdc.gov', x, sep = '/')) %>% 
    html_nodes(xpath = "//div[contains(@class, 'card')]//ul//li") %>% 
    html_text() %>% grep(': \\d+$', ., value = TRUE)})
df <- stack(setNames(lst, gsub('^/salmonella/(.*)/index.html$', '\\1', links)))
df <- df %>% mutate(values = gsub('Case Count', 'Reported Cases', values)) %>% 
  separate(values, c('key', 'value'), sep=": ") %>% spread(key, value) %>% 
  mutate_at(vars(-ind), as.integer) %>% as_tibble()

# Get the links to the "map" pages for each outbreak, if link is present.

links.states <- unlist(lapply(links, function(x) { 
  read_html(paste('https://www.cdc.gov', x, sep = '/')) %>% 
    html_nodes(xpath = "//div[contains(@class, 'card')]//ul//li//a") %>% 
    html_attr("href") %>% grep('map\\.html$', ., value = TRUE)}))

# Get table from "map" page showing state totals for the most recent outbreak.
# Use "html_node" function to only get first table of data (i.e., most recent).

lst.states <- lapply(links.states, function(x) {
  read_html(paste('https://www.cdc.gov', x, sep = '/')) %>% 
    html_node(xpath = "//div[contains(@class, 'card')]//table") %>%
    html_table()
})

# Convert list to a dataframe, including the outbreak ID as a variable.

states <- gsub('^/salmonella/(.*)/map.html$', '\\1', links.states)
df.states <- bind_rows(lapply(1:length(links.states), function(x) { 
  lst.states[[x]]$ind <- states[x]
  lst.states[[x]]}))


# ---  -- Summarize Data ------

# Summarize the state totals to compare with "At A Glace" stats.

df.states.summ <- df.states %>% filter(State != "Total") %>% group_by(ind) %>% 
  summarize(`Reported Cases` = sum(`Ill People`), States = dplyr::n()) %>% 
  arrange(ind)

# Clean up the "At a Glance" stats to be comparable with stats from "maps".

df.summ <- df %>% mutate(ind = as.character(ind)) %>% arrange(ind) %>% 
  select(ind, `Reported Cases`, States) %>%  
  filter(States %in% df.states.summ$States)


# ------- Check Results -------

# Check to see if the stats match.

identical(df.summ, df.states.summ)

