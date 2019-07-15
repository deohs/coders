# Filename: wa_doh_tb.R
# Copyright (c) University of Washington
# License: MIT https://opensource.org/licenses/MIT (See LICENSE file.)
# Repository: https://github.com/deohs/coders
#
# Example of data extraction from a table in a PDF document:
# Get Tuberculosis Cases Statewide by Year from WA DOH and view top-10 in 2018.
# Data source: https://www.doh.wa.gov/DataandStatisticalReports

# -------- Setup ------------

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
pacman::p_load(tabulizer, dplyr, purrr)

# -------- Get Data ---------

# Get TB data from Wa DOH.
url <- paste('https://www.doh.wa.gov/Portals/1/Documents/Pubs',
             '343-113-TBStatewideByYear2018.pdf', sep ='/')
df <- extract_tables(url, output = 'data.frame') %>% bind_rows() %>% 
  set_names(
    c('county', as.vector(outer(c('cases', 'rate'), 2014:2018, paste, sep="_")))
  ) %>% as_tibble() %>% mutate_each(as.numeric, -county)


# -------- View Data --------

# Show top-10 counties for TB rate in 2018.
df %>% arrange(desc(rate_2018)) %>% select(county, rate_2018) %>% head(10)
