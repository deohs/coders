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
# Scenario: Each participant (id) has one or more pets, of various species.
#           For simplicity, only one pet per species is allowed per pet owner.
#           Pet species are grouped into types. Count the number of pets per
#           type owned by each test participant.

library(dplyr)
library(tidyr)
library(stringr)
library(purrr)
library(ggplot2)
library(rlist)

# ---- Define functions ----

# Create a list of pets for a participant as a comma-space separated string.
get_pets <- function(min_n, max_n, pet_lst) {
  sample(unlist(pet_lst), sample(min_n:max_n, 1), replace = FALSE) %>% 
    paste(collapse = ", ")
}

# Find the pet type given a pet species.
get_type <- function(pet, pet_lst) names(list.search(pet_lst, any(. == pet)))

# --------------------------


# Define variables.
n_ids <- 20
min_pets <- 2
max_pets <- 5

# Create list of pet species.
pets <- list(amphibian = c('frog', 'salamander'),
             mammal = c('cat', 'dog', 'hamster'),
             reptile = c('lizard', 'snake', 'turtle'))

# Create dataset.
set.seed(1)
pets_multivalued <- map_chr(1:n_ids, ~(get_pets(min_pets, max_pets, pets)))
df <- tibble(id = 1:n_ids, pet = pets_multivalued)

# View dataset
df

# ---- Method #1: Split and Unnest ----

# Use str_split() and unnest() to split multi-value data into single-value 
# data, then plot the types of pet per id as a bar plot (histogram).

# Split multi-valued strings into rows (one row per value).
df_long <- df %>% mutate(pet = str_split(pet, pattern = ", ")) %>% unnest(pet)

df_long

# For each pet, find pet type using get_type(), defined in Functions section.
df_long <- df_long %>% mutate(type = map_chr(pet, get_type, pet_lst = pets))

df_long

# Let ggplot() count the number of types per id using stat = "count".
ggplot(df_long, aes(x = `id`)) + geom_bar(stat = "count") + 
  facet_wrap(~ `type`, nrow = 3)

# ---- Method #2: Count Pattern Matches ----

# As an alternative, use str_count() to produce frequency counts. So, we don't
# actually need to "flatten" the dataset, just search the multi-value variable 
# for pattern matches and count them.

# Count the number of pet types per id by counting pattern matches.
df_count <- pets %>% 
  map(paste0, collapse = '|') %>% 
  map(~str_count(df$pet, .x)) %>% 
  bind_cols(df) %>% select(-pet) %>%
  pivot_longer(cols = any_of(names(pets)), 
               names_to = "type", values_to = "count")

# Since we have already counted the number per type, use stat = "identity".
ggplot(df_count, aes(x = `id`, y = `count`)) + geom_bar(stat = "identity") + 
  facet_wrap(~ `type`, nrow = 3)

