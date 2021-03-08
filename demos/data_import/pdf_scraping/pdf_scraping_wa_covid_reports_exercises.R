# PDF "scraping" exercises: WA DOH Covid-19 data

# See: https://www.doh.wa.gov/Emergencies/COVID19/DataDashboard#downloads

# Load packages
if (!require(pacman)) install.packages("pacman")
pacman::p_load(readr, dplyr, tidyr, purrr, tabulizer, ggplot2, RColorBrewer)

# Prepare data folder
data_dir <- "data"
if (!dir.exists(data_dir)) {
  dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
}

# ----------
# Example 1
# ----------

# Extract tables as a list of data.frames

# Download file
filename <- "Weekly-COVID-19-Long-Term-Care-Report.pdf"
filepath <- file.path(data_dir, filename)
if (!file.exists(filepath)) {
  url <- paste0('https://www.doh.wa.gov/Portals/1/Documents/1600/coronavirus/',
                'data-tables/', filename)
  download.file(url, filepath)
}

# Extract table from pages 4-5 and clean up so it's all in one data frame
df_list <- extract_tables(...)

# Cleanup data
df <- # ...

# names(df)
# [1] "County"                                           
# [2] "Total.LTC.Associated.and.Likely.Associated.Deaths"
# [3] "Total.LTC.Associated.and.Likely.Associated.Cases" 

# dim(df)
# [1] 36  3

# sapply(df, class)
# County 
# "character" 
# Total.LTC.Associated.and.Likely.Associated.Deaths 
# "numeric" 
# Total.LTC.Associated.and.Likely.Associated.Cases 
# "numeric"

# ----------
# Example 2
# ----------

# Extract table as text then convert to data.frames

# Download file
filename <- "348-791-COVID19VaccinationCoverageRaceEthnicityAgeWAState.pdf"
filepath <- file.path(data_dir, filename)
if (!file.exists(filepath)) {
  url <- paste0('https://www.doh.wa.gov/Portals/1/Documents/1600/coronavirus/',
                'data-tables/', filename)
  download.file(url, filepath)
}

# Extract text from page 12 as a string
# txt <- extract_text(...)

# Parse text into data frames and clean up
lines <- read_lines(txt)
init_vac <-  # ...
full_vac <-  # ...

# init_vac
#   A tibble: 5 x 2
#     age    pct_init
#    <chr>    <dbl>
#  1 0-19       0.2
#  2 20-34      6  
#  3 35-49      8.4
#  4 50-64     10.7
#  5 65+       30  

# full_vac
# A tibble: 5 x 2
#     age   pct_full
#    <chr>     <dbl>
#  1 0-19       0.1
#  2 20-34      3  
#  3 35-49      4.4
#  4 50-64      3.9
#  5 65+        2.3


# Merge data frames and reshape
df <- inner_join(init_vac, full_vac, by = "age") %>%
  pivot_longer(cols = where(is.numeric), names_prefix = "pct_", 
               names_to = "type", values_to = "pct") %>% 
  mutate(type = factor(type, levels = c('init', 'full'), 
    labels = c('Percent Initiating Within Age Group', 
               'Percent Fully Vaccinated Within Age Group')))

# Create custom color palette (lavender, purple, light gray)
my_pal <- c("#C8C8FF", "#7D00AF", "#E1E1E1")

# Plot data
ggplot(df, aes(x = age, y = pct, fill = type)) + 
  geom_bar(width = 0.6, stat = "identity",
           position =  position_dodge(width = 0.7, preserve = "total")) + 
  geom_text(aes(label = sprintf("%0.1f%s", round(pct, digits = 1), "%")), 
            vjust = -0.5, position =  position_dodge(width = 0.7), size = 3.2) + 
  scale_fill_manual(values = my_pal) +
  labs(title = "Figure 3: Percent Vaccinated, By Age", 
       x = "Age Group", y = "Percent") + 
  theme_void() + 
  theme(legend.title = element_blank(), legend.position = c(0.23, 0.6),
        plot.title = element_text(hjust = 0.5), axis.text.x = element_text())

# Prepare images folder
images_dir <- "images"
if (!dir.exists(images_dir)) {
  dir.create(images_dir, showWarnings = FALSE, recursive = TRUE)
}

# Save plot
ggsave(file.path(images_dir, "percent_vaccinated.png"), height = 4, width = 6)

# ----------
# Example 3
# ----------

# Extract a table by area (Non-reproducible: requires user interaction)

# Download file
filename <- "MultisystemInflammatorySyndromeChildrenCOVID19WA2020.pdf"
filepath <- file.path(data_dir, filename)
if (!file.exists(filepath)) {
  url <- paste0('https://www.doh.wa.gov/Portals/1/Documents/1600/coronavirus/',
                filename)
  download.file(url, filepath)
}

# locate_area() will present an interactive selection tool to draw a box
# around the table you wish to extract and return a list containing a vector.

# area <- locate_areas(file = filepath, pages = 6)
# area
# [[1]]
#       top      left    bottom     right 
# 223.22188  68.71747 548.20669 415.60767

# The vector contains the coordinates for the box corners. This output can be
# used with extract_tables().

# The same interactive tool can be used to extract a table by area.

# Extract table on page 6 into a data.frame by area using extract_areas()
# df <- extract_areas(...)

# df
# County.in.Washington    Number.of.reported.cases.of.MIS.C
# 1                Chelan                                 1
# 2               Douglas                                 1
# 3              Franklin                                 2
# 4                  King                                12
# 5                Kitsap                                 2
# 6                 Lewis                                 2
# 7                 Mason                                 1
# 8                Pierce                                 4
# 9                Skagit                                 2
# 10            Snohomish                                 5
# 11              Spokane                                 1
# 12               Yakima                                 6
# 13                Total                                39

