# Make a map of the immunization coverage rates for Washington schools for 
# all students K-12 for the 2018-2019 school year using the leaflet package.
#
# See:
# https://www.doh.wa.gov/CommunityandEnvironment/Schools/Immunization/ExemptionLawChange
# https://www.doh.wa.gov/DataandStatisticalReports/HealthDataVisualization/SchoolImmunization
#
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
pacman::p_load(dplyr, tidyr, readr, leaflet, htmlwidgets, htmltools)

# Get data.
# Data file downloaded as CSV export from:
# https://www.doh.wa.gov/DataandStatisticalReports/HealthDataVisualization/SchoolImmunization/SchoolBuildingImmunization
data_fn <- 'wa_state_schools_k-12_immunization_status_data_2018-2019.csv'
wa_coverage <- read_csv(data_fn)

wa_coverage <- wa_coverage %>% 
  rename('lat' = 'Latitude', 'lon' = 'Longitude') %>% 
  select(`School Name`, `School District`, Enrollment, Percent, lat, lon) %>%
  mutate(Percent = as.numeric(gsub('%', '', Percent))) %>% drop_na() %>% 
  filter(Enrollment > 0)

# Create popup.
wa_coverage <- wa_coverage %>% 
  mutate(Popup = paste0(
    '<dl><dt>School Name</dt>', 
    '<dd>', `School Name`, '</dd>',
    '<dt>School_District</td>', 
    '<dd>', `School District`, '</dd>',
    '<dt>K-12 Enrollment</dt>', 
    '<dd>', Enrollment, '</dd>',
    '<dt>Percent Complete</dt>', 
    '<dd>', Percent, '</dd>', '</dl>'))

# Cut the continuous variable "Percent complete" into bins making factor levels.
wa_coverage$Percent_complete_fct <- 
  cut(wa_coverage$Percent, 
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
                                 font-size: 20px;
                                 }
                                 "))
title <- tags$div(
  tag.map.title, HTML(paste("Immunization Coverage Rates for Washington Schools,<br>", 
                            "Percent Complete for All Students, K-12, SY 2018-2019"))
) 

# Make the map.
map_leaflet <- leaflet(data = wa_coverage) %>% addTiles() %>% 
  addCircleMarkers(lng = ~lon, lat = ~lat,
                   color = ~completeCol(Percent_complete_fct), 
                   popup = ~Popup,
                   radius = ~sqrt(Enrollment) * .3) %>% 
  addLegend("bottomright", pal = completeCol, values = ~Percent_complete_fct,
            title = "Immunization<br>Coverage<br>Percent<br>Complete",
            opacity = 1) %>% 
  addControl(title, position = "topleft", className="map-title")

saveWidget(map_leaflet, file = "wa_immunization_coverage_leaflet_map.html")
