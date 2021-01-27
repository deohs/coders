# Plot a map of air quality data in Seattle using data from Purple Air

# Load packages, installing as needed

if (! suppressPackageStartupMessages(require(pacman))) {
  install.packages('pacman', repos = 'http://cran.us.r-project.org')
}
pacman::p_load(readr, tidyr, dplyr, ggplot2, ggthemes, ggmap, scales, con2aqi,
               RColorBrewer, grid, gridExtra, lubridate, httr, jsonlite)

# Get current PM2.5 AQI from PurpleAir
data_dir <- "data"
if (!dir.exists(data_dir)) dir.create(data_dir, showWarnings = FALSE)
csv_filename <- file.path(data_dir, paste0('pa_seattle_', today(), '.csv'))

# Create a URL to fetch all stations within a rectangular area (Seattle)
base_url <- 'https://www.purpleair.com/data.json'
query_list <- list(fetch = "true", 
                   nwlat = 47.72,
                   selat = 47.51,
                   nwlng = -122.43,
                   selng = -122.25)

# Get station data
json_txt <- content(GET(base_url, query = query_list), "text")
timestamp <- now(tzone = Sys.timezone())
pa_fields <- fromJSON(json_txt)[['fields']]
pa_df <- data.frame(fromJSON(json_txt)[['data']])
names(pa_df) <- pa_fields
pa_df <- pa_df %>% rename(pa_id = ID) %>%
  mutate(across(-Label, ~as.numeric(as.character(.)))) %>% as_tibble()
pm_vars <- names(pa_df)[grepl('^pm_\\d$', names(pa_df))]
new_pm_vars <- paste("pm25", c('now', '10m', '30m', '1h', '6h', '1d'), 
                     sep = "_")
names(pa_df)[names(pa_df) %in% pm_vars] <- new_pm_vars

# Save data to CSV
#write.csv(pa_df, csv_filename, row.names = FALSE)

# Read data from CSV
#pa_df <- read.csv(csv_filename, stringsAsFactors = FALSE)

# Prepare data for plotting
df <- pa_df %>%
  select(PM2.5 = "pm25_10m", conf, Lat, Lon, Flags, Type) %>%
  mutate(across(everything(), ~ as.numeric(as.character(.)))) %>%
  filter(Flags == 0, PM2.5 < 1000, conf > 50) %>%
  select(-c(conf,-Flags)) %>%
  select(PM2.5, Lat, Lon, Type) %>% 
  mutate(Type = factor(Type, labels = c('Outside', 'Inside'))) %>%
  mutate(AQI = con2aqi("pm25", PM2.5))

# Set shapes for plotting symbols by Type
shapes <- ifelse(df$Type == "Outside", 22, 24)
names(shapes) <- df$Type

# Create a factor variable for AQI with levels used in the EPA color scale
# See: https://www.airnow.gov/aqi/aqi-basics/
df$AQI <- cut(df$AQI, ordered_result = TRUE, include.lowest = TRUE, 
              breaks = c(0, 50, 100, 150, 200, 300, Inf), 
              labels = c("0-50", "50-100", "100-150", 
                         "150-200", "200-300", "300+"))
aqi_colors <- c("green", "yellow", "orange", "red", "purple", "maroon")

# Prepare a data frame to use for making the bounding box of the basemap.
bbox.df <- with(query_list, 
                data.frame(Lat = c(selat, selat + (nwlat - selat)/2, nwlat),
                           Lon = c(nwlng, nwlng + (selng - nwlng)/2, selng)))

# Create the basemap.
bbox <- make_bbox(Lon, Lat, bbox.df)
basemap <- get_stamenmap(bbox, zoom = 11, maptype = "toner-lite")

# Create the map
gg <- ggmap(basemap)
gg <- gg + geom_point(data = df, 
                     aes(x = Lon, y = Lat, fill = AQI, shape = Type), 
                     colour = "gray30", size = 1.5, alpha = 0.75)
gg <- gg + scale_shape_manual(values = shapes)
gg <- gg + scale_fill_manual(values = aqi_colors, drop = FALSE)
gg <- gg + scale_alpha(guide = FALSE)
gg <- gg + guides(shape = guide_legend(keyheight = 0.8,
  override.aes = list(size = 3)), 
                  fill = guide_legend(keyheight = 0.8,
  override.aes = list(shape = 21, fill = aqi_colors, size = 3)))
gg <- gg + labs(x = NULL, y = NULL, fill = "PM2.5 AQI", 
                shape = "Sensor Type",
                title = "Seattle Air Quality Index", 
                subtitle = "US EPA PM2.5 AQI 10-min. avg.",
                caption = paste("Source: Purple Air", 
                                format(timestamp, "%Y-%m-%d %H:%M:%S %Z")))
gg <- gg + theme_map(base_family = "Helvetica")
gg <- gg + theme(plot.title = element_text(face = "bold"),
                 plot.caption = element_text(face = "italic"),
                 legend.title = element_text(size = 8))
gg <- gg + theme(legend.position = "right", plot.caption.position = "plot")
gg <- gg + theme(strip.background = element_rect(fill = "white", color = "white"))
gg <- gg + theme(strip.text = element_text(face = "bold", hjust = 0))
gg

# Save plot
img_dir <- "img"
if (!dir.exists(img_dir)) dir.create(img_dir, showWarnings = FALSE)
png_filename <- file.path(img_dir, gsub('\\.csv', '.png', basename(csv_filename)))
ggsave(png_filename, width = 2.5, height = 3)

# Resize this image for presentation using ImageMagick "convert" from Bash
resize_png_filename <- gsub('\\.png', '_50pct_resize.png', png_filename)
system2('convert', args = c('-resize "50%"', png_filename, resize_png_filename))

