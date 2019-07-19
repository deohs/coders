---
title: 'Collecting Real-time Data: EPA Air Quality Index (AQI)'
author: "Brian High"
date: "19 July, 2019"
output:
  ioslides_presentation:
    fig_caption: yes
    fig_retina: 1
    fig_width: 5
    fig_height: 3
    keep_md: yes
    smaller: yes
    template: ../../../templates/ioslides_template.html
  html_document:
    template: ../../../templates/html_template.html
editor_options: 
  chunk_output_type: console
---







## Automated Data Extraction from HTML

Today's example demonstrates these objectives:

* Use a public data freely available on web pages.
* Automate data processing from start to finish (importing to reporting).
* Use "web scraping" techniques to extract data from web pages (HTML).
* Create functions to modularize code and facilitate automation.
* Use "regular expressions" to match patterns and filter data.
* Append data to a local file to accumulate data over time with a scheduled task.
* Use "literate programming" to provide a reproducable report.
* Use a consistent coding [style](https://google.github.io/styleguide/Rguide.xml).
* Share code through a public [repository](https://github.com/deohs/coders) to 
  facilitate collaboration.

We will be using the R language, but several other tools could do the job.

The code and this presentation are free to share and modify according to the 
[MIT License](https://github.com/deohs/coders/blob/master/LICENSE).

## Get data from EPA AQI

This demo is an example of how to automate real-time data collection from the 
web and accumulate it over time in a file.

As the summer progresses, we would expect air quality in our state to 
decrease as wildfires will fill the air with smoke. To see these changes over 
time, we can accumulate this real-time AQI data with the code in this demo.

We will get the current Air Quality Index (AQI) from EPA's "Airnow" site: 
[airnow.gov](https://airnow.gov/index.cfm). 

From the ["AQI Basics" page](https://airnow.gov/index.cfm?action=aqibasics.aqi):

"The higher the AQI value, the greater the level of air pollution and the 
greater the health concern."

We will extract current AQI values from the web and append the data to a file 
to accumulate data over time. 

This can be setup as a scheduled task to automate data collection at an 
interval of your choosing. You will see one way to do this toward the end of 
this demo.

## Setup

Load packages with `pacman` to auto-install any missing packages.


```r
# Load packages.
if (! suppressPackageStartupMessages(require(pacman))) {
  install.packages('pacman', repos = 'http://cran.us.r-project.org')
}
pacman::p_load(dplyr, rvest, httr, readr)
```

We are loading:

* `dplyr` (`mutate()`, `select()`, `filter()`, etc.) for data cleanup
* `rvest` (and `xml2`) for web-scraping with `read_html()`, `html_nodes()`, etc.
* `httr` for `GET()`, which can be used in conjunction with `rvest::read_html()`

## Function: get_states

We need a list of states and their state IDs. We will use `rvest` functions to 
web-scrape the page to get the choices in the state pick list. This pick list 
is located in the top-right of the web page in an HTML form. 

In an HTML form, a pick list will be implemented using the `<select>` tag. 
This one has a ID of "stateid". The choices will be listed using the 
`<option>` tag. The state IDs are found in the "value" attribute and the state 
names are the tag's "text".


```r
# Get a table of states and their stateid to facilitate lookup.
get_states <- function() {
  url <- 'https://airnow.gov/index.cfm'
  pg <- read_html(url)
  select_opts <- pg %>% html_nodes("select#stateid") %>% html_nodes("option")
  state <- select_opts %>% html_text()
  stateid <- select_opts %>% html_attr('value')
  df <- tibble(state = state, stateid = stateid)
  return(df)
}
```

## Function: get_AQI

Use `GET()` from the `httr` package and pipe the output to `read_html()` from the
`rvest` package. `GET()` allows you to send the query parameters as an R "list".


```r
# Get current AQI by city for a given stateid.
get_AQI <- function(stateid = '49') {
  url <- 'https://www.airnow.gov/index.cfm?action=airnow.print_summary'
  res <- GET(url, query = list(stateid = stateid))
  pg <- content(res, as = 'text', encoding = 'utf-8') %>% read_html()
  tbls_ls <- pg %>% html_nodes(".TblInvisible") %>% html_table(fill = TRUE)
  mat <- matrix(tbls_ls[[1]][6:287, "X1"], ncol = 6, byrow = TRUE)[, c(1, 6)]
  df <- as_tibble(mat, .name_repair = 'minimal')
  names(df)  <- c('location', 'aqi')
  return(df)
}
```

## Define variables

Before getting the data, we will define variables used to specify what data we
want. In this case, we want data for "Washington". We will also create our 
output data folder if it does not already exist.


```r
# Define variables.
data_dir <- 'data'
my_state <- 'Washington'

# Create data folder if it does not exist.
dir.create(data_dir, showWarnings = FALSE)
```

## Get states

First, we need to get the list of states in order to get the state IDs. We will
use this to get the state ID for "Washington".

Load data from a CSV file, if present, otherwise get the data from the web.


```r
# Get a dataset of states and state IDs.
states_path <- file.path(data_dir, 'states.csv')
if (!file.exists(states_path)) {
  states <- get_states()
  write.csv(states, states_path, row.names = FALSE)
} else {
  states <- read.csv(states_path)
}

tail(states)
```

```
##            state stateid
## 47       Vermont      47
## 48      Virginia      48
## 49    Washington      49
## 50 West Virginia      50
## 51     Wisconsin      51
## 52       Wyoming      52
```

## Get AQI Data

Now that we have the state IDs, we can get the page for the cities in the state
of Washington.


```r
# Get the current AQI for various cities in the state of Washington.
stateid <- states %>% filter(state == my_state) %>% pull(stateid)
df <- get_AQI(stateid = stateid) %>% 
  mutate(state = my_state, datetime = Sys.time()) %>% 
  select(datetime, state, location, aqi) %>% 
  mutate(aqi = as.numeric(aqi))

# Append the current AQI data to a file to accumulate results over time.
aqi_data_path <- file.path(data_dir, paste(my_state, 'aqi.csv', sep = '_'))

# Write header if data file does not exist.
if (! file.exists(aqi_data_path)) {
  write.table(df, aqi_data_path, sep = ',', row.names = FALSE)
} else {
  # Otherwise, append data to previous records with no header.
  write.table(df, aqi_data_path, append = TRUE, sep = ',', 
              row.names = FALSE, col.names = FALSE)
}
```

## View the results

List the top 15 Washington cities having the highest AQI (greater pollution level).


```r
df %>% filter(state == "Washington") %>% mutate(aqi = as.numeric(aqi)) %>% 
  select(3:4) %>% arrange(desc(aqi)) %>% head(15)
```

```
## # A tibble: 15 x 2
##    location                                         aqi
##    <chr>                                          <dbl>
##  1 Clarkston                                         33
##  2 Kennewick                                         31
##  3 Anacortes                                         29
##  4 Spokane                                           29
##  5 Seattle-Bellevue-Kent Valley                      27
##  6 Vancouver                                         27
##  7 Shelton                                           26
##  8 Bellingham                                        23
##  9 Cascade foothills of east King-Pierce counties    23
## 10 Cascade foothills of King County                  22
## 11 Colville                                          22
## 12 Chehalis                                          21
## 13 Bremerton-Silverdale-Bainbridge Island            20
## 14 Port Angeles                                      20
## 15 Everett-Marysville-Lynnwood                       19
```

## Automated data collection

We collected current data above, but how could we automate this to collect AQI 
data over time?

* We could use these `bash` commands to run from a "Terminal" session:


```bash
cd ~/Documents/coders/demos/data_import/epa_api
Rscript get_AQI.R
```

* We could then use the utility `cron` to run this on a schedule:


```bash
00 * * * * (cd ~/Documents/coders/demos/data_import/epa_api; Rscript get_AQI.R)
```

This will run this script every hour on the hour and append the newly 
harvested data to the same data file.

A copy of this file with data collected hourly for at least one month can be 
found here: [Washington_aqi.csv](data/Washington_aqi.csv)

## Exercises I

1. Load the data of accumulated historical data from the Github page linked 
   above in the previous section: [Washington_aqi.csv](data/Washington_aqi.csv).
2. Do some exploratory data analysis on this dataset. What did you discover?
3. Plot the data for a city in Washington over time and find the peaks in AQI. 
   Do those correspond with known air quality events near or upwind of this city,
   such as wildfires? (Do an internet search to find such events as reported 
   in the [news](https://www.seattlepi.com/washington-wildfires/), 
   [etc.](https://wasmoke.blogspot.com/))
4. Modify the code provided to get data for all states, not just one (Washington). 
   You will need a looping structure like a "for-loop" or use `lapply()`, etc.

## Exercises II (Sample Code)

Given the following code which extracts (near) real-time PM 2.5 data from 
[Washington's Air Monitoring Network](https://fortress.wa.gov/ecy/enviwa/):


```r
pacman::p_load(dplyr, rvest, purrr, con2aqi)

data_dir <- 'data'
time_format <- '%m/%d/%Y %H:%M %p'
tz <- 'America/Los_Angeles'

# Get PM 2.5 "most recent data" from Washington's Air Monitoring Network. 
# Combine the tables: Western PM 2.5, Eastern PM 2.5, and Central PM 2.5.
df <- bind_rows(lapply(c('81', '109', '110'), function(x) {
  url <- paste0('https://fortress.wa.gov/ecy/enviwa/DynamicTable.aspx?G_ID=', x)
  df <- read_html(url) %>% html_node("table#C1WebGrid1") %>% html_table() %>% 
    .[-(1:2),] %>% mutate_at(-(1:2), as.numeric)
  df %>% mutate(pm25 = rowSums(df[, 3:ncol(df)], na.rm = TRUE)) %>% 
    select(X1, X2, pm25) %>% set_names(c('site', 'timestamp', 'pm25')) %>% 
    mutate(timestamp = as.POSIXct(timestamp, format=time_format, tz = tz)) %>% 
    mutate(aqi = con2aqi('pm25', pm25))
}))

dir.create(data_dir, showWarnings = FALSE)
write.csv(df, file.path(data_dir, 'enviwa_pm25_aqi.csv'), row.names = FALSE)
```

## Exercises II

1. Modify the code above to append new data to the output file as shown in the EPA 
   AQI example within this document ("Get AQI Data"). Set up a scheduled task to 
   run this code daily or hourly using the `cron` utility or similar. You can 
   find help for using `cron` [online](https://opensource.com/article/17/11/how-use-cron-linux).
   You can run `cron` from a Linux, Mac, or Unix computer. Since our server 
   `plasmid` runs Linux, you can setup a "cron job" there. Please test the cron 
   job to make sure it is working properly and remember to disable it when you 
   no longer need it.
2. Compare the results you found using the code above with the EPA AQI data. You 
   will need to find a way to combine some locations from the "enviwa" dataset 
   to match locations in the EPA AQI dataset. You will also need a way to match 
   the timestamps. Are the two data sources in agreement?
3. The EPA Airnow site says their AQI is derived from "Combined PM and O3". Modify
   your "enviwa" code to get Ozone data from the "enviwa" site. The page "G_ID" 
   for Ozone is 22. Merge this dataset with the PM 2.5 dataset matching on time 
   and site. Then, for those locations for which Ozone data is available, 
   modify your AQI calculation to use both Ozone and PM 2.5 to better replicate 
   the results from the EPA Airnow AQI website. Do you get better agreement with 
   the EPA Airnow AQI values now that Ozone has been included?

   
