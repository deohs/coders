# Find articles in Pubmed authored by UW SPH Core Faculty and make plots

# Load packages, installing as needed
if (!require("pacman")) install.packages("pacman")
pacman::p_load(rvest, readr, dplyr, tidyr, purrr, easyPubMed, ggplot2)

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
titles <- nodes %>% html_node("p.fac-title") %>% html_text()
degrees <- nodes %>% html_node("p.fac-deg") %>% html_text()
df <- tibble(fac_name = names, fac_title = titles, fac_degree = degrees) %>%
  mutate(fac_name = gsub(' \\/.*$', '', fac_name))

# Query Pubmed for articles unless this information already exists in a file
pm_file <- "sph_core_faculty_pubmed_articles.csv"
pm_filepath <- file.path(data_dir, pm_file)

if(file.exists(pm_filepath)) {
  # Read the file if it exists
  pm_df <- read_csv(pm_filepath)
} else {
  # Query Pubmed for articles with SPH core faculty members as authors
  pm_df <- map(.x = df$fac_name, 
               .f = ~{paste0(.x, "[Author]") %>%
                   get_pubmed_ids() %>% 
                   fetch_pubmed_data(encoding = "ASCII") %>% 
                   articles_to_list() %>% 
                   map(article_to_df, getAuthors = FALSE) %>% 
                   bind_rows() %>% mutate(fac_name = .x) %>%
                   select(-keywords, -lastname, -firstname, -address, -email)
               }) %>% 
    bind_rows() %>% left_join(df, by = "fac_name") %>%
    separate(fac_name, c('fac_lname', 'fac_fname'), ", ", extra = "merge")
  
  # Save results
  write_csv(pm_df, pm_filepath)
} 

# Plot article counts as a histogram
pm_df %>% mutate(Author = paste(fac_fname, fac_lname)) %>% 
  group_by(Author) %>% summarise(`Article Count` = n()) %>% 
  mutate(Author = reorder(Author, `Article Count`)) %>% 
  ggplot(aes(x = Author, y = `Article Count`)) + geom_bar(stat = "identity") + 
  coord_flip()

# Plot article counts as a boxplot
pm_df %>% mutate(Name = paste(fac_fname, fac_lname)) %>%
  group_by(fac_title, Name) %>% summarise(`Article Count` = n()) %>%
  ggplot(aes(reorder(fac_title, `Article Count`), `Article Count`)) + 
  geom_boxplot() + coord_flip() + theme(axis.title.y = element_blank())
