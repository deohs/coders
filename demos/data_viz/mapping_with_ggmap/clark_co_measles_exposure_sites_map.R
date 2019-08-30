# Plot a map of exposure sites from the Clark County Public Health measles 
# investigation of 2019. Restrict map to the Portand/Vancouver area.

# Filename: clark_co_measles_exposure_sites_map.R
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
pacman::p_load(readr, rvest, dplyr, tidyr, maps, ggmap)

# Get exposure sites from Clark County Public Health.
data_fn <- "clark_co_measles_locations.csv"
if (!file.exists(data_fn)) {
  url <- 'https://www.clark.wa.gov/public-health/measles-investigation'
  exposure_site <- read_html(url) %>% html_nodes(".field-content") %>% 
    html_nodes("li") %>% html_text() %>% 
    gsub('^\n', '', .) %>% 
    gsub('(?: from |\n| on | Tuesday|,? ?[0-9]+:).*', '', .) %>% 
    grep('^[0-9]|^They|^Noon|^$', ., value = TRUE, invert = TRUE)
  
  # Geocode locations to get lat and lon for each site name.
  
  # Register API key. Do NOT save this in a file that you will share.
  key_fn <- '~/google_api.key'
  if (file.exists(key_fn)) {
    register_google(key = readLines(key_fn))
    if (has_google_key()) {
      locations <- geocode(location = exposure_site)
      locations$site <- exposure_site
      write.csv(locations, data_fn, row.names = FALSE)
    }
  }
} else {
  locations <- read_csv(data_fn)
}

# Restrict map to the Portand/Vancouver area by removing those in Bend.
locations <- locations %>% filter(!grepl('Bend', site))

# Create bounding box.
bbox <- make_bbox(lon, lat, locations, f = .12)

# Plot map.
stamen_basemap <- get_stamenmap(bbox, zoom = 11, maptype = "toner-lite")
ggmap(stamen_basemap) + 
  geom_point(mapping = aes(x = lon, y = lat), data = locations, 
             color = 'red', size = 1, alpha = 0.5) + 
  theme_void() +
  labs(x = NULL, y = NULL, fill = NULL,
       title = "2019 Clark County Measles Outbreak", 
       subtitle = "Exposure Sites in the Portland/Vancouver Area",
       caption = paste(
         "Source: https://www.clark.wa.gov/public-health/measles-investigation"
       )
  ) + theme(plot.title = element_text(size = 6),
            plot.subtitle = element_text(size = 5),
            plot.caption = element_text(face = "italic", size = 4))

# Save the map as a JPG file.
image_fn <- "clark_co_measles_map.jpg"
ggsave(filename = image_fn, width = 3.5, height = 5.15, units = "in", scale = 0.5)
