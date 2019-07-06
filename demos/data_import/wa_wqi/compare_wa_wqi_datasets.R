# Filename: compare_wa_wqi_datasets.R
# Copyright (c) University of Washington
# License: MIT https://opensource.org/licenses/MIT (See LICENSE file.)
# Repository: https://github.com/deohs/coders
#
# Compare cleaned datasets from WA WQI for "Overall WQI" in 2013:
# 
# 1. Obtained by webscraping from the WA WQI "Statewide water quality 
#    monitoring network" website, our "primary" data source:
#    https://fortress.wa.gov/ecy/eap/riverwq/regions/state.asp?symtype=1
# 2. Obtained from data.wa.gov: "Annual 2013 Water Quality Index Scores"
# 3. Obtained from data.wa.gov: "WQI Parameter Scores 1994-2013"

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
pacman::p_load(dplyr, readr)


# --- Read data set from primary source and subset ---

# Define variables.
data_dir <- 'data'

# Create data folder if it does not exist.
dir.create(data_dir, showWarnings = FALSE)

# Read the data set obtained from the primary data source.
wa_wqi_fn <- file.path(data_dir, 'wa_wqi_primary.csv')
wa_wqi <- read_csv(wa_wqi_fn)

stations_fn <- file.path(data_dir, 'stations_primary.csv')
stations <- read_csv(stations_fn)

station_details_fn <- file.path(data_dir, 'station_details_primary.csv')
station_details <- read_csv(station_details_fn)

# Subset the data we got from the primary data source for year = 2013.
wa_wqi_2013 <- wa_wqi %>% filter(year == 2013) %>% 
  select(Station, overall.WQI) %>% as_tibble() 
dim(wa_wqi_2013)

# --- Compare with other data sets ---

# Read the cleaned data files for the data sets obtained from data.wa.gov.
wa_wqi_orig_fn <- file.path(data_dir, 'wa_wqi.csv')
wa_wqi_alt_fn <- file.path(data_dir, 'wa_wqi_alt.csv')

# Compare with the "Annual 2013 Water Quality Index Scores" data set.
stopifnot(file.exists(wa_wqi_orig_fn))
wa_wqi_orig <- read_csv(wa_wqi_orig_fn)
dim(wa_wqi_orig)

# Subset and rename variables.
wa_wqi_orig <- wa_wqi_orig %>% 
  select(Station = STATION, overall.WQI = `OVERALLWQI 2013`) %>% as_tibble()

# wa_wqi_orig has 10 stations missing from wa_wqi_2013.
stn_diff1 <- setdiff(wa_wqi_orig$Station, wa_wqi_2013$Station) 
stn_diff1
length(stn_diff1)

# List details for stations in wa_wqi_orig missing from wa_wqi_2013.
stn_diff1_details <- stations %>% filter(Station %in% stn_diff1) %>% 
  inner_join(station_details, by = 'Station') %>% 
  select(Station, `Station Name`, type, Ben.Use, quality.level, quality.year)
stn_diff1_details

# Find the station ID and name for any missing stations not listed above.
stations_missing_details <- stn_diff1[!stn_diff1 %in% stn_diff1_details$Station]
suppressMessages(read_csv(wa_wqi_orig_fn)) %>% 
  filter(`STATION` == stations_missing_details) %>% 
  select('STATION', 'STATION NAME')

# wa_wqi_2013 has no stations missing from wa_wqi_orig.
stn_diff2 <- setdiff(wa_wqi_2013$Station, wa_wqi_orig$Station) 
stn_diff2
length(stn_diff2)

# For the matching station IDs, there are no differences in Overall WQI.
df_joined <- inner_join(wa_wqi_2013, wa_wqi_orig, by = 'Station')
df_joined %>% filter(overall.WQI.x != overall.WQI.y)

# Compare the "Annual 2013 Water Quality Index Scores" data set with the 
# "WQI Parameter Scores 1994-2013" data set.
stopifnot(file.exists(wa_wqi_alt_fn))
wa_wqi_alt <- read_csv(wa_wqi_alt_fn)
dim(wa_wqi_alt)

# Subset and rename variables.
wa_wqi_alt <- wa_wqi_alt %>% filter(Year == 2013) %>% 
  select(Station, overall.WQI = `Overall WQI`) %>% as_tibble()

# wa_wqi_orig has 35 stations that are missing from wa_wqi_alt.
stn_diff1 <- setdiff(wa_wqi_orig$Station, wa_wqi_alt$Station) 
stn_diff1
length(stn_diff1)

# wa_wqi_alt has 2 stations that are missing from wa_wqi_orig.
stn_diff2 <- setdiff(wa_wqi_alt$Station, wa_wqi_orig$Station) 
stn_diff2
length(stn_diff2)

# These two stations appear to be in scientific notation.
suppressMessages(read_csv(wa_wqi_alt_fn)) %>% select(1:2) %>% 
  filter(Station %in% stn_diff2) %>% distinct(Station, .keep_all = TRUE)

# View the stations which may appear as numeric with scientific notation.
wa_wqi_orig %>% filter(!is.na(suppressWarnings(as.numeric(Station)))) %>% 
  inner_join(stations, by = 'Station')

# These two should probably be "25E060" and "19E060". Make those corrections.
wa_wqi_alt$Station[wa_wqi_alt$Station == "2.50E+61"] <- "25E060"
wa_wqi_alt$Station[wa_wqi_alt$Station == "1.90E+61"] <- "19E060"

# For the matching station IDs, there are no differences in Overall WQI.
df_joined <- inner_join(wa_wqi_orig, wa_wqi_alt, by = 'Station')
df_joined %>% filter(overall.WQI.x != overall.WQI.y)

