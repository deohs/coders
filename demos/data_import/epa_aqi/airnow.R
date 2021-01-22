# Get AirNow daily AQI for all reported locations in Washington for past n days

# Load packages, installing as needed
if (!require("pacman")) install.packages("pacman")
pacman::p_load(jsonlite, ggplot2)

# Define variables
n_days <- 14
base_url <- 'https://airnowgovapi.com/andata/States/Washington'

# Calculate date sequence
today_date <- Sys.Date()
start_date <- today_date - n_days
end_date <- today_date - 1
dates <- seq(from = start_date, to = end_date, by = 1)

# Get AQI data for each date and combine into a single dataframe
df <- do.call("rbind", lapply(dates, function(my_date) {
  try({
      date_url <- format.Date(my_date, format = '/%Y/%-m/%-d')
      url <- paste0(base_url, date_url, ".json")
      json_dat <- fromJSON(fromJSON(url), simplifyDataFrame = FALSE)
      do.call("rbind", lapply(json_dat$reportingAreas, function(x) {
        data.frame(reportingArea = names(x), date = my_date, x[[1]])}))
      }, silent = TRUE)
}))

# Save as a CSV file
write.csv(df, paste0(today_date, "_airnow_wa", ".csv"), row.names = FALSE)

# View Seattle's data
sea_df <- df[grepl("Seattle", df$reportingArea), ]
sea_df

# View a plot of Seattle's pm25 data
qplot(date, pm25, data = sea_df, main = "Seattle PM2.5 from AirNow")
