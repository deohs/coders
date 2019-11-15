# Filename: chicago_pollution_modeling.R
# Copyright (c) University of Washington
# License: MIT https://opensource.org/licenses/MIT (See LICENSE file.)
# Repository: https://github.com/deohs/coders
# Authors: Rachel Shaffer, Cooper Schumacher, and Brian High
#
# Automate "many models" with tidyverse using Chicago pollution data.
# Compare base-R and tidyverse (pipes, dplyr, broom and purrr) approaches.
# Compare single-core and parallel processing execution times with mclapply().

# Clear workspace of all objects and unload all extra (non-base) packages.
rm(list = ls(all = TRUE))
if (!is.null(sessionInfo()$otherPkgs)) {
  res <- suppressWarnings(lapply(
    paste('package:', names(sessionInfo()$otherPkgs), sep = ""),
    detach, character.only = TRUE, unload = TRUE, force = TRUE))
}

# Load packages.
if (!require(pacman)) {
  install.packages('pacman', repos = 'http://cran.us.r-project.org')
}
pacman::p_load(dlnm, ThermIndex, magrittr, tibble, dplyr, tidyr, rsample, 
               broom, purrr, parallel)

# Get data
data(chicagoNMMAPS)
df <- chicagoNMMAPS
names(df)

# A data frame with 5114 observations on the following 14 variables.
# 
# date:   Date in the period 1987-2000.
# time:   The sequence of observations
# year:   Year
# month:  Month (numeric)
# doy:    Day of the year
# dow:    Day of the week (factor)
# death:  Counts of all cause mortality excluding accident
# cvd:    Cardiovascular Deaths
# resp:   Respiratory Deaths
# temp:   Mean temperature (in Celsius degrees)
# dptp:   Dew point temperature
# rhum:   Mean relative humidity
# pm10:   PM10
# o3:     Ozone

# Calculate humidex
df %<>% mutate(hmdx = humidex(temp, rhum))

# Make vector of outcomes
outcomes <- c("death", "cvd", "resp")

# Make vector of exposures
exposures <- c("pm10", "o3")

# Make formula of outcomes associated w/exposures for each possible combination
base_models <- paste0(outcomes, " ~ ", rep(exposures, each = length(outcomes)))

# Make a list of covariates
covariates_list <- list(
  model1 = c("temp"),
  model2 = c("temp", "dptp"),
  model3 = c("temp", "dptp", "rhum"),
  model4 = c("temp", "dptp", "rhum", "hmdx"),
  model5 = c("temp", "dptp", "rhum", "hmdx", "dow")
  )

# Transfer from list to format separated by "+" 
covariates <- unlist(lapply(covariates_list, 
                            function(x) paste(x, collapse = " + ")))

# Develop all combinations of exposures, outcomes, covariates 
formula_list_char <- as.list(
  paste0(rep(base_models, each = length(covariates)), " + ", covariates))

# Create a list of formulas
formula_list <- lapply(formula_list_char, as.formula)

# Create boostrap samples
nBoot <- 3 #change to 1000

# ----------------------------------------------------------------------
# Compare different ways to get the bootrap samples
# ----------------------------------------------------------------------

# Create boot.samples with sample() function, with replacement, using for()
set.seed(12345)
boot.samples <- list()
for(i in 1:nBoot){
  # Take sample with replacement
  boot.samples[[i]] <- df[sample(1:nrow(df)[1], replace = TRUE), ]
}

# Create boot.samples with sample() function, with replacement, using lapply()
set.seed(12345)
boot.samples2 <- list()
boot.samples2 <- lapply(1:nBoot, function(x) {
  df[sample(1:nrow(df), replace = TRUE), ]
})
all.equal(boot.samples, boot.samples2)

# Create boot.samples with sample() function, with replacement using map()
set.seed(12345)
boot.samples2 <- 1:nBoot %>% map(~df[sample(1:nrow(df), replace = TRUE), ])
all.equal(boot.samples, boot.samples2)

# Compare use of sample() to create boot.samples with rsample::bootstraps()
set.seed(12345)
boot.samples2 <- df %>% bootstraps(times = nBoot) %>% pull(splits) %>%
  map(analysis)
all.equal(boot.samples, boot.samples2)


# Extract summaries from bootstrapped samples

# Define alpha
alpha <- 0.05

# Define a function to extract model results
get_boot_results <- function(.data, .formula, weights = NULL) {
  out <- list()
  out$formula <- .formula
  .formula <- as.formula(.formula)
  coefs <- as.data.frame(matrix(
    unlist(lapply(.data, function(y) {
        if (!is.null(weights)) {
          lm(.formula, y, weights = weights)$coef
        } else {
          lm(.formula, y)$coef
        }
      })
    ),
    nrow = length(seq_along(.data)),
    byrow = T
  ))
  colnames(coefs) <- names(lm(.formula, .data[[1]])$coef)
  
  est <- apply(coefs, 2, mean)
  LCI <- apply(coefs, 2, function(z) quantile(z, alpha / 2))
  UCI <- apply(coefs, 2, function(z) quantile(z, 1 - alpha / 2))
  out$estimates <- data.frame(cbind(estimate = est, LCI = LCI, UCI = UCI))
  out
}

# ----------------------------------------------------------------------
# Compare getting model results with only one core versus multiple cores
# ----------------------------------------------------------------------

# Get model results for all models
system.time(
  boot.results <- 
    lapply(formula_list_char, 
           function(f) get_boot_results(boot.samples, f))
  )
# For nBoot = 3...
# user  system elapsed 
# 1.021   0.000   1.024 

# Define number of cores
num_cores <- 4

# Get model results for all models - repeat using parallel processing
system.time(
  boot.results.mc <- 
    mclapply(formula_list_char, 
             function(f) get_boot_results(boot.samples, f), 
                              mc.cores = num_cores)
  )
# For nBoot = 3...
# user  system elapsed 
# 0.612   0.473   0.413

all.equal(boot.results, boot.results.mc)
# TRUE


# ----------------------------------------------------------------------
# Compare two functions to convert results list into a dataframe
# ----------------------------------------------------------------------

# Convert to single dataframe with columns: model, variable, estimate, LCI, UCI
res_to_df <- function(.data) {
  for(i in seq_along(.data)) {
    df_temp <- .data[[i]]$estimates
    df_temp$variable <- rownames(df_temp)
    df_temp$model <- .data[[i]]$formula
  
    if (i == 1) {
      df <- df_temp[, c("model", "variable", "estimate", "LCI", "UCI")]
    } else{
      df <-
        rbind(df, df_temp[, c("model", "variable", "estimate", "LCI", "UCI")])
    }
  }
  return(df %>% arrange(model, variable))
}

# Convert to single dataframe with columns: model, variable, estimate, LCI, UCI
res_to_df2 <- function(.data) {
  .data %>% lapply(function(x) { 
    x$estimates %>% 
      rownames_to_column(var = "variable") %>% 
      mutate(model = x$formula) %>% 
      select(model, variable, estimate, LCI, UCI) 
    }) %>% 
    bind_rows() %>% 
    arrange(model, variable)
}

# Filter to only keep rows where variable contains the string "pm10"
system.time(
  df_raw_filtered <- 
    res_to_df(boot.results) %>% filter(grepl("pm10", variable))
  )
# user  system elapsed 
# 0.02    0.00    0.02

system.time(
  df_raw_filtered2 <- 
    res_to_df2(boot.results) %>% filter(grepl("pm10", variable))
  )
# user  system elapsed 
# 0.147   0.000   0.147

all.equal(df_raw_filtered, df_raw_filtered2)
# TRUE

df_raw_filtered


# ---------------------------------------------------------------------------
# Compare with using purrr and broom
# ---------------------------------------------------------------------------

# Fit models and calculate confidence intervals on mean of estimate of pm10
set.seed(12345)
df_raw_filtered3 <- df %>% bootstraps(times = nBoot) %>% 
  mutate(results_raw = map(splits, ~lapply(formula_list, function(f) {
      lm(f, analysis(.x) ) })),
         coef_info =  map(results_raw, ~lapply(.x, tidy)),
         model = lapply(1:nBoot, function(x) as.character(formula_list))) %>% 
  select(model, coef_info) %>% 
  unnest(c(model, coef_info)) %>% 
  unnest(c(model, coef_info)) %>% 
  filter(term == 'pm10') %>%
  group_by(model, term) %>% 
  summarize(beta = mean(estimate),
            LCI = quantile(estimate, alpha / 2),
            UCI = quantile(estimate, 1 - alpha / 2)) %>% 
  rename(variable = term, estimate = beta) %>%
  as.data.frame()

# View results
df_raw_filtered3

# Compare with results from previous approach
all.equal(df_raw_filtered, df_raw_filtered3)

