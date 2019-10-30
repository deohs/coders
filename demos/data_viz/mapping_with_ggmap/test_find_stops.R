# Given a GPS track (coordinates and timestamps), find the stops on the route.

# Filename: test_find_stops.R
# Copyright (c) University of Washington
# License: MIT https://opensource.org/licenses/MIT (See LICENSE file.)
# Repository: https://github.com/deohs/coders

# ----- Functions ------

plot_track_and_stops <- function(data_file = file.path("test_track.csv")) {
  require(readr)      # for read_csv()
  require(scales)     # for rescale()
  require(ggmap)      # for make_bbox() and ggmap()

  # Plot a map of a GPS track and the stops along the route. Make the size
  # of the stop points proportional to the duration of the stop.

  if (file.exists(data_file)) {
    # Import the test data for a route.
    df <- read_csv(data_file)

    # Find the stops on the route.
    stops <- with(df, find_stops(latitude, longitude, datetime,
                        stop_min_duration_s = 20, k = 5))

    # Prepare a data frame to use for making the bounding box of the basemap.
    center_lat <- mean(range(df$latitude))
    center_lon <- mean(range(df$longitude))
    border <- 0.015
    bbox.df <- data.frame(
      lat = c(center_lat - border, center_lat, center_lat + border),
      lon = c(center_lon - border, center_lon, center_lon + border))

    # Create the basemap.
    bbox <- make_bbox(lon, lat, bbox.df, f = .3)
    basemap <- get_stamenmap(bbox, zoom = 14, maptype = "toner-lite")

    # Create the plot.
    g <- ggmap(basemap) +
      geom_point(mapping = aes(x = longitude, y = latitude),
                 data = df, color = 'darkorange', size = 1, alpha = 0.4) +
      geom_point(mapping = aes(x = longitude, y = latitude,
                               size = log10(rescale(duration) + 1)/2),
                 data = stops, color = 'darkred', alpha = 0.6) +
      theme_void() + theme(legend.position = "none") +
      labs(x = NULL, y = NULL, fill = NULL)

    return(g)

  } else { warning(paste("Can't find data file:", data_file)) }
}


# ----- Main routine -----

# Load packages.
if (!suppressPackageStartupMessages(require(pacman))) {
  install.packages("pacman", repos = "http://cran.us.r-project.org")
}
pacman::p_load_gh("brianhigh/stopr")
pacman::p_load(readr, scales, ggmap, ggplot2)

# Plot map.
plot_track_and_stops(
  data_file = file.path("test_track.csv"))

# Save image.
ggplot2::ggsave(filename = "test_track.jpg")
