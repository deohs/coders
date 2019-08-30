# Make a map of the immunization coverage rates for Washington schools for 
# all students K-12 for the 2016-2017 school year using the leaflet package.
#
# See:
# https://catalog.data.gov/dataset/all-students-kindergarten-through-12th-grade-immunization-data-by-school-2016-2017

# Filename: wa_immunization_coverage_leaflet_map.R
# Copyright (c) University of Washington
# License: MIT https://opensource.org/licenses/MIT (See LICENSE file.)
# Repository: https://github.com/deohs/coders

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
pacman::p_load(dplyr, tidyr, readr, ggmap, leaflet, htmlwidgets, htmltools)

# Get data.
url <- 'https://data.wa.gov/api/views/9zru-c2kz/rows.csv?accessType=DOWNLOAD'
wa_coverage <- read_csv(url)

# Parse location variable to get lat/lon coordinate pair, if present.
wa_coverage <- wa_coverage %>% 
  mutate(lat_lon = gsub('^.*\n\\(([0-9., -]+)\\)$', '\\1', `Location 1`),
         site = ifelse(!grepl('^[0-9., -]+$', lat_lon), 
                       gsub('\n', ', ', lat_lon), NA),
         lat_lon = ifelse(!grepl('^[0-9., -]+$', lat_lon), NA, lat_lon)) %>% 
  separate(lat_lon, c('lat', 'lon'), ', ')
wa_coverage <- wa_coverage %>% 
  mutate(site = ifelse(is.na(site), NA, paste0(site, ', WA')))

# Geocode to obtain any missing coordinate pairs.
# Read locations file, if present, otherwise obtain from Google geocoding.
data_fn <- "wa_coverage_locations.csv"
key_fn <- '~/google_api.key'
if (!file.exists(data_fn)) {
  if (file.exists(key_fn)) {
    register_google(key = readLines(key_fn))
    if (has_google_key()) {
      lookup <- unique(wa_coverage$site[!is.na(wa_coverage$site)])
      locations <- geocode(location = lookup)
      locations$site <- lookup
      locations <- locations %>% drop_na() %>% filter(lon < -115, lat > 45)
      write.csv(locations, data_fn, row.names = FALSE)
    }
  }
} else {
  locations <- read_csv(data_fn)
}

# Merge geolocated coordinates into data set.
wa_coverage <- wa_coverage %>% left_join(locations, by = 'site') %>% 
  mutate(lat = as.numeric(ifelse(is.na(lat.x), lat.y, lat.x)),
         lon = as.numeric(ifelse(is.na(lon.x), lon.y, lon.x))) %>% 
  select(-lat.x, -lat.y, -lon.x, -lon.y) %>% drop_na()

# Create popup.
wa_coverage <- wa_coverage %>% 
  mutate(Popup = paste0(
    '<dl><dt>School Name</dt>', 
    '<dd>', School_Name, '</dd>',
    '<dt>School_District</td>', 
    '<dd>', School_District, '</dd>',
    '<dt>K-12 Enrollment</dt>', 
    '<dd>', K_12_enrollment, '</dd>',
    '<dt>Percent Complete</dt>', 
    '<dd>', Percent_complete_for_all_immunizations, '</dd>',
    '<dt>Percent with any exemption</td>', 
    '<dd>', Percent_with_any_exemption, '</dd>'))


# Cut the continuous variable "Percent complete" into bins making factor levels.
wa_coverage$Percent_complete_fct <- 
  cut(wa_coverage$Percent_complete_for_all_immunizations, 
      c(0, 25, 50, 60, 70, 80, 85, 90, 95, 100), include.lowest = TRUE, 
      labels = c('<25', '25-50', '50-60', '60-70', '70-80', 
                 '80-85', '85-90', '90-95', '95-100'),
      ordered_result = TRUE)

# Assign a palette to this using colorFactor.
completeCol <- colorFactor(palette = colorRamp(c("red", "green3"), 
                                               interpolate = "spline"), 
                           wa_coverage$Percent_complete_fct)

# Make a map title
tag.map.title <- tags$style(HTML("
  .leaflet-control.map-title { 
                                 transform: translate(-50%,20%);
                                 position: fixed !important;
                                 left: 50%;
                                 text-align: center;
                                 padding-left: 10px; 
                                 padding-right: 10px; 
                                 background: rgba(255,255,255,0.75);
                                 font-weight: bold;
                                 font-size: 28px;
                                 }
                                 "))
title <- tags$div(
  tag.map.title, HTML(paste("Immunization Coverage Rates for Washington Schools,", 
                            "percent complete for all students, K-12"))
) 

# Make the map.
map_leaflet <- leaflet(data = wa_coverage) %>% addTiles() %>% 
  addCircleMarkers(lng = ~lon, lat = ~lat,
                   color = ~completeCol(Percent_complete_fct), 
                   popup = ~Popup,
                   radius = ~sqrt(K_12_enrollment) * .3) %>% 
  addLegend("bottomright", pal = completeCol, values = ~Percent_complete_fct,
            title = "Immunization<br>Coverage<br>Percent<br>Complete",
            opacity = 1) %>% 
  addControl(title, position = "topleft", className="map-title")

saveWidget(map_leaflet, file = "wa_immunization_coverage_leaflet_map.html")
