# Working with multi-value data
#
# Some common "untidy data" scenarios are listed in the following article:
# https://tidyr.tidyverse.org/articles/tidy-data.html
#
# However, a case not mentioned there is when a variable contains nested lists. 
#
# Usually we work with data organized such that for each row and column, there
# is a single value. That is, if we view our data as a grid, each "cell" in 
# that grid only contains a single value. What if the value is actually a 
# vector or list? What if those nested objects are of unequal length? How can 
# we "flatten" the dataset?
#
# Scenario: Each participant (id) has one or more pets, of various types.
#           Pet types are grouped into classes. Count the number of 
#           pets per class owned by each participant.

# ---- Setup ----

# Clear workspace of all objects.
rm(list = ls(all = TRUE))

# Unload all extra (non-base) packages.
if (!is.null(sessionInfo()$otherPkgs)) {
  res <- suppressWarnings(map(
    paste('package:', names(sessionInfo()$otherPkgs), sep = ""),
    detach,
    character.only = TRUE,
    unload = TRUE,
    force = TRUE
  ))
}

# Load pacman, installing if needed.
if (!require("pacman")) install.packages("pacman")

# Load other packages, installing as needed.
pacman::p_load(dplyr, tidyr, stringr, purrr, ggplot2)


# ---- Define functions ----

# Create a list of pets for a participant as a comma-space separated string.
get_pets <- function(lst, min_n, max_n) {
  sample(unlist(lst), sample(min_n:max_n, 1), replace = TRUE) %>% 
    paste(collapse = ", ")
}

# Find the pet class given a pet type.
get_class <- function(lst, pet) names(lst)[map_lgl(lst, ~ pet %in% .x)]


# ---- Prepare dataset ----

# Define variables.
n_ids <- 20
min_pets <- 2
max_pets <- 5

# Create list of pet types, grouped by class.
pets <- list(amphibian = c('frog', 'salamander'),
             mammal = c('cat', 'dog', 'hamster'),
             reptile = c('lizard', 'snake', 'turtle'))

# Create dataset.
set.seed(1)
pets_multivalued <- map_chr(1:n_ids, ~get_pets(pets, min_pets, max_pets))
df <- tibble(id = 1:n_ids, pet = pets_multivalued)

# View dataset
df


# ---- Method #1: Split and Unnest ----

# Use str_split() and unnest() to split multi-value data into single-value 
# data, then plot the classes of pet per id as a bar plot (histogram).

# Split multi-valued strings into rows (one row per value).
df_long <- df %>% mutate(pet = str_split(pet, pattern = ", ")) %>% unnest(pet)

df_long

# For each pet, find pet class using get_class(), defined in Functions section.
df_long <- df_long %>% mutate(`class` = map_chr(pet, ~get_class(pets, .x)))

df_long

# Let ggplot() count the number of classes per id using stat = "count".
ggplot(df_long, aes(x = `id`)) + geom_bar(stat = "count") + 
  facet_wrap(~ `class`, nrow = 3)


# ---- Method #2: Count Pattern Matches ----

# As an alternative, use str_count() to produce frequency counts. So, we don't
# actually need to "flatten" the dataset, just search the multi-value variable 
# for pattern matches and count them.

# Count the number of pet classes per id by counting pattern matches.
df_count <- pets %>% 
  map(paste0, collapse = '|') %>% 
  map(~str_count(df$pet, .x)) %>% 
  bind_cols(df) %>% select(-pet) %>%
  pivot_longer(cols = any_of(names(pets)), 
               names_to = "class", values_to = "count")

# Since we have already counted the number per class, use stat = "identity".
ggplot(df_count, aes(x = `id`, y = `count`)) + geom_bar(stat = "identity") + 
  facet_wrap(~ `class`, nrow = 3)

