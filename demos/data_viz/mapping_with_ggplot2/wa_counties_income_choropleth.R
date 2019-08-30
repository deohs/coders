# Plot a choropleth map of per-capita income of Washington State counties.

# Filename: wa_counties_income_choropleth.R
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
pacman::p_load(rvest, dplyr, tidyr, maps, ggplot2)

# Get per-capita income by county for Washington State.
url <-
  'https://en.wikipedia.org/wiki/List_of_Washington_locations_by_per_capita_income'
wa_income <- read_html(url) %>%
  html_nodes(xpath = "//div/table[3]") %>% html_table(fill = TRUE) %>%
  as.data.frame() %>% drop_na(Rank) %>%
  select(county = County, income = Per.capitaincome) %>%
  mutate(income = as.numeric(gsub('[$,]', '', income)))

# Get Washington counties.
counties <- map_data("county")
wa_county <- subset(counties, region == 'washington') %>%
  mutate(county = tools::toTitleCase(subregion)) %>% 
  select(long, lat, county, group) %>% 
  left_join(wa_income, by = 'county')

# Convert income variable to a factor with 5 bins.
wa_county$income <- factor(
  cut(x = wa_county$income / 1000, 
      breaks = c(0, 20, 25, 30, 35, Inf), 
      labels = c(
        "Under $20K",
        "$20K to $25K",
        "$25K to $30K",
        "$30K to $35K",
        "Over $35K"
        ),
      ordered_result = TRUE
      )
  )

# Create dataframe for county labels.
county_names <- wa_county %>% group_by(county) %>% 
  summarise_at(.vars = c('long', 'lat'), .funs = ~ mean(range(.)))

# Plot map.
ggplot() +
  geom_polygon(data = wa_county, 
               aes(x = long, y = lat, group = group, fill = income),
    color = "gray20", size = 0.3, alpha = 0.4) + coord_quickmap() +
  scale_fill_brewer(palette = "YlOrRd", na.value = "grey70") + 
  geom_text(data = county_names, aes(long, lat, label = county),
            size = 2.5, color = "gray10") +
  theme_void() +
  labs(x = NULL, y = NULL, fill = NULL,
    title = "Per-Capita Income by County in Washington State",
    caption = paste(
      "Source: 2010 U.S. Census",
      "and the 2006-2010 American Community Survey",
      "5-Year Estimates (Wikipedia, 2019)"
    )
  ) + theme(plot.caption = element_text(face = "italic"))

