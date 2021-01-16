# Find articles in Pubmed authored by UW SPH Core Faculty and make plots

# Load packages, installing as needed
if (!require("pacman")) install.packages("pacman")
pacman::p_load(jsonlite, rvest, readr, dplyr, tidyr, purrr, easyPubMed, ggplot2)

# Setup data folder
data_dir <- "data"
if(!dir.exists(data_dir)) {
  dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
}

# Setup figures folder
fig_dir <- "figures"
if(!dir.exists(fig_dir)) {
  dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
}

# Define functions

get_sph_faculty <- function(n = 1) {
  url <- paste0("https://sph.washington.edu/faculty/sphcore/", n, 
                "?_wrapper_format=drupal_ajax")
  doc <- read_json(url)[[1]][['data']]
  if (doc != "") {
    doc <- read_html(doc)
    nodes <- doc %>% html_nodes("div.faculty-tile-text-wrap")
    names <- nodes %>% html_node("h3") %>% html_text()
    titles <- nodes %>% html_node("p.fac-title") %>% html_text()
    degrees <- nodes %>% html_node("p.fac-deg") %>% html_text()
    tibble(fac_name = names, fac_title = titles, fac_degree = degrees) %>%
      mutate(fac_name = gsub(' \\/.*$', '', fac_name))
  } else { NULL }
}

get_pubmed_articles_by_author <- function(author) {
  ids <- get_pubmed_ids(paste0(author, "[Author]"))
  if (as.numeric(ids$Count) > 0) {
    fetch_pubmed_data(ids, encoding = "ASCII") %>% 
      articles_to_list() %>% 
      map(article_to_df, getAuthors = FALSE) %>% 
      bind_rows() %>% mutate(fac_name = author) %>%
      mutate(date = paste(year, month, day, sep = "-")) %>%
      select(pmid, doi, title, date, jabbrv, fac_name)
  } else { NULL }
}

# Get list of UW SPH core faculty from website unless data exists in local file

# Set filepath
ws_file <- "sph_core_faculty_list.csv"
ws_filepath <- file.path(data_dir, ws_file)

if(file.exists(ws_filepath)) {
  df <- read_csv(ws_filepath)
} else {
  # Extract SPH faculty member information from HTML contained in JSON data.
  # The page has a "Load More Results" button which appends more JSON results.
  # We need to repeat this at least five times to get all of the faculty. 
  # We will code this for nine times just in case the number of faculty grows.
  df <- map(1:9, get_sph_faculty) %>% bind_rows()
  
  # Save results
  write_csv(df, ws_filepath)
}

# Query Pubmed for articles unless data exists in local file

# Set filepath
pm_file <- "sph_core_faculty_pubmed_articles.csv"
pm_filepath <- file.path(data_dir, pm_file)

if(file.exists(pm_filepath)) {
  pm_df <- read_csv(pm_filepath)
} else {
  # Query Pubmed by author for each SPH faculty member.
  # Edit author names as needed to better match Pubmed database.
  df[df$fac_name == "Fretts, Mandy", "fac_name"] <- "Fretts, Amanda M."
  df[df$fac_name == "Mooney, Steve J.", "fac_name"] <- "Mooney, Stephen J."
  pm_df <-  map(df$fac_name, get_pubmed_articles_by_author) %>% 
    bind_rows() %>% inner_join(df, by = "fac_name") %>%
    separate(fac_name, c('fac_lname', 'fac_fname'), ", ", extra = "merge")
  
  # Save results
  write_csv(pm_df, pm_filepath)
} 

# Plot top-50 article counts per faculty member as a histogram
pm_hist <- pm_df %>% mutate(Author = paste(fac_fname, fac_lname)) %>% 
  group_by(Author) %>% summarise(`Article Count` = n()) %>% 
  mutate(Author = reorder(Author, `Article Count`)) %>% 
  arrange(desc(`Article Count`)) %>% head(50) %>% 
  ggplot(aes(x = Author, y = `Article Count`)) + geom_bar(stat = "identity") + 
  coord_flip() + ggtitle("SPH Core Faculty Top-50 Pubmed Article Count")

# Save results
hist_filepath <- file.path(fig_dir, "sph_core_faculty_pubmed_articles_hist.png")
ggsave(hist_filepath, pm_hist, height = 8.65, width = 7.24)

# Plot article counts by job title as a boxplot
pm_box <- pm_df %>% mutate(Name = paste(fac_fname, fac_lname)) %>%
  group_by(fac_title, Name) %>% summarise(`Article Count` = n()) %>%
  ggplot(aes(reorder(fac_title, `Article Count`), `Article Count`)) + 
  geom_boxplot() + coord_flip() + theme(axis.title.y = element_blank()) + 
  ggtitle("SPH Core Faculty Pubmed Article Count by Job Title")

# Save results
box_filepath <- file.path(fig_dir, "sph_core_faculty_pubmed_articles_box.png")
ggsave(box_filepath, pm_box, height = 8.65, width = 7.24)
