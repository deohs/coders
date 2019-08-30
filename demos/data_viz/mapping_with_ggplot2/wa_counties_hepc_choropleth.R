# Create a choropleth map of Chronic Hepatitus-C for Wash. counties in 2017.

# Filename: wa_counties_hepc_choropleth.R
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
pacman::p_load(tabulizer, dplyr, maps, ggplot2)

# Get Chronic Hepatitis-C data for Washington counties in 2017 from WA DOH.
# Note: '*' in the Rate column will be converted to NA in the data frame.
url <- paste0('https://www.doh.wa.gov/Portals/1/Documents/5100/', 
              '420-004-CDAnnualReportIncidenceRates.pdf')
wa_hepc_chronic <- extract_tables(file = url, pages = 24) %>% 
  as.data.frame() %>% .[3:41, c(1, 10, 11)] %>% 
  mutate(X1 = as.character(X1), 
         X11 = suppressWarnings(as.numeric(as.character(X11))),
         X11 = ifelse(is.na(X11), 0, X11))
names(wa_hepc_chronic) <- c('county', 'cases', 'rate')

# Get Washington counties.
counties <- map_data("county")
wa_county <- subset(counties, region == 'washington') %>%
  mutate(county = tools::toTitleCase(subregion)) %>% 
  select(long, lat, county, group) %>% 
  left_join(wa_hepc_chronic, by = 'county')

# Convert incidence rate variable to a factor with 6 bins.
wa_county$rate <- factor(
  cut(x = wa_county$rate, 
      breaks = c(0, 50, 100, 150, 200, 250, Inf), 
      labels = c("<50", "50-100", "100-150", "150-200", "200-250", "250+"),
      ordered_result = TRUE
  )
)

# Create dataframe for county labels.
county_names <- wa_county %>% group_by(county) %>% 
  summarise_at(.vars = c('long', 'lat'), .funs = ~ mean(range(.)))

# Plot map.
ggplot() +
  geom_polygon(data = wa_county, 
               aes(x = long, y = lat, group = group, fill = rate),
               color = "gray20", size = 0.3, alpha = 0.4) + coord_quickmap() +
  geom_text(data = county_names, aes(long, lat, label = county),
            size = 2.5, color = "gray10") + 
  scale_fill_brewer(palette = "YlOrRd", na.value = "grey70") + 
  labs(x = NULL, y = NULL, fill = 'Incidence rate \nper 100,000',
       title = paste("Chronic Hepatitus-C Incidence Rate", 
                     "for Washington Counties in 2017"),
       subtitle = paste("Rates are cases per 100,000 population.", 
                        "Rates not calculated for <5 cases.", 
                        "NA means Not Available."),
       caption = paste("Source: Washington State Communicable Disease Report", 
                       "2017 \nDOH 420-004 10/2018,", 
                       "Washington State Department of Health")
  ) + theme_void() + theme(plot.caption = element_text(face = "italic"))

