# Get wait times (hourly avg.) for one year at San Ysidro (09250401) crossing
# Uses request headers to grab the XML formatted feed instad of the default JSON feed

# Load packages, installing as needed
if (!require("pacman")) install.packages("pacman")
pacman::p_load(xml2, httr, readr, tidyr, dplyr, purrr)

# Create data folder
data_dir <- 'data'
dir.create(file.path(data_dir), showWarnings=FALSE, recursive=TRUE)

# Define variables
base_url <- 'https://bwt.cbp.gov/api/historicalwaittimes/'
crossing_id <- '09250401'
csv <- file.path(data_dir, "syR-hist2.csv")

# Get data and combine as a single dataframe
df <- tibble(bwt_month = 1:12) %>% 
  mutate(url = paste0(base_url, crossing_id, '/POV/GEN/', bwt_month, '/7')) %>%
  mutate(data = map(url, ~map(as_list(xml_find_all(read_xml(GET(.x, accept_xml())), "/port/wait_times/wait_time")), as_tibble))) %>% 
  unnest(data) %>% unnest(data) %>% select(-url) %>% 
  rename("bwt_hour" = "time_slot") %>%
  mutate(across(everything(), as.numeric))

# Save results
write_csv(df, csv)