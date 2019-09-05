# Plot a choropleth map of K-12 immunization coverage in Washington counties.

# Filename: wa_state_counties_k-12_immunization_status_choropleth_2018-2019.R
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
pacman::p_load(readr, dplyr, tidyr, maps, ggplot2)

# Get K-12 immunization coverage by county for Washington State.
# See: https://www.doh.wa.gov/DataandStatisticalReports/HealthDataVisualization/SchoolImmunization/CountySchoolImmunization
data_fn <-'wa_state_counties_k-12_immunization_status_data_2018-2019.csv'
wa_coverage <- read_csv(data_fn) %>% 
  filter(State == "Washington") %>% 
  select(county = Name, Measure, Percent) %>% 
  spread(key = Measure, value = Percent) %>% 
  mutate_at(.vars = c('Complete', 'Exempt'), 
            .funs = ~as.numeric(sub('%', '', .)))

# Convert immunization percent complete variable to a factor with 5 bins.
wa_coverage$Complete_fct <- factor(
  cut(x = wa_coverage$Complete, 
      breaks = c(0, 75, 85, 90, 95, 100), 
      labels = c("<75%", "75%-85%", "85%-90%", "90%-95%", "95%-100%"),
      ordered_result = TRUE))

# Get Washington counties.
counties <- map_data("county")
wa_county <- subset(counties, region == 'washington') %>%
  mutate(county = tools::toTitleCase(subregion)) %>% 
  select(long, lat, county, group) %>% 
  left_join(wa_coverage, by = 'county')

# Create dataframe for county labels.
county_names <- wa_county %>% 
  mutate(county = paste0(county, '\n', Complete, '%')) %>% group_by(county) %>% 
  summarise_at(.vars = c('long', 'lat'), .funs = ~ mean(range(.)))

# Plot map.
ggplot() +
  geom_polygon(data = wa_county, 
               aes(x = long, y = lat, group = group, fill = Complete_fct),
               color = "gray50", size = 0.3, alpha = 0.4) + coord_quickmap() +
  scale_fill_brewer(palette = "YlOrRd", na.value = "grey70", direction = -1) + 
  geom_text(data = county_names, aes(long, lat, label = county),
            size = 1.25, color = "gray10") +
  theme_void() +
  labs(x = NULL, y = NULL, fill = NULL,
       title = "School Immunization Coverage in Washington Counties",
       subtitle = "Percent complete for all students, K-12, SY 2018-2019",
       caption = paste("Source: School Immunization Dashboards,", 
                       "Washington State Department of Health")
  ) + theme(plot.caption = element_text(face = "italic", size = 7))

# Save the map as a PNG file.
image_fn <- "wa_county_immunization_choropleth_map.png"
ggsave(filename = image_fn, width = 5, height = 3, units = "in")

