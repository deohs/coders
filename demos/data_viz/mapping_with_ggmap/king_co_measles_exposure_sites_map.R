# Plot a map of exposure sites from the King County measles outbreak of 2019.
# Compare Stamen basemap with Google basemap.

# Filename: king_co_measles_exposure_sites_map.R
# Copyright (c) University of Washington
# License: MIT https://opensource.org/licenses/MIT (See LICENSE file.)
# Repository: https://github.com/deohs/coders

# This script uses ggmap. Here is the citation:
#
#   D. Kahle and H. Wickham. ggmap: Spatial Visualization with ggplot2. The R
#   Journal, 5(1), 144-161. URL
#   http://journal.r-project.org/archive/2013-1/kahle-wickham.pdf

# Clear workspace of all objects and unload all extra (non-base) packages.
rm(list = ls(all = TRUE))
if (!is.null(sessionInfo()$otherPkgs)) {
  res <- suppressWarnings(
    lapply(paste("package:", names(sessionInfo()$otherPkgs), sep = ""),
           detach,
           character.only = TRUE, unload = TRUE, force = TRUE
    )
  )
}

# Load packages.
if (!suppressPackageStartupMessages(require(pacman))) {
  install.packages("pacman", repos = "http://cran.us.r-project.org")
}
pacman::p_load(readr, rvest, dplyr, tidyr, maps, ggmap, ggrepel)


# Get exposure sites from King County.
data_fn <- "king_co_measles_locations.csv"
if (!file.exists(data_fn)) {
  url <- 'https://www.kingcounty.gov/measles/cases'
  df <- read_html(url) %>% html_nodes(xpath = '//div/table') %>% 
    html_table(fill = TRUE) %>% .[[1]] %>% as_tibble()
  names(df) <- as.character(df[1, ])
  df <- df[2:nrow(df), ]
  exposure_site <- df$Location
  
  # Geocode locations to get lat and lon for each site name.
  
  # Register API key. Do NOT save this in a file that you will share.
  key_fn <- '~/google_api.key'
  if (file.exists(key_fn)) {
    register_google(key = readLines(key_fn))
    if (has_google_key()) {
      locations <- geocode(location = exposure_site)
      locations$site <- exposure_site
      locations <- locations %>% drop_na() %>% filter(lon < -120, lat > 45)
      write.csv(locations, data_fn, row.names = FALSE)
    }
  }
} else {
  locations <- read_csv(data_fn)
}


# Make labels.
site_label <- data.frame(site = c('SeaTac Airport', 
                                  "Children's Hospital",
                                  "Auburn Community Center",
                                  "Kenmore Safeway"), 
                         lon = c(-122.3009, -122.2831, -122.2170, -122.2476),
                         lat = c(47.44269, 47.66234, 47.29993, 47.75889))

# ------ Functions --------

plot_map <- function(basemap, bbox) {
  # Plot the map using either a Google or Stamen basemap. Add site labels.
  #   Notes:
  #   1. coord_fixed() is used to crop the Google basemap. It is not essential.
  #      coord_fixed() generates a warning that we can ignore.
  #      "Coordinate system already present. [...]"
  #   2. geom_label_repel() has more features than geom_label() but both work.
  #      geom_label_repel() generates warnings that we can ignore.
  #      "In min(x) : no non-missing arguments to min; returning Inf [...]"
  ggmap(basemap) + 
    coord_fixed(xlim = c(bbox['left'], bbox['right']),
                ylim = c(bbox['bottom'], bbox['top']), 
                ratio = 1/cos(pi*41.39/180)) +
    geom_point(mapping = aes(x = lon, y = lat), 
               data = locations, color = 'darkred', size = 1, alpha = 0.4) + 
    geom_label_repel(data = site_label, mapping = aes(label = site),
                     box.padding   = 0.1, 
                     point.padding = 0.1,
                     label.padding = 0.1,
                     segment.color = 'darkred',
                     size = 1,
                     color = 'darkred',
                     nudge_x = 0.01,
                     nudge_y = -0.01) +
    theme_void() +
    labs(x = NULL, y = NULL, fill = NULL, 
         title = "2019 King County Measles Outbreak", 
         subtitle = "Exposure Sites in the Seattle Area", 
         caption = "Source: https://www.kingcounty.gov/measles/cases") + 
    theme(plot.title = element_text(size = 6),
          plot.subtitle = element_text(size = 5),
          plot.caption = element_text(face = "italic", size = 4))
}


# ------ Stamen Basemap --------

# Create bounding box.
center_lat <- mean(range(locations$lat))
center_lon <- mean(range(locations$lon))
bbox.df <- data.frame(lat = c(center_lat - 0.15, center_lat, center_lat + 0.15), 
                      lon = c(center_lon - 0.15, center_lon, center_lon + 0.15))
bbox <- make_bbox(lon, lat, bbox.df, f = .3)

# Get "terrain" basemap.
stamen_basemap <- get_stamenmap(bbox, zoom = 11, maptype = "terrain")

# Plot map.
plot_map(stamen_basemap, bbox)

# Save the map as a JPG file.
image_fn <- "king_co_measles_map_stamen_terrain.jpg"
ggsave(filename = image_fn, width = 3, height = 4.5, units = "in", scale = 0.5)

# Get "toner-lite" basemap.
stamen_basemap <- get_stamenmap(bbox, zoom = 11, maptype = "toner-lite")

# Plot map.
plot_map(stamen_basemap, bbox)

# Save the map as a JPG file.
image_fn <- "king_co_measles_map_stamen_toner.jpg"
ggsave(filename = image_fn, width = 3, height = 4.5, units = "in", scale = 0.5)

# ------ Google Basemap --------

# Register API key. Do NOT save this in a file that you will share.
key_fn <- '~/google_api.key'
if (file.exists(key_fn)) {
  register_google(key = readLines(key_fn))
  if (has_google_key()) {
    # Get basemap. Center map at White Center so as to include Bothell and Auburn.
    google_basemap <- get_map("White Center, WA", zoom = 10, maptype = "terrain")
    
    # Plot map.
    plot_map(google_basemap, bbox)
    
    # Save the map as a JPG file.
    image_fn <- "king_co_measles_map_google_terrain.jpg"
    ggsave(filename = image_fn, width = 3, height = 4.5, units = "in", scale = 0.5)
  }
}

# Exercise: Make a map of the Pierce County measles outbreak locations using ggmap().
# https://www.tpchd.org/healthy-people/diseases/measles/pierce-county-measles-investigation
