# Plot a map of air quality in Seattle using historical data from Purple Air 
# and Thingspeak.

# Load packages, installing as needed
if (! suppressPackageStartupMessages(require(pacman))) {
  install.packages('pacman', repos = 'http://cran.us.r-project.org')
}
pacman::p_load(tidyr, dplyr, ggplot2, ggthemes, ggmap, scales, con2aqi,
               grid, gridExtra, lubridate, jsonlite, httr)

# Define functions

get_sensor_meta <- function(pa_id) {
  # Add 2 second delay to reduce load on webserver
  Sys.sleep(2)
  
  lapply(pa_id, function(pa_id) { try({
    # Get dataframe of information we need to query Thingspeak's API
    url <- paste0("https://www.purpleair.com/json?show=", as.character(pa_id))
    df <- jsonlite::fromJSON(url)$results
    df <- df %>%
      select(ID, Label, THINGSPEAK_PRIMARY_ID, THINGSPEAK_PRIMARY_ID_READ_KEY, 
             DEVICE_LOCATIONTYPE)
    
    # Extract values we need from dataframe
    ts_id <- df$THINGSPEAK_PRIMARY_ID
    ts_key <- df$THINGSPEAK_PRIMARY_ID_READ_KEY
    ts_type <- df$DEVICE_LOCATIONTYPE
    
    list(pa_id = pa_id, ts_id = ts_id, ts_key = ts_key, ts_type = ts_type)
  }) })
}

get_sensor_data <- function(ts_list, start = Sys.Date(), end = Sys.Date(),
                            average = "daily", round = 4) {
  # Add 2 second delay to reduce load on webserver
  Sys.sleep(2)
  
  # Add hours and minutes to start and end dates
  start <- paste(start, "00:00:00")
  end <- paste(end, "23:59:59")
  
  lapply(ts_list, function(ts) {
    if (!is.null(ts) & length(ts) == 4) {
      pa_id <- ts$pa_id
      ts_id <- ts$ts_id
      ts_key <- ts$ts_key
      ts_type <- ts$ts_type
      
      # For each pair of IDs and keys, get sensor data as a dataframe
      lapply(1:length(ts_id), function(x) { try({
        # Make web request
        url <- paste('https://thingspeak.com/channels', ts_id[x], 
                     'feeds.json', sep = "/")
        query_list <- list(api_key = ts_key[x], start = start, end = end, 
                           average = average, round = round)
        response <- GET(url, query = query_list)
        
        # Extract data from JSON into a dataframe
        json_txt <- content(response, "text")
        df <- as_tibble(fromJSON(json_txt)[['feeds']])
        
        # Get names for "field1" through "field8" from metadata list
        meta_lst <- fromJSON(json_txt, simplifyVector = FALSE)[[1]] 
        field_names <- meta_lst[grepl('^field\\d+$', names(meta_lst))]
        names(df)[names(df) %in% names(field_names)] <- unlist(field_names)
        
        # Add station IDs and return dataframe
        df$pa_id <- pa_id
        df$ts_id <- ts_id[x]
        df$ts_type <- ts_type[x]
        df
      }) }) %>% bind_rows()
    } else { NULL }
  })
}

# Create a URL to fetch all stations within a rectangular area (Seattle)
base_url <- 'https://www.purpleair.com/data.json'
query_list <- list(fetch = "true", nwlat = 47.72, selat = 47.51, 
                   nwlng = -122.43, selng = -122.25, fields = "pm_1")

# Get station data
json_txt <- content(GET(base_url, query = query_list), "text")
pa_fields <- fromJSON(json_txt)[['fields']]
pa_df <- data.frame(fromJSON(json_txt)[['data']])
names(pa_df) <- pa_fields
pa_df <- pa_df %>% rename(pa_id = ID) %>%
  mutate(across(-Label, ~as.numeric(as.character(.)))) %>% as_tibble()

# Set start and end dates
start <- "2021-01-28"
end <- "2021-01-28"

# Get daily sensor data
ts_list <- get_sensor_meta(pa_df$pa_id)
ts_df <- get_sensor_data(ts_list, start, end) %>% 
  bind_rows() %>% select(-starts_with("Unused")) 

# Combine station data with sensor data
df <- inner_join(pa_df, ts_df, by = "pa_id")

# Filter for plot date
plot_date <- as.Date("2021-01-28")
df <- df %>% filter(as.Date(created_at) == plot_date)

# Select columns of interest for plotting
df <- df %>% 
  select(pa_id, conf, Type, Label, Lat, Lon, Flags, created_at, `PM2.5 (ATM)`)

# Prepare data for plotting
df <- df %>% select(PM2.5 = "PM2.5 (ATM)", conf, Lat, Lon, Flags, Type) %>%
  mutate(across(everything(), ~ as.numeric(as.character(.)))) %>%
  filter(Flags == 0, PM2.5 < 1000, conf > 50) %>%
  select(-c(conf, -Flags)) %>%
  select(PM2.5, Lat, Lon, Type) %>%
  mutate(Type = factor(Type, labels = c('Outside', 'Inside'))) %>%
  mutate(AQI = con2aqi("pm25", PM2.5))

# Filter for sensors within our geographical boundaries
df <- df %>% filter(Lat <= query_list$nwlat, Lat >= query_list$selat, 
                    Lon <= query_list$selng, Lon >= query_list$nwlng)

# Create a factor variable for AQI with levels used in the EPA color scale
# See: https://www.airnow.gov/aqi/aqi-basics/
df$AQI <- cut(df$AQI, ordered_result = TRUE, include.lowest = TRUE,
              breaks = c(0, 50, 100, 150, 200, 300, Inf),
              labels = c("0-50", "50-100", "100-150",
                         "150-200", "200-300", "300+"))

# Create vectors for shape, size, and color of points
aqi_shapes <- c(Outside = 21, Inside = 24)
aqi_sizes <- seq(1, 3.5, 0.5)
aqi_colors <- c("green", "yellow", "orange", "red", "purple", "maroon")

# Prepare a data frame to use for making the bounding box of the basemap.
bbox.df <- with(query_list,
                data.frame(
                  Lat = c(selat, selat + (nwlat - selat) / 2, nwlat),
                  Lon = c(nwlng, nwlng + (selng - nwlng) / 2, selng)
                ))

# Create the basemap.
bbox <- make_bbox(Lon, Lat, bbox.df)
basemap <- get_stamenmap(bbox, zoom = 11, maptype = "toner-lite")

# Create the plot
gg <- ggmap(basemap)
gg <- gg + geom_point(
  data = df, aes(x = Lon, y = Lat, fill = AQI, size = AQI, shape = Type),
  colour = "gray30")
gg <- gg + scale_fill_manual(values = aqi_colors, drop = FALSE)
gg <- gg + scale_shape_manual(values = aqi_shapes)
gg <- gg + scale_size_manual(values = aqi_sizes, guide = FALSE)
gg <- gg + scale_alpha(guide = FALSE)
gg <- gg + guides(
  shape = guide_legend(keyheight = 1,
                       override.aes = list(size = 2)),
  fill = guide_legend(keyheight = 1,
    override.aes = list(shape = 21, fill = aqi_colors, size = aqi_sizes)
  )
)
gg <- gg + labs(x = NULL, y = NULL, fill = "PM2.5 AQI", shape = "Sensor Type",
  title = "Seattle Air Quality Index", 
  subtitle = paste0("US EPA PM2.5 AQI (", plot_date, ")"),
  caption = paste("Sources: Purple Air and Thingspeak")
)
gg <- gg + theme_map(base_family = "Helvetica")
gg <- gg + theme(
  plot.title = element_text(face = "bold"),
  plot.caption = element_text(face = "italic"),
  legend.title = element_text(size = 8)
)
gg <- gg + theme(legend.position = "right",
             plot.caption.position = "plot")
gg <- gg + theme(strip.background = 
                   element_rect(fill = "white", color = "white"))
gg <- gg + theme(strip.text = element_text(face = "bold", hjust = 0))

# View the plot
gg

# Save plot
img_dir <- "img"
if (!dir.exists(img_dir)) dir.create(img_dir, showWarnings = FALSE)
png_filename <- file.path(img_dir, paste0('pa_seattle_daily_avg_', end, '.png'))
ggsave(png_filename, width = 2.5, height = 3)

# Resize this image for presentation using ImageMagick "convert" from Bash
resize_png_filename <- gsub('\\.png', '_50pct_resize.png', png_filename)
system2('convert', args = c('-resize "50%"', png_filename, resize_png_filename))
