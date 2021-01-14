# Find articles in Pubmed authored by UW SPH Core Faculty

# Load packages, installing as needed
if (!require("pacman")) install.packages("pacman")
pacman::p_load(rvest, readr, dplyr, tidyr, purrr, easyPubMed)

# Setup data folder
data_dir <- "data"
if(!dir.exists(data_dir)) {
  dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
}

# Get a list of core faculty from the UW SPH website
url <- 'https://sph.washington.edu/faculty/sphcore'
doc <- read_html(url)
nodes <- doc %>% html_nodes("div.faculty-tile-text-wrap")
names <- nodes %>% html_node("h3") %>% html_text()
titles <- doc %>% html_nodes("p.fac-title") %>% html_text()
degrees <- doc %>% html_nodes("p.fac-deg") %>% html_text()
df <- tibble(fac_name = names, fac_title = titles, fac_degree = degrees) %>%
  mutate(fac_name = gsub(' \\/.*$', '', fac_name))

# Query Pubmed for articles with SPH core faculty members as authors
pm_df <- df %>% 
  pull(fac_name) %>% 
  lapply(function(aut) { 
    paste0(aut, "[Author]") %>%
      get_pubmed_ids() %>% 
      fetch_pubmed_data(encoding = "ASCII") %>% 
      articles_to_list() %>% 
      map(article_to_df, getAuthors = FALSE) %>% 
      bind_rows() %>% mutate(fac_name = aut) %>%
      select(-keywords, -lastname, -firstname, -address, -email)
  }) %>% 
  bind_rows() %>% left_join(df, by = "fac_name") %>%
  separate(fac_name, c('fac_lname', 'fac_fname'), ", ", extra = "merge")

# Save results
write_csv(pm_df, file.path(data_dir, "sph_core_faculty_pubmed_search_results.csv"))