# Plot a map of air quality data in Seattle using data from Purple Air

# Load packages, installing as needed

if (! suppressPackageStartupMessages(require(pacman))) {
  install.packages('pacman', repos = 'http://cran.us.r-project.org')
}
pacman::p_load(readr, tidyr, dplyr, ggplot2, ggthemes, ggmap, scales, 
               RColorBrewer, grid, gridExtra, lubridate, httr, jsonlite)

# Get current PM2.5 AQI from PurpleAir
data_dir <- "data"
if (!dir.exists(data_dir)) dir.create(data_dir, showWarnings = FALSE)
csv_filename <- file.path(data_dir, paste0('pa_seattle_', today(), '.csv'))

# Create a URL to fetch all stations within a rectangular area (Seattle)
# Field "pm_5" is the 30-min average PM2.5 AQI
base_url <- 'https://www.purpleair.com/data.json'
query_list <- list(fetch = "true", 
                   nwlat = "47.71803233",
                   selat = "47.47633042",
                   nwlng = "-122.49252319",
                   selng = "-122.24670410",
                   fields = "pm_5")

# Get station data
timestamp <- now(tzone = Sys.timezone())
json_txt <- content(GET(base_url, query = query_list), "text")
pa_fields <- fromJSON(json_txt)[['fields']]
pa_df <- data.frame(fromJSON(json_txt)[['data']])
names(pa_df) <- pa_fields
df <- pa_df %>% rename(pa_id = ID) %>%
  mutate(across(-Label, ~as.numeric(as.character(.)))) %>% as_tibble()
write.csv(df, csv_filename, row.names = FALSE)

# Prepare data for plotting
df <- df %>%
  select(PM2.5 = "pm_5", conf, Lat, Lon, Flags) %>%
  mutate(across(everything(), ~ as.numeric(as.character(.)))) %>%
  filter(Flags == 0, PM2.5 < 1000, conf > 50) %>%
  select(-c(conf,-Flags)) %>%
  select(PM2.5, Lat, Lon)

# Create a factor variable for AQI with levels used in the EPA color scale
# See: https://www.airnow.gov/aqi/aqi-basics/
df$AQI <- cut(df$PM2.5, ordered_result = TRUE, include.lowest = TRUE, 
              breaks = c(0, 50, 100, 150, 200, 300, Inf), 
              labels = c("0-50", "50-100", "100-150", 
                         "150-200", "200-300", "300+"))
aqi_colors <- c("green", "yellow", "orange", "red", "purple", "maroon")

# Prepare a data frame to use for making the bounding box of the basemap.
center_lat <- mean(range(df$Lat))
center_lon <- mean(range(df$Lon))
border <- 0.05
bbox.df <- data.frame(
  Lat = c(center_lat - border, center_lat, center_lat + border/1.5),
  Lon = c(center_lon - border, center_lon, center_lon + border/2.5))

# Create the basemap.
bbox <- make_bbox(Lon, Lat, bbox.df, f = 1)
basemap <- get_stamenmap(bbox, zoom = 10, maptype = "toner-lite")

# Create the map
gg <- ggmap(basemap)
gg <- gg+ geom_point(data = df, aes(x = Lon, y = Lat, fill = AQI), 
                     colour = "black", pch = 21, size = 2, alpha = 0.5)
gg <- gg + scale_fill_manual(values = aqi_colors, drop = FALSE)
gg <- gg + scale_alpha(guide = FALSE)
gg <- gg + labs(x = NULL, y = NULL, 
                title = "Seattle Air Quality Index", 
                subtitle = "US EPA PM2.5 AQI 30-min avg",
                caption = paste("Source: Purple Air", 
                                format(timestamp, "%Y-%m-%d %H:%M %Z")))
gg <- gg + theme_map(base_family = "Helvetica")
gg <- gg + theme(plot.title = element_text(face = "bold"))
gg <- gg + theme(legend.title = element_blank())
gg <- gg + theme(legend.position = "right", plot.caption.position = "plot")
gg <- gg + theme(strip.background = element_rect(fill = "white", color = "white"))
gg <- gg + theme(strip.text = element_text(face = "bold", hjust = 0))
gg

# Save plot
img_dir <- "img"
if (!dir.exists(img_dir)) dir.create(img_dir, showWarnings = FALSE)
png_filename <- file.path(img_dir, gsub('\\.csv', '.png', basename(csv_filename)))
ggsave(png_filename, width = 2.5, height = 2.5)

# Resize this image using ImageMagick "covert" from Bash for use in presentation
resize_png_filename <- gsub('\\.png', '_50pct_resize.png', png_filename)
system2('convert', args = c('-resize "50%"', png_filename, resize_png_filename))

