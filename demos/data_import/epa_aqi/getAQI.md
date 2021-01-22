---
title: 'Air Quality Web Data'
author: "Brian High"
date: "22 January, 2021"
output:
  ioslides_presentation:
    fig_caption: yes
    fig_retina: 1
    fig_width: 5
    fig_height: 3
    keep_md: true
    smaller: true
    incremental: false
    logo: img/logo_128.png
    css: inc/deohs-ioslides-theme.css
    template: inc/deohs-default-ioslides.html
editor_options: 
  chunk_output_type: console
---







## Get air quality data from web sites

This demo is an example of how to automate real-time data collection from the 
web.

We will get recent PM2.5 data from Seattle sampling stations from two web sites: 

* EPA's "Airnow" site: https://airnow.gov/
* WA Ecology's Air Monitoring Network site: https://enviwa.ecology.wa.gov/
* Purple Air: https://www.purpleair.com/

## Setup

Load packages with `pacman` to auto-install any missing packages.


```r
# Load packages.
if (! suppressPackageStartupMessages(require(pacman))) {
  install.packages('pacman', repos = 'http://cran.us.r-project.org')
}
pacman::p_load(dplyr, tidyr, ggplot2, lubridate, httr, jsonlite)
```

We are loading:

* `dplyr` -- `mutate()`, `select()`, `filter()`, etc. -- for data cleanup
* `tidyr` -- `unnest()`, `pivot_wider()`, etc. -- for data reshaping
* `ggplot2` -- `ggplot()` -- for plotting
* `lubridate` -- `as_datetime()` -- for date manipulation
* `httr` -- `GET()`, `POST()` -- for sending requests to web servers
* `jsonlite` -- `fromJSON()` -- for extracting JSON from web responses

## Airnow data by date

We will get history air quality data from this page: 

- https://www.airnow.gov/state/?name=washington

The "Historical Air Quality" tab has a place to enter a date. We will need
to create a sequence of dates to get the data for each date.


```r
# Calculate date sequence
n_days <- 14
today_date <- Sys.Date()
start_date <- today_date - n_days
end_date <- today_date - 1
dates <- seq(from = start_date, to = end_date, by = 1)
```

We will use these dates to query the Airnow "API" by incorporating the date
into the web address (URL). Here is an example URL that returns JSON data:

- https://airnowgovapi.com/andata/States/Washington/2021/1/21.json

## What does JSON look like?

Here are the first 400 characters of the JSON returned from a request.


```r
url <- 'https://airnowgovapi.com/andata/States/Washington/2021/1/21.json'
substr(prettify(fromJSON(url)), 1, 400)
```

```
## {
##     "state": "Washington",
##     "fileWrittenDateTime": "20210122T160629Z",
##     "reportingAreas": [
##         {
##             "Ritzville": {
##                 "pm25": 25.0,
##                 "pm10": -999.0,
##                 "ozone": -999.0
##             }
##         },
##         {
##             "Clarkston": {
##                 "pm25": 54.0,
##                 "pm10": -999.0,
##                 "ozone": -999.0
##             }
```

## Get Airnow data

We will use this date sequence to automate the extraction of data using `lapply()`.

The data is in JSON format so we will use `fromJSON()` to parse the JSON into
a list. Then we can use `lapply()` again to transform the list items into 
dataframes. Finally, we combine the dataframes with `rbind()`.


```r
# Get AQI data for each date and combine into a single dataframe
base_url <- 'https://airnowgovapi.com/andata/States/Washington'
df <- do.call("rbind", lapply(dates, function(my_date) {
  try({
      date_url <- format.Date(my_date, format = '/%Y/%-m/%-d')
      url <- paste0(base_url, date_url, ".json")
      json_dat <- fromJSON(fromJSON(url), simplifyDataFrame = FALSE)
      do.call("rbind", lapply(json_dat$reportingAreas, function(x) {
        data.frame(reportingArea = names(x), date = my_date, x[[1]])}))
      }, silent = TRUE)
}))
```

This is a base-R approach. We could do this with the `tidyverse` 
function `map()` instead of `lapply()` and `bind_rows()` instead of `rbind()`.

## Plot Airnow PM2.5 data for Seattle

We obtained data for several sites in Washington. We can subset the results for
Seattle and view them as a scatter plot.


```r
plot_df <- df[grepl("Seattle", df$reportingArea), ]
plot_title <- "Seattle PM2.5 from AirNow"
ggplot(plot_df, aes(date, pm25)) + geom_point() +  ggtitle(plot_title) + 
  geom_smooth(formula = "y ~ x", method = "loess") + theme_classic()
```

![](getAQI_files/figure-html/airnow_plot-1.png)<!-- -->

## Get WA Ecology data

WA Ecology also has airquality data on their [web site](https://enviwa.ecology.wa.gov/).

To find data comparable to the previous example, we will get PM2.5 data for the 
"Seattle-10th & Weller" sampling station.

To do so, we need the "StationId" for "Seattle-10th & Weller" and 
the "channel" for "BAM_PM25". We can get those from querying the web site.


```r
url <- 'https://enviwa.ecology.wa.gov/ajax/getAllStationsWithoutFiltering'
enviwa_df <- fromJSON(url)
sea_df <- enviwa_df %>% filter(name == "Seattle-10th & Weller")
StationId <- sea_df %>% pull(serialCode)
channel <- sea_df %>% select(monitors) %>% unnest(monitors) %>% 
  filter(name == "BAM_PM25") %>% pull(channel)
```

## Format query dates

To query for our dates of interest, we need them in the format the web site expects.


```r
today_date <- Sys.Date()
n_days <- 14
start_date <- format.Date(today_date - n_days, format = '%-m/%-d/%Y')
end_date <- format.Date(today_date - 1, format = '%-m/%-d/%Y')

start_date
```

```
## [1] "1/8/2021"
```

```r
end_date
```

```
## [1] "1/21/2021"
```

## Create list of request parameters

This web site expects our request parameters to be sent as "data". We can 
create a list to help accomplish that.


```r
# Create a list of query parameters
body_lst <- list(StationId = as.character(StationId),
                 MonitorsChannels = channel,
                 reportName = "station report",
                 startDateAbsolute = paste(start_date, "00:00"),
                 endDateAbsolute = paste(end_date, "23:00"),
                 reportType = "Average",
                 fromTb = 60,
                 toTb = 60)
```

## Get WA Ecology JSON

Now that our request is in a list, we can send that list to the web site.


```r
# Get data as JSON
response <- POST(
  "https://enviwa.ecology.wa.gov/report/GetStationReportData",
  config = list(content_type("application/json")), 
  body = body_lst, encode = "json"
)

json_txt <- content(response, "text")
```

## What does this JSON look like?

Here are the first 400 characters of this JSON data string.


```r
substr(prettify(json_txt), 1, 400)
```

```
## {
##     "StationId": 163,
##     "data": [
##         {
##             "datetime": "2021-01-08T00:00:00-08:00",
##             "Originaldatetime": "/Date(-62135568000000)/",
##             "channels": [
##                 {
##                     "DisplayName": "BAM_PM25",
##                     "id": 32,
##                     "name": "BAM_PM25",
##                     "alias": null,
##                     "value": 8.0,
## 
```

## Clean up the data

Now we just need to format the data as a dataframe and clean it up for plotting.


```r
# Clean up data
json_df <- fromJSON(json_txt)$data
df <- bind_rows(json_df$channels)
df$datetime <- json_df$datetime
df$StationId <- json_df$StationId

# Prepare for plotting
plot_df <- df %>% filter(status == 1) %>%
  mutate(datetime = as_datetime(datetime)) %>%
  select(datetime, name, value) %>% 
  pivot_wider() %>% rename("pm25" = "BAM_PM25")
```

## Plot WA Ecology PM2.5 data for Seattle


```r
plot_title <- "Seattle (10th and Weller) PM2.5 from WA Ecology"
ggplot(plot_df, aes(datetime, pm25)) + geom_point() +  ggtitle(plot_title) + 
  geom_smooth(formula = "y ~ x", method = "loess") + theme_classic()
```

![](getAQI_files/figure-html/enviwa_plot-1.png)<!-- -->

## Data collection on a schedule

Purple Air offers current data from several sampling stations, but no clear way 
to get historical data.

However, we can run R code hourly to collect PM2.5 data from the Laurelhurst 
station (48167) over time.


```r
df <- jsonlite::fromJSON("https://www.purpleair.com/json?show=48167")$results
df <- df[df$Label == "L-hurst", c('ID', 'Label', 'PM2_5Value', 'LastSeen')]
df$LastSeen <- lubridate::as_datetime(df$LastSeen)
readr::write_csv(df, "seattle_pm25.csv", append = TRUE)
```

We can save this to a script file and then execute that file hourly using 
the "cron" utility. Here is an example "crontab" entry which would do this.

```
00 * * * * (cd ~/Documents/coders/demos/data_import/epa_aqi; Rscript get_pm25.R)
```

Note: The "cron" utility comes with most Unix and Linux systems. Windows users 
have similar options.
