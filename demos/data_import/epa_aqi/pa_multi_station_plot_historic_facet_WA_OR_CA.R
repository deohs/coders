# Plot PurpleAir PM2.5 daily AQI for WA, OR, and CA on a specific day

# Load packages, installing as needed
if (! suppressPackageStartupMessages(require(pacman))) {
  install.packages('pacman', repos = 'http://cran.us.r-project.org')
}
pacman::p_load(tidyr, dplyr, AirSensor, con2aqi, ggplot2, ggthemes, stringr)

# Date to plot
plot_date <- "2020-09-08"

# Load data
setArchiveBaseUrl("http://data.mazamascience.com/PurpleAir/v1")
pas <- pas_load(datestamp = str_remove_all(plot_date, "-"))

# Filter by state and select columns of interest
pas <- pas %>% filter(stateCode %in% c('WA', 'OR', 'CA')) %>% 
  select(
    lat = "latitude", lon = "longitude", PM2.5 = "pm25_1day", 
    Type = "DEVICE_LOCATIONTYPE", 
    flag_hidden, flag_highValue, flag_attenuation_hardware
  )

# Omit flagged records
df <- pas %>% 
  mutate(Flags = flag_hidden | flag_highValue | flag_attenuation_hardware) %>% 
  filter(is.na(Flags)) %>% 
  select(-flag_hidden, -flag_highValue, -flag_attenuation_hardware, -Flags)

# Prepare data for plotting
df <- df %>% drop_na(PM2.5) %>% filter(PM2.5 < 1000) %>%
  mutate(Type = ifelse(is.na(Type), 'inside', Type)) %>%
  mutate(Type = factor(Type, labels = c('Inside', 'Outside'))) %>%
  mutate(AQI = con2aqi("pm25", PM2.5)) %>% 
  mutate(AQI = cut(AQI, ordered_result = TRUE, include.lowest = TRUE,
      breaks = c(0, 50, 100, 150, 200, 300, Inf),
      labels = c("0-50", "50-100", "100-150",
                 "150-200", "200-300", "300+")))

library(ggmap)

# Capitalize first letter of word - for use with proper nouns
# From documentation for `tolower` in package _base_ 3.1.3
capwords <- function(s, strict = FALSE) {
  cap <- function(s) paste(toupper(substring(s, 1, 1)),
                           {s <- substring(s, 2); if(strict) tolower(s) else s},
                           sep = "", collapse = " " )
  sapply(strsplit(s, split = " "), cap, USE.NAMES = !is.null(names(s)))
}

# Create vectors for shape and color of points
aqi_shapes <- c(Outside = 21, Inside = 24)
aqi_colors <- c("green", "yellow", "orange", "red", "purple", "maroon")

# Get mappings of states
state_df <- map_data('state')

# Subset just for WA, OR, and CA
woc <- subset(state_df, region %in% c("washington", "oregon", "california"))
woc$region <- sapply(woc$region, function(x) capwords(x))
woc$state <- woc$region
snames <- aggregate(cbind(long, lat) ~ region, data=woc, 
                    FUN=function(x)mean(range(x)))

# Offset the state names so they are no covered by points
snames$lat <- snames$lat - 0.2
snames$long <- snames$long + 3

# Create the base state map with counties outlined in grey
basemap <- ggplot(woc, aes(long, lat)) +
  geom_polygon(aes(group = group), color = 'darkgrey', fill = NA) +
  geom_text(
    data = snames,
    aes(long, lat, label = region),
    size = 3,
    colour = "gray30"
  ) +
  theme_classic() +
  theme(
    axis.line = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank()
  )

# Create the map
gg <- basemap + geom_point(
  data = df, aes(x = lon, y = lat, fill = AQI, 
                 alpha = AQI ),
  colour = "gray30", shape = 21, size = 1)
gg <- gg + scale_fill_manual(values = aqi_colors, drop = FALSE)
gg <- gg + scale_alpha_ordinal(range = c(0.3, 0.7), guide = FALSE)
gg <- gg + guides(
  shape = guide_legend(keyheight = 1,
                       override.aes = list(size = 2)),
  fill = guide_legend(keyheight = 1,
                      override.aes = 
        list(shape = 21, fill = aqi_colors, size = 2, alpha = 0.7)
  )
)
gg <- gg + labs(x = NULL, y = NULL, fill = "PM2.5 AQI", shape = "Sensor Type",
                title = "WA, OR, & CA Air Quality Index", 
                subtitle = paste0("US EPA PM2.5 AQI (", plot_date, ")"),
                caption = paste("Sources: PurpleAir and Mazama Science")
)
gg <- gg + theme_map(base_family = "Helvetica")
gg <- gg + theme(
  plot.title = element_text(face = "bold"),
  plot.caption = element_text(face = "italic"),
  legend.title = element_text(size = 8)
)
gg <- gg + theme(legend.position = "right",
                 plot.caption.position = "plot")
gg <- gg + theme(strip.background = 
                   element_rect(fill = "white", color = "white"))
gg <- gg + theme(strip.text = element_text(face = "bold", hjust = 0)) 
gg <- gg + facet_wrap(facets = vars(Type), nrow = 1, ncol = 2)

# View the plot
gg

# Save plot
img_dir <- "img"
if (!dir.exists(img_dir)) dir.create(img_dir, showWarnings = FALSE)
png_filename <- file.path(img_dir, 
                  paste0('pa_wa_or_ca_daily_avg_facet_', plot_date, '.png'))
ggsave(filename = png_filename, plot = gg, width = 4, height = 4)

# Resize this image for presentation using ImageMagick "convert" from Bash
resize_png_filename <- gsub('\\.png', '_30pct_resize.png', png_filename)
system2('convert', args = c('-resize "30%"', png_filename, resize_png_filename))

