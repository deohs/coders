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
# from the National Vaccine Injury Compensation Program of the US 
# Health Resources and Services Administration (https://www.hrsa.gov/). 
# Plot the results using ggplot() and geom_area().

# Load packages
if (!require(pacman)) install.packages("pacman")
pacman::p_load(dplyr, tidyr, tabulizer, ggplot2, RColorBrewer)

# Extract Adjudications table (#5), remove Total row, and convert to numeric
url <- paste0('https://www.hrsa.gov/sites/default/files/hrsa/', 
              'vaccine-compensation/data/data-statistics-report.pdf')
lst <- extract_tables(url, output = "data.frame")
adjudications <- lst[[5]]
adjudications <- adjudications %>% filter(Fiscal.Year != "Total") %>% 
  mutate(across(everything(), function(x){ as.numeric(gsub('\\D', '', x)) }))

# Prepare for plotting
adjudications.long <- adjudications %>% select(-Total) %>% 
  pivot_longer(cols = c(Compensable, Dismissed), 
               names_to = "Type", values_to = "Count")

# Plot the results
ggplot(adjudications.long, aes(x = Fiscal.Year, y = Count, fill = Type)) +
  scale_fill_brewer(palette = "Set2") + geom_area() + theme_classic() + 
  ggtitle(label = "US Vaccine Adjudications by Fiscal Year", 
          subtitle = "Source: National Vaccine Injury Compensation Program")
ggsave(file.path("images", "vaccine_adjudication.png"), height = 3, width = 6)
