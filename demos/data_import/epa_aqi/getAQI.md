---
title: 'Automated Data Extraction: EPA AQI'
author: "Brian High"
date: "18 July, 2019"
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

Get the current Air Quality Index (AQI) from EPA's "Airnow" site (airnow.gov). 

From the [AQI website](https://airnow.gov/index.cfm?action=aqibasics.aqi):

"The higher the AQI value, the greater the level of air pollution and the 
greater the health concern."

We will look at current AQI values, but want to use our code to accumulate data 
over time. Do do so, we will append the data to a file. This can be setup 
as a scheduled task to automate data collection at an interval of your choosing.

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

* `dplyr` (several functions) and for data cleanup
* `rvest` (and `xml2`) for web-scraping with `read_html()`, `html_nodes()`, etc.
* `httr` for `GET()`, an alternative to `rvest::read_html()`

## Function: get_states

We need a list of states and their state IDs. We will use `rvest` functions to 
web-scrape the page to get the choices in the state pick list. This pick list 
is located in the top-right of the web page. 

In an HTML form, a pick list will be implmented using the `<select>` tag. 
This one has  class of "stateid". The choices will be listed using the `<option>` 
tag. The state IDs are the "value" and the state names are the "text".


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

Use `GET()` from the `httr` package as an alternative to `read_html()` from the
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

Now that we have the state IDs, we can get the page for each city in the state
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
##  1 Ellensburg                                        52
##  2 Spokane                                           48
##  3 Kennewick                                         34
##  4 Cascade foothills of east King-Pierce counties    29
##  5 Vancouver                                         29
##  6 Bellingham                                        27
##  7 Seattle-Bellevue-Kent Valley                      27
##  8 Shelton                                           27
##  9 Cascade foothills of King County                  26
## 10 Anacortes                                         25
## 11 Port Angeles                                      22
## 12 Sunnyside                                         20
## 13 Cheeka Peak                                       19
## 14 Port Townsend                                     19
## 15 Tacoma-Puyallup                                   17
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

