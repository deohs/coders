# PDF "scraping" examples: WA DOH Covid-19 data

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

# Extract data
df <- extract_tables(file = filepath, output = "data.frame")[[1]][c(1, 4:15),]

# Cleanup data
names(df) <- c('county', 'deaths', 'cases')
df <- df[-1, ] %>% mutate(across(2:3, ~as.numeric(gsub(',', '', .))))

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

# Extract data as text
txt <- extract_text(file = filepath, pages = 12)

# Parse text into data frames and clean up
lines <- read_lines(txt)
init_vac <- 
  read_delim(lines[21:25], delim = " ", 
    col_names = c('age', 'count_init', 'tot_pop', 'pct_init', 'X')) %>%
  select(age, pct_init) %>% 
  mutate(pct_init = as.numeric(gsub('%', '', pct_init)))
full_vac <- 
  read_delim(lines[42:46], delim = " ", 
    col_names = c('age', 'count_full', 'tot_pop', 'pct_full', 'X')) %>%
  select(age, pct_full) %>% 
  mutate(pct_full = as.numeric(gsub('%', '', pct_full)))

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

# Extract data by area
df <- extract_areas(file = filepath, pages = 6, output = "data.frame")[[1]]



