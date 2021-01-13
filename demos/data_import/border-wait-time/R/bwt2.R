# bwt2.R: Extract border wait time data from XML using R.
#
# Tested on Ubuntu 18.04.5 LTS and R version 3.6.3 (2020-02-29).
#
# Schedule to run once an hour, at half past the hour, e.g.:
#     $ echo '30 * * * * Rscript ~/bin/bwt2.R' | crontab

# Load packages, installing as needed
if (!require("pacman")) install.packages("pacman")
pacman::p_load(jsonlite, dplyr, purrr, readr, tidyr)

# Create data folder
data_dir <- 'data'
dir.create(file.path(data_dir), showWarnings=FALSE, recursive=TRUE)

# Define variables
cl_url <- 'https://bwt.cbp.gov/api/bwtmodern/crossingslist'
base_url <- 'https://bwt.cbp.gov/api/bwtpublicmod'
loc <- "San Ysidro"
csv <- file.path(data_dir, "syR2.csv")

# Parse JSON
crossings <- fromJSON(cl_url)[[1]]
names(crossings)[1:4] <- c('port_number', 'border', 'port_name', 'crossing_name')

# Get port numbers for port of interest
port_num <- crossings %>% filter(port_name == loc) %>% pull(port_number) %>%
  gsub('^09', '', .)

# Create URLs
url <- paste(base_url, port_num, sep = "/")

# Get port data
ports_lst <- lapply(url, fromJSON)
names(ports_lst) <- port_num

# Get ports
myvars <- grep('_lanes$', names(ports_lst[[1]]), value = TRUE, invert = TRUE)
ports <- ports_lst %>% 
  map(.x = ., .f = ~data.frame(t(.x[myvars]))) %>%
  bind_rows(.id = "port_number") %>% unnest(everything())

# Get lane data
lane_types <- grep('_lanes$', names(ports_lst[[1]]), value = TRUE)
lane_type <- rep(lane_types, each = length(ports_lst))
lane_data <- map2(.x = rep(ports_lst, length(lane_types)),
                  .y = lane_type, 
                  .f = ~data.frame(t(.x[[.y]]$standard_lanes), lane_type = .y)) %>%
  bind_rows(.id = "port_number") %>% unnest(everything())

# Combine variables into a single dataframe
port_data <- inner_join(ports, lane_data, by = "port_number")

# Save results
write_csv(port_data, csv)
