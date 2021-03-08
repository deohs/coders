# PDF "scraping" examples

# ----------
# Example 1
# ----------

# Use tabulizer to extract tables from a PDF file

# Load packages
if (!require(pacman)) install.packages("pacman")
pacman::p_load(tidyr, dplyr, purrr, tabulizer)

# Prepare data folder
data_dir <- "data"
if (!dir.exists(data_dir)) {
  dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
}

# Download file
filepath <- file.path(data_dir, "RatesK12ImmandExmptbyCounty.pdf")
if (!file.exists(filepath)) {
  url <- paste0('https://www.oregon.gov/oha/PH/PREVENTIONWELLNESS/',
              'VACCINESIMMUNIZATION/Documents/RatesK12ImmandExmptbyCounty.pdf')
  download.file(url, filepath)
}

# Extract data
df <- extract_tables(file = filepath, output = "data.frame") %>%
  reduce(inner_join, by = "X") %>%
  select(-contains("X.")) %>%
  rename_with(.fn = ~gsub('^X\\d+', '', .x)) %>%
  pivot_longer(cols = -X, names_to = "County") %>%
  pivot_wider(id_cols = "County", names_from = "X") %>%
  filter(County != "Oregon") %>%
  mutate(across(.cols = -c(1:2), .fns = ~as.numeric(gsub('%', '', .x))))

# ----------
# Example 2
# ----------

# Use pdf_text() from the pdftools package

# Load packages
if (!require(pacman)) install.packages("pacman")
pacman::p_load(pdftools, data.table)

# Prepare data folder
data_dir <- "data"
if (!dir.exists(data_dir)) {
  dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
}

# Read data into a string variable with pdf_text() and fix a typo with gsub()
filepath <- file.path(data_dir, 'OM_753981True.pdf')
txt <- gsub('(\\w)(\\s{3,})', '\\1:\\2', pdf_text(filepath))

# Create a dataframe by extracting individual values with gsub()
meta_data <- data.frame(
  tax_id = gsub('^.*Tax ID: (\\d+).*$', '\\1', txt)[1],
  rpt_id = gsub('^.*ReportID: (\\d+).*$', '\\1', txt)[1],
  insp_date = gsub('^.*Inspected: ([0-9/]+).*$', '\\1', txt)[1],
  insp_type = gsub('^.*Inspection Type: ([^-]*) - .*$', '\\1', txt)[1],
  status = gsub('^.*Correction Status: ([^:\n]*).*$', '\\1', txt)[1]
)

# Create a dataframe by parsing with data:table::fread() and then cleanup names
gen_site <- fread(text = txt, skip = 'GENERAL SITE', nrows = 9, sep = ":",
                  header = FALSE, select = c('V1', 'V2'))
gen_site$V1 <- c('site', 'components', 'effluent', 'watertight', 'encroachment',
                 'settling', 'ponding', 'covered', 'maintenance')

# Combine first dataframe with second (transposed) dataframe using cbind()
df <- cbind(meta_data, transpose(gen_site, make.names = 1))

# ----------
# Example 3
# ----------

# Use a system utility (pdftotext) called with system()

# Load packages
if (!require(pacman)) install.packages("pacman")
pacman::p_load(data.table)

# Prepare data folder
data_dir <- "data"
if (!dir.exists(data_dir)) {
  dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
}

# Read file using the pdftotext shell utility and fix a typo with gsub()
filepath <- file.path(data_dir, 'OM_753981True.pdf')
txt <- system(paste("pdftotext -raw", filepath, "-"), intern = TRUE)
txt <- gsub('(adequately covered)(\\s)', '\\1:\\2', txt)

# Create a dataframe by extracting individual values with gsub()
meta_data <- data.frame(
  tax_id = gsub('^.*Tax ID: (\\d+).*$', '\\1',
                txt[grep('Tax ID:', txt)])[1],
  rpt_id = gsub('^.*ReportID: (\\d+).*$', '\\1',
                txt[grep('ReportID:', txt)])[1],
  insp_date = gsub('^.*Inspected: ([0-9/]+).*$', '\\1',
                   txt[grep('Inspected:', txt)])[1],
  insp_type = gsub('^.*Inspection Type: ([^-]*) - .*$', '\\1',
                   txt[grep('Inspection Type:', txt)])[1],
  status = gsub('^.*Status: ([^:\n]*).*$', '\\1',
                txt[grep('Status:', txt)])[1]
)

# Create a dataframe by parsing with data:table::fread() and then cleanup names
gen_site <- fread(text = txt, skip = 'GENERAL INSPECTION NOTES', nrows = 9,
                  sep = ":", header = FALSE, select = c('V1', 'V2'))
gen_site$V1 <- c('site', 'components', 'effluent', 'watertight', 'encroachment',
                 'settling', 'ponding', 'covered', 'maintenance')

# Combine first dataframe with second (transposed) dataframe using cbind()
df <- cbind(meta_data, transpose(gen_site, make.names = 1))

# ----------
# Example 4
# ----------

# Extract the Adjudications table from page 7 of the Monthly Statistics Report 
# from the National Vaccine Injury Compensation Program 
# (https://www.hrsa.gov/vaccine-compensation/data/index.html) of the US 
# Health Resources and Services Administration (https://www.hrsa.gov/). 
# Plot the results using ggplot() and geom_area().

# Load packages
if (!require(pacman)) install.packages("pacman")
pacman::p_load(dplyr, tidyr, tabulizer, ggplot2, RColorBrewer)

# Prepare data folder
data_dir <- "data"
if (!dir.exists(data_dir)) {
  dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
}

# Prepare images folder
images_dir <- "images"
if (!dir.exists(images_dir)) {
  dir.create(images_dir, showWarnings = FALSE, recursive = TRUE)
}

# Download the PDF file if not already present
pdf_filepath <- file.path(data_dir, "hrsa.pdf")
if (!file.exists(pdf_filepath)) {
  url <- paste0('https://www.hrsa.gov/sites/default/files/hrsa/', 
                'vaccine-compensation/data/data-statistics-report.pdf')
  download.file(url, pdf_filepath)
}

# Extract Adjudications table from page 7 of PDF
table_lst <- extract_tables(pdf_filepath, output = "data.frame", pages = 7)
adjudications <- table_lst[[1]]

# Clean up data: remove extra rows & symbols; convert values to numeric
adjudications <- adjudications %>% filter(Fiscal.Year != "Total") %>% 
  mutate(across(everything(), function(x){ as.numeric(gsub('\\D', '', x)) }))

# Prepare for plotting: remove extra columns & rows; reshape to long format
adjudications.long <- adjudications %>% select(-Total) %>% 
  filter(Fiscal.Year != year(Sys.Date())) %>%
  pivot_longer(cols = c(Compensable, Dismissed), 
               names_to = "Type", values_to = "Count")

# Plot the results
ggplot(adjudications.long, aes(x = Fiscal.Year, y = Count, fill = Type)) +
  scale_fill_brewer(palette = "Set2") + geom_area() + theme_classic() + 
  ggtitle(label = "US Vaccine Injury Adjudications by Fiscal Year", 
          subtitle = "Source: National Vaccine Injury Compensation Program")
ggsave(file.path(images_dir, "vaccine_adjudication.png"), height = 3, width = 6)

# ----------
# Example 5
# ----------

# Extract the Awards Paid table from pages 8-9 of the Monthly Statistics Report 
# from the National Vaccine Injury Compensation Program 
# (https://www.hrsa.gov/vaccine-compensation/data/index.html) of the US 
# Health Resources and Services Administration (https://www.hrsa.gov/). 
# Plot Total Outlays per Fiscal Year using ggplot().

# Load packages
if (!require(pacman)) install.packages("pacman")
pacman::p_load(readr, dplyr, tabulizer, ggplot2, lubridate)

# Prepare data folder
data_dir <- "data"
if (!dir.exists(data_dir)) {
  dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
}

# Prepare images folder
images_dir <- "images"
if (!dir.exists(images_dir)) {
  dir.create(images_dir, showWarnings = FALSE, recursive = TRUE)
}

# Download the PDF file if not already present
pdf_filepath <- file.path(data_dir, "hrsa.pdf")
if (!file.exists(pdf_filepath)) {
  url <- paste0('https://www.hrsa.gov/sites/default/files/hrsa/', 
                'vaccine-compensation/data/data-statistics-report.pdf')
  download.file(url, pdf_filepath)
}

# Extract lines of text from the PDF file
hrsa_lines <- read_lines(extract_text(file = pdf_filepath, pages = 8:9))

# Subset for only those lines starting with "FY "
awards_paid_lines <- grep('^FY ', hrsa_lines, value = TRUE)

# Extract the data from lines of text into a data frame
awards_paid_df <- read_delim(awards_paid_lines, delim = " ", trim_ws = TRUE, 
           col_names = c('X1', 'fiscal_year', 'num_awards', 'award_amt', 
                         'fees_paid', 'num_paid', 'fees_paid_diss', 
                         'num_paid_int', 'fees_paid_int', 'tot_outlays', 'X2'))

# Clean up data: remove extra columns, rows & symbols; convert values to numeric
awards_paid_df <- awards_paid_df %>% select(-X1, -X2) %>% 
  filter(fiscal_year != year(today())) %>%
  mutate(across(everything(), function(x){ as.numeric(gsub('\\D', '', x)) }))

# Plot the results
ggplot(awards_paid_df, aes(x = fiscal_year, y = tot_outlays/1000000000)) + 
  geom_line() + theme_classic() + 
  xlab("Fiscal Year") + ylab("Total Outlays (Billion USD)") +
  ggtitle(label = "US Vaccine Injury Awards Paid by Fiscal Year", 
          subtitle = "Source: National Vaccine Injury Compensation Program")
ggsave(file.path(images_dir, "vaccine_awards.png"), height = 3, width = 6)


# ----------
# Example 6
# ----------

# Plot Snowfall per year at Snoqualmie pass using WSDOT data.

# Load packages
if (!require(pacman)) install.packages("pacman")
pacman::p_load(data.table, tabulizer, ggplot2)

# Prepare data folder
data_dir <- "data"
if (!dir.exists(data_dir)) {
  dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
}

# Prepare images folder
images_dir <- "images"
if (!dir.exists(images_dir)) {
  dir.create(images_dir, showWarnings = FALSE, recursive = TRUE)
}

# Download file
filename <- "snoqualmie-historical-snowfall-data.pdf"
filepath <- file.path(data_dir, filename)
if (!file.exists(filepath)) {
  url <- paste0("https://www.wsdot.com/winter/files/", filename)
  download.file(url, filepath)
}

# Extract data
arg_list <- list(p1 = c(pages = 1, nrows = 43), 
                 p2 = c(pages = 2, nrows = 28))
sno <- rbindlist(lapply(arg_list, function(x) {
  dat <- read_lines(extract_text(file = filepath, pages = x['pages']))
  fread(text = dat, skip = "Season Snowfall", nrows = x['nrows'], fill = TRUE)
}))

# Clean up data
sno[, Year := as.numeric(substr(Season, 1, 4))]
sno[, Season := factor(Season, ordered = TRUE)]

# Plot the results
ggplot(sno[complete.cases(sno), ], aes(x = Year, y = Snowfall)) + 
  geom_point() +  geom_smooth(formula = "y ~ x", method = "lm") + 
  ggtitle(label = "Snowfall at Snoqualmie Pass by Year", 
          subtitle = "Source: WSDOT South Central Region") + 
  theme_classic() + ylab("Snowfall (in)")
ggsave(file.path(images_dir, "snoqualmie_snowfall.png"), height = 3, width = 6)
