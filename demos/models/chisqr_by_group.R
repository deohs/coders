# Run a Pearson's Chi-squared by group using a tidyverse pipeline
# Adapted from: https://stackoverflow.com/questions/49659103

if (!require(pacman)) install.packages("pacman")
pacman::p_load(dplyr, tidyr, purrr, broom, titanic)

titanic_train %>% 
  group_by(Pclass, Survived, Sex) %>%
  summarize(freq = n(), .groups = "drop") %>%
  group_by(Pclass) %>% nest() %>%
  mutate(M = map(data, ~ .x %>% 
      pivot_wider(names_from = Sex, values_from = freq) %>% 
      select(-Survived) %>% as.matrix())) %>% 
  mutate(p.value = map_dbl(M, ~chisq.test(.x)$p.value)) %>%
  select(-data, -M)


