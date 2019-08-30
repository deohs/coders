# Create a choropleth map of Heart Disease Mortality for Washington State by 
# county for adults (aged 35 and older).
#
# Filename: wa_county_heart_choropleth.R
# Copyright (c) University of Washington
# License: MIT https://opensource.org/licenses/MIT (See LICENSE file.)
# Repository: https://github.com/deohs/coders
#
# Heart Disease Mortality Data Among US Adults (35+) by State/Territory and County
#
# 2014 to 2016, 3-year average. Rates are age-standardized. County rates are
# spatially smoothed. The data can be viewed by gender and race/ethnicity. Data
# source: National Vital Statistics System. Additional data, maps, and
# methodology can be viewed on the Interactive Atlas of Heart Disease and Stroke
# http://www.cdc.gov/dhdsp/maps/atlas. https://chronicdata.cdc.gov/
#
# See: https://www.cdc.gov/dhdsp/maps/hds-widget.htm
# And: https://nccd.cdc.gov/DHDSPAtlas/Default.aspx?state=WA

pacman::p_load(readr, dplyr, maps, ggplot2)

# Get data.
url <- 'https://chronicdata.cdc.gov/api/views/48mw-5apu/rows.csv?accessType=DOWNLOAD'
df <- read_csv(url)
wa_heart <- df %>% 
    filter(LocationAbbr == 'WA', GeographicLevel == 'County', Year == 2015,
           Stratification2 == 'Overall') %>% 
    select(county = LocationDesc, 
           rate = Data_Value, 
           gender = Stratification1) %>% 
    mutate(county = gsub(' County', '', county))

# Get Washington counties.
counties <- map_data("county")
wa_county <- subset(counties, region == 'washington') %>%
    mutate(county = tools::toTitleCase(subregion)) %>% 
    select(long, lat, county, group) %>% 
    left_join(wa_heart, by = 'county')

# Create dataframe for county labels.
county_names <- wa_county %>% group_by(county) %>% 
  summarise_at(.vars = c('long', 'lat'), .funs = ~ mean(range(.)))

# Plot map with facets for Male and Female.
ggplot() + 
  geom_polygon(data = wa_county %>% filter(gender == "Overall"), 
               aes(x = long, y = lat, group = group, fill = rate),
               color = "gray20", size = 0.3) + 
  coord_quickmap() +  
  scale_fill_gradient(low='beige', high='lightcoral') +
  geom_text(data = county_names, aes(long, lat, label = county),
            size = 2.5, color = "gray10") +
  labs(x = NULL, y = NULL, fill = 'Heart Disease \nMortality per \n100,000',
       title = paste("Adult Heart Disease Mortality Rate", 
                     "in Washington Counties"),
       subtitle = paste("Three-year average as of 2015. Rates are", 
                        "age-standardized and spatially smoothed."), 
       caption = paste(
         "Source: Heart Disease Mortality Data Among US Adults (35+)", 
         "by State/Territory and County, CDC"
       )
  ) + theme_void() + theme(plot.caption = element_text(face = "italic"))

# Plot map with facets for Male and Female.
ggplot() + 
  geom_polygon(data = wa_county %>% filter(gender %in% c("Male", "Female")), 
               aes(x = long, y = lat, group = group, fill = rate),
               color = "gray20", size = 0.3) + 
  coord_quickmap() + facet_grid(. ~ gender) + 
  scale_fill_gradient(low='beige', high='lightcoral') +
  geom_text(data = county_names, aes(long, lat, label = county),
            size = 2, color = "gray10") +
  labs(x = NULL, y = NULL, fill = 'Heart Disease \nMortality per \n100,000',
       title = paste("Adult Heart Disease Mortality Rate by Gender", 
                     "in Washington Counties"),
       subtitle = paste("Three-year average as of 2015. Rates are", 
                        "age-standardized and spatially smoothed."), 
       caption = paste(
           "Source: Heart Disease Mortality Data Among US Adults (35+)", 
           "by State/Territory and County, CDC"
       )
  ) + theme_void() + theme(plot.caption = element_text(face = "italic"))

# Convert incidence rate variable to a factor with 5 bins.
wa_county$rate_fct <- factor(
  cut(x = wa_county$rate, 
      breaks = c(0, 100, 200, 300, 400, Inf), 
      labels = c("<100", "100-200", "200-300", "300-400", "400+"),
      ordered_result = TRUE
  )
)

# Plot map with discrete color gradient.
ggplot() +
  geom_polygon(data = wa_county %>% filter(gender %in% c("Male", "Female")), 
               aes(x = long, y = lat, group = group, fill = rate_fct),
               color = "gray20", size = 0.3, alpha = 0.4) + 
  coord_quickmap() + facet_grid(. ~ gender) + 
  scale_fill_brewer(palette = "YlOrRd", na.value = "grey70") +
  geom_text(data = county_names, aes(long, lat, label = county),
            size = 2, color = "gray10") +
  labs(x = NULL, y = NULL, fill = 'Heart Disease \nMortality per \n100,000',
       title = paste("Adult Heart Disease Mortality Rate by Gender", 
                     "in Washington Counties"),
       subtitle = paste("Three-year average as of 2015. Rates are", 
                        "age-standardized and spatially smoothed."), 
       caption = paste(
         "Source: Heart Disease Mortality Data Among US Adults (35+)", 
         "by State/Territory and County, CDC"
       )
  ) + theme_void() + theme(plot.caption = element_text(face = "italic"))
