# Get the PM25 data for the Seattle-10th & Weller station for the past n days

# Load packages, installing as needed
if (!require("pacman")) install.packages("pacman")
pacman::p_load(readr, dplyr, tidyr, ggplot2, lubridate, httr, jsonlite)

# Get the StationId for "Seattle-10th & Weller" and the channel for "BAM_PM25"
url <- 'https://enviwa.ecology.wa.gov/ajax/getAllStationsWithoutFiltering'
enviwa_df <- fromJSON(url)
sea_df <- enviwa_df %>% filter(name == "Seattle-10th & Weller")
StationId <- sea_df %>% pull(serialCode)
channel <- sea_df %>% select(monitors) %>% unnest(monitors) %>% 
  filter(name == "BAM_PM25") %>% pull(channel)

# Seattle 10th & Weller: StationId = 163
# BAM_PM25: channel = 32

# Or you can get all channels with 
# channel <- monitors$channel

# Format the query dates
today <- Sys.Date()
n_days <- 14
start_date <- format.Date(today - n_days, format = '%-m/%-d/%Y')
end_date <- format.Date(today - 1, format = '%-m/%-d/%Y')

# Create a list of query parameters
body_lst <- list(StationId = as.character(StationId),
                 MonitorsChannels = channel,
                 reportName = "station report",
                 startDateAbsolute = paste(start_date, "00:00"),
                 endDateAbsolute = paste(end_date, "23:00"),
                 reportType = "Average",
                 fromTb = 60,
                 toTb = 60)

# Get data as JSON
response <- POST(
  "https://enviwa.ecology.wa.gov/report/GetStationReportData",
  config = list(content_type("application/json")), 
  body = body_lst, encode = "json"
)

json_txt <- content(response, "text")

# Clean up data
json_df <- fromJSON(json_txt)$data
df <- bind_rows(json_df$channels)
df$datetime <- json_df$datetime
df$StationId <- json_df$StationId

# Save data as CSV
write_csv(df, paste0(today, "_enviwa_seattle_10th_and_weller_pm25.csv"))

# Make a plot

plot_df <- df %>% filter(status == 1) %>%
  mutate(datetime = as_datetime(datetime)) %>%
  select(datetime, name, value) %>% 
  pivot_wider() %>% rename("pm25" = "BAM_PM25")
my_title <- "Seattle (10th and Weller) PM2.5 from WA Ecology"
qplot(datetime, pm25, data = plot_df, main = my_title)

