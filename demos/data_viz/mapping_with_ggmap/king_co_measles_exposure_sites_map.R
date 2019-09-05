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

# -------- Setup -------

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
pacman::p_load(readr, rvest, dplyr, tidyr, maps, ggmap)

# --------- Define functions ---------

get_kc_locations <- function(url) {
  read_html(url) %>% html_nodes(xpath = '//div/table') %>% 
    html_table(fill = TRUE) %>% .[[1]] %>% as_tibble() %>% pull(3) %>% 
    unique() %>% grep('Location', ., value = TRUE, invert = TRUE)
}

plot_map <- function(basemap, bbox) {
  # Plot the map using either a Google or Stamen basemap. Add site labels.
  #   Notes:
  #   *  coord_fixed() is used to crop the Google basemap. It is not essential.
  #      coord_fixed() generates a warning that we can ignore.
  #      "Coordinate system already present. [...]"
  ggmap(basemap) + 
    coord_fixed(xlim = c(bbox['left'], bbox['right']),
                ylim = c(bbox['bottom'], bbox['top']), 
                ratio = 1/cos(pi*41.39/180)) +
    geom_point(mapping = aes(x = lon, y = lat), 
               data = locations, color = 'darkred', size = 1, alpha = 0.4) + 
    theme_void() +
    labs(x = NULL, y = NULL, fill = NULL, 
         title = "2019 King County Measles Outbreak", 
         subtitle = "Exposure Sites in the Seattle/Tacoma Area", 
         caption = "Source: https://www.kingcounty.gov/measles/cases") + 
    theme(plot.title = element_text(size = 3.5),
          plot.subtitle = element_text(size = 3),
          plot.caption = element_text(face = "italic", size = 2.5))
}

# ------- Load data -------

# Get exposure sites from King County.
data_fn <- "king_co_measles_locations.csv"
if (!file.exists(data_fn)) {
  urls <- c(paste0('https://kingcounty.gov/depts/health/news/', 
              c('2019/January/23-measles.aspx', '2019/May/04-measles.aspx', 
                '2019/May/12-measles.aspx', '2019/May/17-measles.aspx', 
                '2019/May/21-measles.aspx', '2019/June/28-measles.aspx')),
            'https://www.kingcounty.gov/measles/cases')
  exposure_site <- as.vector(unlist(sapply(urls, get_kc_locations)))
  
  # Geocode locations to get lat and lon for each site name.
  
  # Register API key. Do NOT save this in a file that you will share.
  key_fn <- '~/google_api.key'
  if (file.exists(key_fn)) {
    register_google(key = readLines(key_fn))
    if (has_google_key()) {
      locations <- geocode(location = exposure_site)
      locations$site <- exposure_site
      locations <- locations %>% drop_na() %>% filter(lon < -120, lat > 45) %>% 
        unique()
      write.csv(locations, data_fn, row.names = FALSE)
    }
  }
} else {
  locations <- read_csv(data_fn)
}

# ------ Stamen Basemap --------

# Create bounding box.
center_lat <- mean(range(locations$lat))
center_lon <- mean(range(locations$lon))
bbox.df <- data.frame(lat = c(center_lat - 0.25, center_lat, center_lat + 0.25), 
                      lon = c(center_lon - 0.13, center_lon, center_lon + 0.13))
bbox <- make_bbox(lon, lat, bbox.df, f = .3)

# Get "terrain" basemap.
stamen_basemap <- get_stamenmap(bbox, zoom = 10, maptype = "terrain")

# Plot map.
plot_map(stamen_basemap, bbox)

# Save the map as a JPG file.
image_fn <- "king_co_measles_map_stamen_terrain.jpg"
ggsave(filename = image_fn, width = 1.85, height = 4.5, units = "in", scale = 0.5)

# Get "toner-lite" basemap.
stamen_basemap <- get_stamenmap(bbox, zoom = 10, maptype = "toner-lite")

# Plot map.
plot_map(stamen_basemap, bbox)

# Save the map as a JPG file.
image_fn <- "king_co_measles_map_stamen_toner.jpg"
ggsave(filename = image_fn, width = 1.85, height = 4.5, units = "in", scale = 0.5)

# ------ Google Basemap --------

# Register API key. Do NOT save this in a file that you will share.
key_fn <- '~/google_api.key'
if (file.exists(key_fn)) {
  register_google(key = readLines(key_fn))
  if (has_google_key()) {
    # Get basemap. Center map at White Center so as to include Bothell and Auburn.
    google_basemap <- get_map("White Center, WA", zoom = 9, maptype = "terrain")
    
    # Plot map.
    plot_map(google_basemap, bbox)
    
    # Save the map as a JPG file.
    image_fn <- "king_co_measles_map_google_terrain.jpg"
    ggsave(filename = image_fn, width = 1.85, height = 4.5, units = "in", scale = 0.5)
  }
}

