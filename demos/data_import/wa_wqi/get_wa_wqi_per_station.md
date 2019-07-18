---
title: 'Automated Data Extraction: WA WQI'
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
* Read from locally-cached data files to avoid needlessly repeating downloads.
* Use "literate programming" to provide a reproducable report.
* Use a consistent coding [style](https://google.github.io/styleguide/Rguide.xml).
* Share code through a public [repository](https://github.com/deohs/coders) to 
  facilitate collaboration.

We will be using the R language, but several other tools could do the job.

The code and this presentation are free to share and modify according to the 
[MIT License](https://github.com/deohs/coders/blob/master/LICENSE).

## Get data from WA Dept. of Ecology

Get all Washington Water Quality Index Scores for all available years from 
all freashwater stream and river stations from the WA Department of Ecology. 

We will extract HTML tables from multiple web pages and combine into a 
single WQI dataset. Each web page fetched represents data for one station.

Data files will be cached to save time when re-running the code.

Finally, we will create a map for 2013 to compare with maps made from data 
files obtained from data.wa.gov.

## Setup

Load packages with `pacman` to auto-install any missing packages.


```r
# Load packages.
if (! suppressPackageStartupMessages(require(pacman))) {
  install.packages('pacman', repos = 'http://cran.us.r-project.org')
}
pacman::p_load(dplyr, tidyr, rvest, mgsub, readr, purrr, ggmap)
```

We are loading:

* `dplyr` (several functions) and `tidyr` (`separate()`) for data cleanup
* `rvest` (and `xml2`) for web-scraping with `read_html()`, `html_nodes()`, etc.
* `mgsub` for multiple-pattern search/replace with `mgsub()`
* `readr` for reading files with `read_csv()`
* `purrr` for `set_names()`, like `colnames()` but for use in a pipeline 
* `ggmap` (and `ggplot2`) for plotting a map of the results

## User-defined functions

We will define the following functions for code modularity and automation.

`get_list_of_stations()` - Gets station list to follow when getting more data.

`get_station_details()` ... (wrapper) - Orchestrates station details collection.

* `get_station_details_ns()` - Gets XML nodeset for station details tables.
* `extract_stn_details_from_ns()` - Extracts data from tables nodeset.
* `extract_stn_qual_from_ns()` - Extracts overall station quality level.
* `clean_station_details()` - Cleans up dataset.

`get_wa_wqi_per_station()` ... (wrapper) - Orchestrates WQI data collection.

* `get_wa_wqi_table_ns()` - Gets XML nodeset for WQI data tables.
* `extract_wa_wqi_from_ns()` ... - Extracts data from tables nodeset.
   * `clean_wa_wqi_data()` - Cleans up dataset.

`create_wqi_map()` ... - Creates the map, including base map, points, legend, etc.

* `create_bbox()` - Creates boundary box for base map.

## Function: Get list of stations


```r
get_list_of_stations <- function () {
  # Get XML nodeset of table(s) of class "list" containing a list of stations.
  url <- 'https://fortress.wa.gov/ecy/eap/riverwq/regions/state.asp?symtype=1'
  xmlns <- read_html(url) %>% html_nodes("table.list")
  
  # Extract station type from img class and station ID and name from table text.
  stn_type <- xmlns %>% html_nodes("img[class $= 'sta']") %>% 
    html_attr("class") %>% mgsub(., c('Rsta', 'Dsta'), c('Long-term', 'Basin'))
  stations <- xmlns %>% html_table(fill = TRUE) %>% bind_rows() %>% .[, 2:3] %>% 
    set_names(c('Station', 'Station Name')) %>% mutate(`Station Type` = stn_type)
  return(stations)
}
```

Test it:


```r
stations <- get_list_of_stations()
head(stations, 4)
```

```
##   Station               Station Name Station Type
## 1  01A050       Nooksack R @ Brennan    Long-term
## 2  01A120 Nooksack R @ No Cedarville    Long-term
## 3  01F070    SF Nooksack @ Potter Rd        Basin
## 4  01N060  Bertrand Cr @ Rathbone Rd        Basin
```

## Function: Get station details (wrapper)


```r
get_station_details <- function(Station = '') {
  col_names <- c("type", "Ben.Use", "uwa", "ecoregion", "county", "contact", 
                 "lat", "lon", "LLID", "Route.Measure", "river.mile", "substrate", 
                 "flow", "gaging", "mixing", "elevation", "surrounding", 
                 "waterbody.id", "location.type", "overall.quality", 
                 "quality.level", "quality.year", "Station")
  
  # Get station details table XML nodeset for a station ID.
  xmlns <- get_station_details_ns(Station = Station)
  
  # Extract station details from table nodeset.
  df <- extract_stn_details_from_ns(xmlns)
  
  # Add a variable for the note about overall water quality.
  stn_qual <- extract_stn_qual_from_ns(xmlns)
  df$overall.quality <- ifelse(length(stn_qual) > 0, stn_qual, NA)
  
  # Add a variable for the station.
  df$Station <- Station
  
  # Clean up station details data frame.
  df <- clean_station_details(df)
  return(df[, col_names])
}
```

## Function: Get station details nodeset


```r
get_station_details_ns <- function(Station = '') {
  # Get station details table XML nodeset for a station ID.
  url <- 'https://fortress.wa.gov/ecy/eap/riverwq/station.asp'
  qstr <- paste('sta=', Station, sep='')
  url <- paste(url, qstr, sep = '?')
  xmlns <- read_html(url) %>% html_nodes("table")
  return(xmlns)
}
```

Test it:


```r
Station <- stations$Station[1]
xmlns <- get_station_details_ns(Station)
head(xmlns, 5)
```

```
## {xml_nodeset (5)}
## [1] <table width="100%" cellpadding="0" cellspacing="0" border="0">\n<tr ...
## [2] <table style="margin-top:20;margin-bottom:20" align="center" width=" ...
## [3] <table width="100%" cellpadding="8" cellspacing="0" border="0"><tr>\ ...
## [4] <table cellspacing="1" cellpadding="1" border="0" align="center">\n< ...
## [5] <table width="396" style="text-align:center;font-size:70%" cellpaddi ...
```

## Function: Extract station details


```r
extract_stn_details_from_ns <- function(xmlns) {
  # Get station details from two tables and combine them.
  lst <- xmlns %>% 
    html_nodes(xpath='.//table[contains(@width, "396")]') %>% 
    html_table(fill = TRUE, header = TRUE)
  df <- bind_cols(lst[[1]][1,], lst[[2]][1,])
  names(df) <- gsub('\\W', '.', names(df))
  df$LLID <- as.character(df$LLID)
  df$`waterbody.id` <- as.character(df$`waterbody.id`)
  return(df)
}
```

Test it:


```r
stn_details <- extract_stn_details_from_ns(xmlns)
stn_details %>% select(type, latitude, longitude, LLID, waterbody.id)
```

```
##        type latitude longitude          LLID waterbody.id
## 1 long-term   48.819    122.58 1225982487712   WA-01-1010
```

## Function: Extract station quality


```r
extract_stn_qual_from_ns <- function(xmlns) {
  # Get station overall water quality text comment from table XML nodeset.
  stn_qual <- xmlns %>% 
    html_nodes(xpath='.//td[contains(@align, "center")]') %>% 
    html_text()
  stn_qual <- grep('Overall water quality', stn_qual, value = TRUE)
  return(stn_qual)
}
```

Test it:


```r
stn_qual <- extract_stn_qual_from_ns(xmlns)
strwrap(stn_qual)
```

```
## [1] "Overall water quality at this station met or exceeded expectations"
## [2] "and is of lowest concern. (based on water-year 2015 summary)"
```

## Function: Clean station details


```r
clean_station_details <- function(df) {
  # Rename variables. Force longitude to be negative. Split overall quality.
  df <- df %>% rename('lat' = 'latitude', 'lon' = 'longitude') %>% 
    mutate(lon = ifelse(lon > 0, -lon, lon)) %>% 
    mutate(overall.quality = gsub('^.* (\\w+) concern.*water-year (\\d+).*$', 
                                  '\\1,\\2', overall.quality)) %>% 
    separate(overall.quality, c('quality.level', 'quality.year'), ',', 
             convert = TRUE, remove = FALSE) %>% 
    select(-map.detail)
  names(df) <- gsub('[.]+', '.', names(df))
  return(df)
}
```

Test it:


```r
stn_details$overall.quality <- ifelse(length(stn_qual) > 0, stn_qual, NA)
stn_details$Station <- Station
stn_details <- clean_station_details(stn_details)
stn_details %>% select(type, lat, lon, quality.level, quality.year, Station)
```

```
##        type    lat     lon quality.level quality.year Station
## 1 long-term 48.819 -122.58        lowest         2015  01A050
```

## Function: Get WA WQI (wrapper)


```r
get_wa_wqi_per_station <- function(Station = '') {
  # Define column names to be returned in resulting data frame.
  col_names <- c('year', 'fecal.coliform.bacteria', 'oxygen', 'pH', 
                 'suspended.solids', 'temperature', 'total.persulf.nitrogen', 
                 'total.phosphorus', 'turbidity', 'overall.WQI', 
                 'adjusted.for.flow', 'Station')
  
  # Get table XML nodeset WA WQI data for a station.
  lst <- get_wa_wqi_table_ns(Station)
  
  # Extract data from nodeset and clean up.
  df <- extract_wa_wqi_from_ns(lst[[1]], Station = Station, year = lst[[2]], 
                               col_names = col_names)
  
  # Return the data frame with the columns in a consitent order.
  return(df[, col_names])
}
```

## Function: Get WQI table nodeset


```r
get_wa_wqi_table_ns <- function(Station = '') {
  # Fetch web page.
  url <- 'https://fortress.wa.gov/ecy/eap/riverwq/station.asp'
  query <- list(theyear = '', tab = 'wqi', scrolly = 262, wria = 03, 
                sta = Station)
  qstr <- paste(names(query), query, sep = "=", collapse = "&")
  pg <- read_html(paste(url, qstr, sep = '?'))
  
  # Extract year of most recent data. To be used for pages with only one year.
  text.year <- pg %>% html_nodes(xpath = "//ol/li/a") %>% html_text()
  year <- as.numeric(gsub('^.*(\\d{4}).*$', '\\1', text.year))[1]
  
  # Attempt to get one or more "twocolumn" tables from the page.
  xmlns <- pg %>% html_nodes("table.twocolumn")
  return(list(xmlns, year))
}
```

## Function: Extract WQI from nodeset


```r
extract_wa_wqi_from_ns <- function(xmlns, Station = '', year = NA, col_names = c()) {
  if (length(xmlns) == 0) {
    # Create an empty data frame if no matching table was found.
    mat <- matrix(ncol = length(col_names), nrow = 0)
    class(mat) <- 'numeric'
    df <- setNames(data.frame(mat), col_names)
  } else {
    # Select the "twocolumn" table containing WQI and convert to a data frame.
    if (length(xmlns) > 1) {
      lst <- xmlns %>% `[`(2) %>% html_node("table") %>% html_table(fill = TRUE)
    } else {
      if (length(xmlns) == 1) {
        lst <- xmlns %>% html_node("table") %>% html_table(fill = TRUE)
        lst[[1]] <- rbind(data.frame(
          X1 = '', X2 = year, stringsAsFactors = FALSE), lst[[1]])
      }
    }
    
    # Convert to a data frame, clean up, and add station ID column.
    df <- as.data.frame(t(lst[[1]]), row.names=FALSE, stringsAsFactors=FALSE)
    df <- clean_wa_wqi_data(df)
    df$Station <- Station
  }
  return(df)
}
```

## Function: Clean WA WQI data


```r
clean_wa_wqi_data <- function(df) {
  # Use first row as column names
  df_col_names <- c('year', df[1, -1])
  df_col_names <- gsub('[^A-Za-z0-9_.]', '.', df_col_names)
  names(df) <- df_col_names
  
  # Remove rows missing the year and columns missing a column name.
  df <- df[grepl('^\\d{4}$', df$year), df_col_names[df_col_names != '']]
  
  # Add missing variables with NA values.
  if (!'overall.WQI' %in% names(df)) df$overall.WQI <- NA
  if (!'adjusted.for.flow' %in% names(df)) df$adjusted.for.flow <- NA
  
  # Convert all values to numeric.
  df <- suppressWarnings(
    mutate_all(df, function(x) as.numeric(as.character(x))))
  return(df)
}
```

## Test: Get WQI data and Clean

Test the AQI data functions with a test function that runs the wrapper function:


```r
test_get_wa_wqi <- function(Station) {
  get_wa_wqi_per_station(Station) %>% 
  select(year, oxygen, pH, overall.WQI, adjusted.for.flow, Station) %>% head()
}
test_get_wa_wqi('01A050')
```

```
##   year oxygen pH overall.WQI adjusted.for.flow Station
## 1 1994     82 96          73                61  01A050
## 2 1995     80 96          56                55  01A050
## 3 1996     80 96          49                50  01A050
## 4 1997     73 93          41                45  01A050
## 5 1998     78 96          62                59  01A050
## 6 1999     88 96          42                54  01A050
```

Test with a Station that only offers one year of AQI data:


```r
test_get_wa_wqi('07A100')
```

```
##   year oxygen pH overall.WQI adjusted.for.flow Station
## 1 2011     86 89          NA                NA  07A100
```

## Function: Create bounding box


```r
# Create a bounding box for the map.
create_bbox <- function(lat, lon, pad = 0.15) {
  height <- max(lat) - min(lat)
  width <- max(lon) - min(lon)
  bbox <- c(
    min(lon) - pad * width,
    min(lat) - pad * height,
    max(lon) + pad * width,
    max(lat) + pad * height
  )
  names(bbox) <- c('left', 'bottom', 'right', 'top')
  return(bbox)
}
```

Test it:


```r
with(stn_details, create_bbox(lat, lon))
```

```
##     left   bottom    right      top 
## -122.580   48.819 -122.580   48.819
```

## Function: Create WA WQI map


```r
# Create a ggmap for a year given a data frame with lat, lon, and WQI.
create_wqi_map <- function(df, year) {
  if (all(c('lon', 'lat', 'overall.WQI') %in% names(df))) {
    # Define a boundary box and make a map base layer of "Stamen" tiles.
    bbox <- create_bbox(df$lat, df$lon)
    map <- suppressMessages(
      get_stamenmap(bbox, zoom = 8, maptype = "toner-background"))
    
    # Make the map image from the tiles using `ggmap` and add points, legend, etc.
    g <- ggmap(map, darken = c(0.3, "white")) + theme_void() 
    g <- g + geom_point(aes(x = lon, y = lat, fill = overall.WQI), 
                        data = df, pch = 21, size = 3) + 
      scale_fill_gradient(name = "WQI", low = "red", high = "green") + 
      ggtitle(label = paste("Washington State", 
                            "River and Stream Water Quality Index (WQI)"),
              subtitle = paste0("Source: River and Stream Monitoring Program, ", 
                               "WA State Department of Ecology (", year, ")")) +
      theme(legend.position = c(.98, .02), legend.justification = c(1, 0)) 
    return(g)
  } else {
    warning("Missing required variables in df passed to create_wqi_map().")
  }
}
```

## Using the functions: Get stations


```r
# Define variables.
data_dir <- 'data'

# Create data folder if it does not exist.
dir.create(data_dir, showWarnings = FALSE)

# Get list of stations. Use a cached data file, if present.
file_name <- file.path(data_dir, 'stations_primary.csv')
if (!file.exists(file_name)) {
  stations <- get_list_of_stations()
  write.csv(stations, file_name, row.names = FALSE)
} else {
  stations <- suppressMessages(read_csv(file_name))
}
head(stations, 4)
```

```
## # A tibble: 4 x 3
##   Station `Station Name`             `Station Type`
##   <chr>   <chr>                      <chr>         
## 1 01A050  Nooksack R @ Brennan       Long-term     
## 2 01A120  Nooksack R @ No Cedarville Long-term     
## 3 01F070  SF Nooksack @ Potter Rd    Basin         
## 4 01N060  Bertrand Cr @ Rathbone Rd  Basin
```

## Using the functions: Get station details


```r
# Get station details for all stations. Use a cached data file, if present.
file_name <- file.path(data_dir, 'station_details_primary.csv')
if (!file.exists(file_name)) {
  station_details <- bind_rows(lapply(stations$Station, get_station_details))
  write.csv(station_details, file_name, row.names = FALSE)
} else {
  station_details <- suppressMessages(read_csv(file_name)) %>% 
    mutate(LLID = as.character(LLID),
           `waterbody.id` = as.character(`waterbody.id`))
}
head(station_details, 4)
```

```
## # A tibble: 4 x 23
##   type  Ben.Use uwa   ecoregion county contact   lat   lon LLID 
##   <chr> <chr>   <chr> <chr>     <chr>  <chr>   <dbl> <dbl> <chr>
## 1 long… core/p… 790 … Puget Lo… Whatc… Clishe   48.8 -123. 1225…
## 2 long… core/p… 596 … Puget Lo… Whatc… Christ…  48.8 -122. 1225…
## 3 basin core/p… <NA>  Puget Lo… Whatc… Christ…  48.8 -122. 1222…
## 4 basin core/p… <NA>  Puget Lo… Whatc… Christ…  48.9 -123. 1225…
## # … with 14 more variables: Route.Measure <dbl>, river.mile <dbl>,
## #   substrate <chr>, flow <chr>, gaging <chr>, mixing <chr>,
## #   elevation <chr>, surrounding <chr>, waterbody.id <chr>,
## #   location.type <chr>, overall.quality <chr>, quality.level <chr>,
## #   quality.year <dbl>, Station <chr>
```

## Using the functions: Get WQI data


```r
# Get WQI data for all stations. Use a cached data file, if present.
file_name <- file.path(data_dir, 'wa_wqi_primary.csv')
if (!file.exists(file_name)) {
  wa_wqi <- bind_rows(lapply(stations$Station, get_wa_wqi_per_station))
  write.csv(wa_wqi, file_name, row.names = FALSE)
} else {
  wa_wqi <- suppressMessages(read_csv(file_name))
}
head(wa_wqi, 4)
```

```
## # A tibble: 4 x 12
##    year fecal.coliform.… oxygen    pH suspended.solids temperature
##   <dbl>            <dbl>  <dbl> <dbl>            <dbl>       <dbl>
## 1  1994               75     82    96               67          76
## 2  1995               75     80    96               29          73
## 3  1996               66     80    96               54          71
## 4  1997               63     73    93               36          82
## # … with 6 more variables: total.persulf.nitrogen <dbl>,
## #   total.phosphorus <dbl>, turbidity <dbl>, overall.WQI <dbl>,
## #   adjusted.for.flow <dbl>, Station <chr>
```

## Using the functions: Create the map


```r
# Prepare dataset for plotting. Join with station details to get lat and lon.
wa_wqi <- wa_wqi %>% 
  inner_join(station_details %>% select(Station, lat, lon), by = 'Station')

# Use 2013 for comparison with datasets from data.gov.
map_year = 2013

# Uncomment the line below to use the most recent year of WQI data available.
#map_year <- max(wa_wqi$year)

# Filter dataset by year. 
df <- wa_wqi %>% filter(year == map_year)

# Create a map from lon, lat, and overall.WQI variables in df for map_year.
g <- create_wqi_map(df, map_year)
```

## View the map

![](get_wa_wqi_per_station_files/figure-html/view_map-1.png)<!-- -->

## Exercises

1. Run the code in [compare_stations_2013_wa_wqi.R](compare_stations_2013_wa_wqi.R) 
   to compare the three data sources we found for WA WQI 2013. Are there any 
   stations which have data values which are not the same in all three datasets?
   Which dataset includes the most and least stations? Which has errors? What 
   might be the source of these errors?
2. What is the most recent year of WA WQI data in this dataset? Is there more 
   recent data to be found online? How would you import it into R?

## Advanced Exercises: CDC Salmonella

Given the following code:


```r
# Go to the CDC "Reports of Active Salmonella Outbreak Investigations" page 
# and get the "At A Glance" data for each outbreak.
pacman::p_load(dplyr, tidyr, rvest)
url <- 'https://www.cdc.gov/salmonella/outbreaks-active.html'
links <- read_html(url) %>% 
  html_nodes(xpath = "//div[@class='syndicate']/ul/li/a") %>% html_attr("href")
lst <- lapply(links, function(x) { 
  read_html(paste('https://www.cdc.gov', x, sep = '/')) %>% 
    html_nodes(xpath = "//div[contains(@class, 'card')]/ul/li") %>% 
    html_text() %>% grep(': \\d+$', ., value = TRUE)})
df <- stack(setNames(lst, gsub('^/salmonella/(.*)/index.html$', '\\1', links)))
df <- df %>% mutate(values = gsub('Case Count', 'Reported Cases', values)) %>% 
  separate(values, c('key', 'value'), sep=": ") %>% spread(key, value)
```

1. Modify this code to get the table of "Ill People" per state for each
   recent outbreak. Example: https://www.cdc.gov/salmonella/uganda-06-19/map.html
   Combine these into a single dataset with the outbreak identifier as a variable.
2. Summarize your results by outbreak to compare with the values for "Reported 
   Cases" and "States" obtained by using the code provided above. Do they match?
