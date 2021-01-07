################################################################################
#                                                                              #
#               DEOHS Coders Group: Data Analysis Tutorial                     #
#                                                                              #
#                PM 2.5 Chemical Speciation Network                            #
#                                                                              #
# by: Chris Zuidema                                                            #
#                                                                              #
################################################################################

# This script serves as an example of basic data analysis workflow. It covers 
# the following steps: 
#   1. load needed packages 
#   2. organize files/directories 
#   3. read in data 
#   4. examine data structure and attributes 
#   5. clean, tidy, and wrangle 
#   6. exploratory data analysis 
#   7. statistical analysis 
#   8. data visualization 



## STEP 1: load packages as needed with pacman
if(!require(pacman)) {install.packages("pacman")}
pacman::p_load(dplyr, readr, stringr, lubridate, tidyr, ggplot2)


## STEP 2: organize directories
# specify working directory
work_dir <- getwd()

# specify and create data directory (if needed)
data_dir <- file.path(work_dir, "data")
dir.create(data_dir, showWarnings = TRUE, recursive = TRUE)

# specify and create output directory (if needed)
output_dir <- file.path(work_dir, "output")
dir.create(output_dir, showWarnings = TRUE, recursive = TRUE)


## STEP 3: read in data
# EPA's interactive AirData Website URL: https://epa.maps.arcgis.com/apps/webappviewer/index.html?id=5f239fd3e72f424f98ef3d5def547eb5&extent=-146.2334,13.1913,-46.3896,56.5319
# you can explore this website and identify the URL of the dataset of interest.

# for this example, we'll use the URL for the 2019 Duwamish Monitor Data
url <- "https://www3.epa.gov/cgi-bin/broker?_service=data&_program=dataprog.Daily.sas&check=site&debug=0&year=2019&site=53-033-0057"

# option 1: use readr function `read_csv()` to load the .csv file from the web
#all_data <- read_csv(url)

# option 2: download file locally; then read in
# first, specify the name of the .csv file
file_name <- file.path(data_dir, "daily_53_033_0057_2019.csv")

# download the .csv file if it does not already exist locally
if(!file.exists(file_name)) {download.file(url, file_name)} 

# use readr function `read_csv()` to load read and load the .csv file
all_data <- read_csv(file_name)

# remove temporary variables
rm(file_name, url)


## STEP 4: Examine data attributes 
# look at the first several rows of the dataframe
all_data

# look at the data structure. We can see important features, like data classes.
# what are the classes of important variabes you see? (i.e. Site Number, Latitude, 
# Parameter Name, Date)
str(all_data)

# what are the dimiensions of the dataframe? 
dims <- dim(all_data)
dims

# are there any missing values? Let's look at `Pollutant Standard` as an example.
miss <- sum(is.na(all_data$`Pollutant Standard`))
miss

# how much missingness is that? the NAs in this variable aren't too concerning, 
# since the NAs appear for lines without a regulatory standard for the 
# corresponding `Parameter Name` but you can imagine how problematic missing 
# data are. this tells us most of the data here do not have regulatory standards.
miss/dims[1]*100

# what types of pollutant measurements are contained in the dataset?
polls <- unique(all_data$`Parameter Name`)
polls

# remove temporary variables
rm(dims, miss)


## STEP 5: Clean,Tidy & Wrangle Data

# select varibles of interest to make data more manageable; rename for convenience
df <- select(all_data, 
        date = `Date (Local)`,
        day_in_year = `Day In Year (Local)`,
        year = Year,
        value = `Arithmetic Mean`, 
        poll = `Parameter Name`, 
        units = `Units of Measure`,
        AQI)
df

# replace the "." in AQI with NA using `mutate()` and `na_if()`
df <- mutate(df, AQI = na_if(all_data$AQI, ".") )
df

# say we're interested in heavy metals, so lets identify heavy metal measurements. 
# first, make a character vector containing metals of interest
metals <- c("Arsenic", "Cadmium", "Cobalt", "Chromium", "Nickel", "Lead")

# next, subset `polls` from earlier creating a string that can be interpreted by 
# `stringr` functions 
filter_txt <- str_subset(polls, pattern = paste(metals, collapse = "|"))

# next, subset the dataframe to the rows of interest 
df <- filter(df, poll %in% filter_txt)
df

# it turns out we don't need AQI. It's all NA because AQI isn't based on heavy 
# metal concentration. We'll use the `select()` function with a "-". think of it 
# like "deselecting"
df <- select(df, -AQI)
df

# change the units because it's a little unwieldy right now
df <- mutate(df, units = "ug/m3")
df

# change the pollutant variable to be more coder-friendly
df <- mutate(df, poll = str_remove(string = poll, pattern = " PM2.5 (LC)"))
df

# change the pollutant variable to be a factor
df <- mutate(df, poll = factor(poll))
df

# change the day_in_year to numeric
df <- mutate(df, day_in_year = as.integer(day_in_year))
df

# add a month column using lubridate function
df <- mutate(df, month = month(date, label = TRUE))
df

# change year to integer too
df <- mutate(df, year = as.integer(year))
df


# The dataframe looks great now, but we can also clearly and efficiently 
# implement all of these operations into a single "pipeline." This extra step, 
# of reviewing our code to keep required steps, clarify and efficiency execute 
# operations is very important. 

# lets' remove the old relevant variables so we can start "fresh."
rm(df, metals, filter_txt)

# we first specify the external variables needed. 
metals <- c("Arsenic", "Cadmium", "Cobalt", "Chromium", "Nickel", "Lead")
filter_txt <- str_subset(polls, pattern = paste(metals, collapse = "|"))

# create dataframe from `all_data`
df <- all_data %>% 
  
  # select varibles of interest; rename for convenience
  select(date = `Date (Local)`,
         day_in_year = `Day In Year (Local)`,
         year = Year,
         value = `Arithmetic Mean`, 
         poll = `Parameter Name`, 
         units = `Units of Measure`) %>% 
  
  # subset the dataframe to the rows of interest using `filter()`
  filter(poll %in% filter_txt) %>% 
  
  # use mutate to modify the dataframe: 
  #   change units to be more manageable
  #   remove extra info from pollutant variable
  #   change pollutant to factor
  #   change day_in_year to numeric/integer
  #   add column for months
  #   change year to integer
  
  mutate(units = "ug/m3", 
         poll = str_remove(string = poll, pattern = " PM2.5 (LC)"), 
         poll = factor(poll), 
         day_in_year = as.integer(day_in_year),
         month = month(date, label = TRUE),
         year = as.integer(year)) 

df

# remove temporary variables (we might want "metals" later)
rm(filter_txt)


## STEP 6: Exploratory Data Analysis

# group by pollutant and calculate summary statistics
annual_summary <- df %>% 
  group_by(poll) %>% 
  summarise (annual_avg = mean(value), 
             sd = sd(value))

# does pollutant concentration vary by month?
monthly_summary <- df %>% 
  
  # create month variable, using lubridate function
  mutate(month = month(date, label = TRUE)) %>% 
  
  # group_by month and pollutant
  group_by(poll, month) %>% 
  
  # calculate monthly averages for each metal
  summarise(month_avg = mean(value))

# This data is currently in what is call "long' format. For what we're doing, 
# this is a little hard to read. Let's change it to "long" format using 
# the tidyr function `pivot_wider()`
monthly_summary <- monthly_summary %>% 
  pivot_wider(names_from = month, values_from = month_avg)
  

## STEP 7: Statistical Analysis

# In Coders Group, we will show statistical approaches to demonstrate 
# implementation of common methods, but these should be considered examples only. 
# Instruction on the theory, appropriateness and interpretation of statistical 
# methods should come from coursework through the BIOSTATS department. 


# Using Lead as an example, let's examine if there is a statistically 
# significant difference between September and January measurements using the 
# `t.test()` function. 

# first, we'll make a Pb dataset for the `t.test()` function.
Pb <- df %>% 
  filter(poll == "Lead", 
         month == "Jan"| month == "Sep") %>% 
  pivot_wider(names_from = month, values_from = value)
Pb

# next, we'll run the t-test
t_test <- t.test(Pb$Jan, Pb$Sep)
t_test

## STEP 8: Data Visualization

# plot a timeseries of metals concentration using ggplot
p <- ggplot(data = df, aes(x = date, y = value, color = poll)) +
  
  # specify the geometry of interest
  geom_line() + 
  
  # add labels
  labs(x = "Date",
       y = "Concentration (ug/m3)", 
       color = "Metal", 
       title = "EPA Chemical Speciation Network, Duwamish Monitor") + 
  
  # choose a theme
  theme_bw() + 
  
  # choose new color palette
  scale_color_brewer(palette="Dark2") +
  
  # move legend
  theme(legend.position = "bottom")
  
  
# show plot
p


# save figure
ggsave(filename = file.path(output_dir, "chemical_spec_network.png"), plot = p, 
       width = 8, height = 6, units = "in", dpi = "print")
