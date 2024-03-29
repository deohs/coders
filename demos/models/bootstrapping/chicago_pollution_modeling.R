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
               broom, purrr, modelr, parallel, pryr)

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
nBoot <- 10

# ----------------------------------------------------------------------
# Compare different ways to get the bootrap samples
# ----------------------------------------------------------------------

# Create boot.samples with sample() function, with replacement, using for()
set.seed(12345)
boot.samples <- list()
system.time(
  for(i in 1:nBoot){
    # Take sample with replacement
    boot.samples[[i]] <- df[sample(1:nrow(df)[1], replace = TRUE), ]
  }
)
# For nBoot = 100...
#  user  system elapsed 
# 0.823   0.044   0.872 

# Create boot.samples with sample() function, with replacement, using lapply()
set.seed(12345)
system.time(
  boot.samples2 <- lapply(1:nBoot, function(x) {
    df[sample(1:nrow(df), replace = TRUE), ]
  })
)
# For nBoot = 100...
#  user  system elapsed 
# 0.780   0.033   0.877

all.equal(boot.samples, boot.samples2)

# Create boot.samples with sample() function, with replacement using map()
set.seed(12345)
system.time(
  boot.samples2 <- 1:nBoot %>% map(~df[sample(1:nrow(df), replace = TRUE), ])
)
# For nBoot = 100...
#  user  system elapsed 
# 0.692   0.026   0.723  

all.equal(boot.samples, boot.samples2)

# Compare use of sample() to create boot.samples with rsample::bootstraps()
set.seed(12345)
system.time(
  boot.samples2 <- df %>% bootstraps(times = nBoot) %>% pull(splits) %>%
    map(analysis)
)
# For nBoot = 100...
#  user  system elapsed 
# 0.679   0.000   0.683

all.equal(boot.samples, boot.samples2)

# Test results: All four variations take about the same amount of time to 
# run, though the two tidyverse versions are slightly faster.


# Extract summaries from bootstrapped samples

# Define alpha
alpha <- 0.05

# Define a function to extract model results
get_boot_results <- function(.data, .formula, .weights = NULL) {
  out <- list()
  out$formula <- .formula
  .formula <- as.formula(.formula)
  coefs <- as.data.frame(matrix(unlist(lapply(.data, function(y) 
      lm(.formula, y, weights = .weights)$coef)),
    nrow = length(seq_along(.data)), byrow = T))
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
# For nBoot = 100...
#   user  system elapsed 
# 19.934   0.139  20.083

# Define number of cores
num_cores <- 4

# Get model results for all models - repeat using parallel processing
system.time(
  boot.results.mc <- 
    mclapply(formula_list_char, 
             function(f) get_boot_results(boot.samples, f), 
                              mc.cores = num_cores)
  )
# For nBoot = 100...
#  user  system elapsed 
# 9.911   7.111   8.910 

all.equal(boot.results, boot.results.mc)
# TRUE

# Test results: Multicore processing was about twice as fast as single
# core processing.

# Display structure of results list
#source("plot_lib.R")
#plot_list_structure(boot.results[1:2])

# ----------------------------------------------------------------------
# Compare two functions to convert results list into a dataframe
# ----------------------------------------------------------------------

# Convert to single dataframe with columns: model, variable, estimate, LCI, UCI
res_to_df <- function(.data) {
  df <- do.call("rbind", lapply(.data, function(x) {
    df <- x$estimates
    df$variable <- rownames(df)
    df$model <- x$formula
    df[, c("model", "variable", "estimate", "LCI", "UCI")]
  }))
  df[order(df$model, df$variable),]
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
    res_to_df(boot.results) %>% filter(grepl("pm", variable))
  )
# For nBoot = 100...
#  user  system elapsed 
# 0.024   0.000   0.024

system.time(
  df_raw_filtered2 <- 
    res_to_df2(boot.results) %>% filter(grepl("pm", variable))
  )
# For nBoot = 100...
#  user  system elapsed 
# 0.185   0.000   0.189

all.equal(df_raw_filtered, df_raw_filtered2)
# TRUE

df_raw_filtered

# Test results: The base-R version was about 8 times faster than the 
# tidyverse version.

# ----------------------------------------------------------------------------
# Compare the processing time of the whole procedure, single-core vs. parallel
# ----------------------------------------------------------------------------

# Filter to only keep rows where variable contains the string "pm10"
system.time(
  df_raw_filtered <- 
    res_to_df(lapply(formula_list_char, function(f) {
      get_boot_results(boot.samples, f) })) %>% 
    filter(grepl("pm", variable))
)
# For nBoot = 100...
#   user  system elapsed 
# 19.164   0.437  19.623 

# Filter to only keep rows where variable contains the string "pm10"
system.time(
  df_raw_filtered2 <- 
    res_to_df(mclapply(formula_list_char, function(f) {
      get_boot_results(boot.samples, f) }, mc.cores = num_cores)) %>% 
    filter(grepl("pm", variable))
)
# For nBoot = 100...
#   user  system elapsed 
# 11.699  86.454  52.250 

all.equal(df_raw_filtered, df_raw_filtered2)
# TRUE

# Test results: The multicore version is about twice as slow as the 
# single core version. (Note: In other tests, before we added wupport for 
# weights, we observed the reverse. TODO: Improve implementation of weights.)


# TODO: Test with weights, for example...
# system.time(
#   df_raw_filtered <- 
#     res_to_df(lapply(formula_list_char, function(f) {
#       get_boot_results(boot.samples, f, 
#                        .weights = runif(nrow(df), min = 0, max = 1)) })) %>% 
#     filter(grepl("pm", variable))
# )

# ---------------------------------------------------------------------------
# Compare with using purrr and broom
# ---------------------------------------------------------------------------

# Fit models and calculate confidence intervals in mean of terms of interest
boot_results_tidy <- function(.data, .formulas, .var = '', .weights = NULL, 
                              .times = 10, .alpha = 0.05) {
  .data %>% bootstraps(times = .times) %>% 
    mutate(results = map(splits, 
                         ~fit_with(.x, lm, .formulas, weights = .weights)),
      coef =  map(results, ~lapply(.x, tidy)),
      model = lapply(1:.times, function(x) as.character(.formulas))) %>% 
    select(model, coef) %>% 
    unnest(c(model, coef)) %>% unnest(c(model, coef)) %>% 
    filter(grepl(.var, term)) %>% group_by(model, term) %>% 
    summarize(beta = mean(estimate),
              LCI = quantile(estimate, .alpha / 2),
              UCI = quantile(estimate, 1 - .alpha / 2)) %>% 
    rename(variable = term, estimate = beta) %>% as.data.frame()
}

# Fit models and calculate confidence intervals on mean of estimate of pm10
set.seed(12345)
system.time(df_raw_filtered3 <- 
              boot_results_tidy(.data = df, .formulas = formula_list, 
                                .var = 'pm', .times = nBoot))

# For nBoot = 100...
#    user  system elapsed 
# 62.287   1.350  63.643 

# Compare with results from previous approach
all.equal(df_raw_filtered, df_raw_filtered3)

# Test results: The base-R version is about four times as fast as the 
# tidyverse version.

# ---------------------------------------------------------------------------
# Compare with using purrr and broom, single-core vs. parallel
# ---------------------------------------------------------------------------

# Fit models and calculate confidence intervals in mean of terms of interest
boot_results_tidy_mc <- function(.data, .formulas, .var = '', 
                              .weights = rep(1, nrow(.data)), 
                              .times = 10, .alpha = 0.05, mc.cores = 1) {
  .data %>% bootstraps(times = .times) %>% 
    mutate(results = map(splits, ~mcmapply(
      lm, formula = .formulas, MoreArgs = list(data = .x, weights = .weights)),
      mc.cores = mc.cores),
      coef =  map(results, ~mclapply(.x, tidy, mc.cores = mc.cores)),
      model = lapply(1:.times, function(x) as.character(.formulas))) %>% 
    select(model, coef) %>% 
    unnest(c(model, coef)) %>% unnest(c(model, coef)) %>% 
    filter(grepl(.var, term)) %>% group_by(model, term) %>% 
    summarize(beta = mean(estimate),
              LCI = quantile(estimate, .alpha / 2),
              UCI = quantile(estimate, 1 - .alpha / 2)) %>% 
    rename(variable = term, estimate = beta) %>% as.data.frame()
}

# Fit models and calculate confidence intervals on mean of estimate of pm10
set.seed(12345)
system.time(df_raw_filtered3 <- 
              boot_results_tidy_mc(.data = df, .formulas = formula_list, 
                                   .var = 'pm', .times = nBoot, 
                                   mc.cores = num_cores))
# For nBoot = 100...
#    user  system elapsed 
# 153.944 484.831 352.020 

# Compare with results from previous approach
all.equal(df_raw_filtered, df_raw_filtered3)

# Test results: The single-core tidyverse version is about 2-1/2 times faster 
# than the multicore tidyverse version. The multicore base-R version is almost 
# 7 times faster than the multicore tidyverse version. (Note: Before we added
# support for weights, the multicore base-R version was 25 times faster than
# this version, and this version was twice as fast as it is now with support 
# for weights. TODO: Improve performance when using weights.)

# Find object size of output in memory
object_size(df_raw_filtered3)
