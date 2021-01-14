# Get a list of UW SPH Core Faculty from the school's website

library(rvest)

url <- 'https://sph.washington.edu/faculty/sphcore'
doc <- read_html(url)
nodes <- doc %>% html_nodes("div.faculty-tile-text-wrap")
names <- nodes %>% html_node("h3") %>% html_text()
titles <- doc %>% html_nodes("p.fac-title") %>% html_text()
degrees <- doc %>% html_nodes("p.fac-deg") %>% html_text()
df <- tibble(fac_name = names, fac_title = titles, fac_degree = degrees)
df


# Get PubMed articles for each faculty member.

library(readr)
library(dplyr)
library(purrr)
library(easyPubMed)

# Define function to retrieve results from a Pubmed search
get_articles <- function(aut) {
  # Retrieve PubMed data and return a list of articles
  my_query <- paste0(aut, "[Author]")
  my_query <- get_pubmed_ids(pubmed_query_string = my_query)
  my_data <- fetch_pubmed_data(my_query, encoding = "ASCII")
  articles_to_list(my_data)
}

# Setup data folder
data_dir <- "data"
if(!dir.exists(data_dir)) {
  dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
}

# Query Pubmed for articles with SPH core faculty members as authors
df <- df %>% mutate(fac_name = gsub(' \\/.*$', '', fac_name))
pm_df <- lapply(df$fac_name, function(aut) { 
    map(get_articles(aut), article_to_df, getAuthors = FALSE) %>% 
    bind_rows() %>% mutate(fac_name = aut) %>%
    select(-keywords, -lastname, -firstname, -address, -email)
}) %>% 
  bind_rows() %>% left_join(df, by = "fac_name") %>%
  separate(fac_name, c('fac_lname', 'fac_fname'), ", ", extra = "merge")

# Save results
write_csv(pm_df, file.path("data", "sph_core_faculty_pubmed_search_results.csv"))
