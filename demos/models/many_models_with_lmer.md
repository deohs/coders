---
title: "Many Models with lme4::lmer() and broom.mixed::tidy()"
author: "Brian High"
date: "2022-10-17"
output:
  html_document:
    df_print: paged
    keep_md: yes
  pdf_document:
    fig_caption: yes
    keep_md: yes
editor_options:
  chunk_output_type: console
---



## Objectives

- Run many models with `lme4::lmer()` and extract estimates with `broom.mixed::tidy()`.
- Use `furrr::future_map()` for parallel processing.
- Compare results of:
    - `lme4::confint.merMod(method = "Wald")`
    - `broom.mixed::tidy(conf.int = TRUE, conf.method = "Wald")`

## Setup

We will use the *broom.mixed* package to support `lmer()` from the *lme4* package.


```r
# Install pacman if not installed.
if (!require(pacman)) {
  install.packages('pacman', repos = 'http://cran.us.r-project.org')
}
```

```
## Loading required package: pacman
```

```r
# Load packages, installing as needed.
suppressPackageStartupMessages(
  pacman::p_load(
    nycflights13,
    tibble,
    tidyr,
    dplyr,
    lme4,
    broom.mixed,
    purrr,
    furrr,
    tictoc,
    kableExtra
  )
)

# Show number of available CPU cores.
availableCores()
```

```
## system 
##      8
```

```r
# Set number of multicore "workers" to 1/2 the number of cores.
plan(multisession, workers = availableCores()/2)
```

## Prepare formulas

We use a list so that we can have named groups of formulas.


```r
# Create a list of formulas for use with lmer().
formulas <- list(
  crude = c(
    "arr_delay ~ distance + (1|carrier)",
    "arr_delay ~ air_time + (1|carrier)",
    "arr_delay ~ month + (1|carrier)"
  ),
  min = c(
    "arr_delay ~ distance + air_time + (1|carrier)",
    "arr_delay ~ distance + month + (1|carrier)",
    "arr_delay ~ air_time + month + (1|carrier)"
  ),
  max = c("arr_delay ~ distance + air_time + month + (1|carrier)")
)

# Convert the list of formulas into a data.frame (tibble).
formula_df <- formulas %>%
  enframe(name = "fgroup", value = "formula") %>% unnest(formula)
```

## Prepare data

Our dataset will be `flights` from the *nycflights13* package.


```r
# Select only the model variables to minimize parallelization overhead.
data_df <- 
  flights %>% select(arr_delay, distance, air_time, month, carrier)
```

## Run the models

We could use `nest()` for the following steps in a single pipeline, using 
`tidy()` for confidence intervals, but the terms might be misaligned. 

Instead, using a stepwise approach, we retain the term names, use 
`confint.merMod()` to get confidence intervals, join on the terms 
and the formula number, and show the results to compare the two 
methods of getting confidence intervals.


```r
# Start timer.
tic()

# Fit the models with lmer() using future_map() for multicore processing.
model_fit_list <- formula_df$formula %>% future_map(lmer, data = data_df)

# Extract the estimates with broom.mixed::tidy().
est <- 
  model_fit_list %>%
  map(broom.mixed::tidy, conf.int = TRUE, 
      conf.method = "Wald", conf.level = 0.95) %>%
  bind_rows(.id = "ID") %>%
  select(-group)

# Calculate confidence intervals with confint.merMod().
CI <-  
  model_fit_list %>%
  map(confint.merMod, method = "Wald", level = 0.95) %>%
  map(as_tibble, rownames = "term") %>%
  bind_rows(.id = "ID")

# Merge estimates and confidence intervals by formula number (ID) and term.
results_df <- formula_df %>%
  rownames_to_column(var = "ID") %>%
  inner_join(est, by = "ID") %>%
  inner_join(CI, by = c("ID", "term")) %>%
  select(-ID, -effect, -std.error, -statistic) %>%
  arrange(fgroup, formula, term)

# Stop timer.
toc()
```

```
## 22.606 sec elapsed
```

Display the results.


```r
results_df %>% knitr::kable(digits = 4)
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> fgroup </th>
   <th style="text-align:left;"> formula </th>
   <th style="text-align:left;"> term </th>
   <th style="text-align:right;"> estimate </th>
   <th style="text-align:right;"> conf.low </th>
   <th style="text-align:right;"> conf.high </th>
   <th style="text-align:right;"> 2.5 % </th>
   <th style="text-align:right;"> 97.5 % </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> crude </td>
   <td style="text-align:left;"> arr_delay ~ air_time + (1|carrier) </td>
   <td style="text-align:left;"> (Intercept) </td>
   <td style="text-align:right;"> 5.5096 </td>
   <td style="text-align:right;"> 0.6767 </td>
   <td style="text-align:right;"> 10.3424 </td>
   <td style="text-align:right;"> 0.6767 </td>
   <td style="text-align:right;"> 10.3424 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> crude </td>
   <td style="text-align:left;"> arr_delay ~ air_time + (1|carrier) </td>
   <td style="text-align:left;"> air_time </td>
   <td style="text-align:right;"> 0.0085 </td>
   <td style="text-align:right;"> 0.0065 </td>
   <td style="text-align:right;"> 0.0105 </td>
   <td style="text-align:right;"> 0.0065 </td>
   <td style="text-align:right;"> 0.0105 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> crude </td>
   <td style="text-align:left;"> arr_delay ~ distance + (1|carrier) </td>
   <td style="text-align:left;"> (Intercept) </td>
   <td style="text-align:right;"> 8.9182 </td>
   <td style="text-align:right;"> 4.8971 </td>
   <td style="text-align:right;"> 12.9394 </td>
   <td style="text-align:right;"> 4.8971 </td>
   <td style="text-align:right;"> 12.9394 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> crude </td>
   <td style="text-align:left;"> arr_delay ~ distance + (1|carrier) </td>
   <td style="text-align:left;"> distance </td>
   <td style="text-align:right;"> -0.0014 </td>
   <td style="text-align:right;"> -0.0016 </td>
   <td style="text-align:right;"> -0.0011 </td>
   <td style="text-align:right;"> -0.0016 </td>
   <td style="text-align:right;"> -0.0011 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> crude </td>
   <td style="text-align:left;"> arr_delay ~ month + (1|carrier) </td>
   <td style="text-align:left;"> (Intercept) </td>
   <td style="text-align:right;"> 8.5815 </td>
   <td style="text-align:right;"> 4.1367 </td>
   <td style="text-align:right;"> 13.0263 </td>
   <td style="text-align:right;"> 4.1367 </td>
   <td style="text-align:right;"> 13.0263 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> crude </td>
   <td style="text-align:left;"> arr_delay ~ month + (1|carrier) </td>
   <td style="text-align:left;"> month </td>
   <td style="text-align:right;"> -0.2242 </td>
   <td style="text-align:right;"> -0.2686 </td>
   <td style="text-align:right;"> -0.1797 </td>
   <td style="text-align:right;"> -0.2686 </td>
   <td style="text-align:right;"> -0.1797 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max </td>
   <td style="text-align:left;"> arr_delay ~ distance + air_time + month + (1|carrier) </td>
   <td style="text-align:left;"> (Intercept) </td>
   <td style="text-align:right;"> -2.7542 </td>
   <td style="text-align:right;"> -6.7541 </td>
   <td style="text-align:right;"> 1.2457 </td>
   <td style="text-align:right;"> -6.7541 </td>
   <td style="text-align:right;"> 1.2457 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max </td>
   <td style="text-align:left;"> arr_delay ~ distance + air_time + month + (1|carrier) </td>
   <td style="text-align:left;"> air_time </td>
   <td style="text-align:right;"> 0.6717 </td>
   <td style="text-align:right;"> 0.6599 </td>
   <td style="text-align:right;"> 0.6835 </td>
   <td style="text-align:right;"> 0.6599 </td>
   <td style="text-align:right;"> 0.6835 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max </td>
   <td style="text-align:left;"> arr_delay ~ distance + air_time + month + (1|carrier) </td>
   <td style="text-align:left;"> distance </td>
   <td style="text-align:right;"> -0.0862 </td>
   <td style="text-align:right;"> -0.0877 </td>
   <td style="text-align:right;"> -0.0847 </td>
   <td style="text-align:right;"> -0.0877 </td>
   <td style="text-align:right;"> -0.0847 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max </td>
   <td style="text-align:left;"> arr_delay ~ distance + air_time + month + (1|carrier) </td>
   <td style="text-align:left;"> month </td>
   <td style="text-align:right;"> -0.0443 </td>
   <td style="text-align:right;"> -0.0881 </td>
   <td style="text-align:right;"> -0.0006 </td>
   <td style="text-align:right;"> -0.0881 </td>
   <td style="text-align:right;"> -0.0006 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> min </td>
   <td style="text-align:left;"> arr_delay ~ air_time + month + (1|carrier) </td>
   <td style="text-align:left;"> (Intercept) </td>
   <td style="text-align:right;"> 6.9904 </td>
   <td style="text-align:right;"> 2.1389 </td>
   <td style="text-align:right;"> 11.8419 </td>
   <td style="text-align:right;"> 2.1389 </td>
   <td style="text-align:right;"> 11.8419 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> min </td>
   <td style="text-align:left;"> arr_delay ~ air_time + month + (1|carrier) </td>
   <td style="text-align:left;"> air_time </td>
   <td style="text-align:right;"> 0.0086 </td>
   <td style="text-align:right;"> 0.0066 </td>
   <td style="text-align:right;"> 0.0106 </td>
   <td style="text-align:right;"> 0.0066 </td>
   <td style="text-align:right;"> 0.0106 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> min </td>
   <td style="text-align:left;"> arr_delay ~ air_time + month + (1|carrier) </td>
   <td style="text-align:left;"> month </td>
   <td style="text-align:right;"> -0.2262 </td>
   <td style="text-align:right;"> -0.2706 </td>
   <td style="text-align:right;"> -0.1817 </td>
   <td style="text-align:right;"> -0.2706 </td>
   <td style="text-align:right;"> -0.1817 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> min </td>
   <td style="text-align:left;"> arr_delay ~ distance + air_time + (1|carrier) </td>
   <td style="text-align:left;"> (Intercept) </td>
   <td style="text-align:right;"> -3.0548 </td>
   <td style="text-align:right;"> -7.0448 </td>
   <td style="text-align:right;"> 0.9351 </td>
   <td style="text-align:right;"> -7.0448 </td>
   <td style="text-align:right;"> 0.9351 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> min </td>
   <td style="text-align:left;"> arr_delay ~ distance + air_time + (1|carrier) </td>
   <td style="text-align:left;"> air_time </td>
   <td style="text-align:right;"> 0.6725 </td>
   <td style="text-align:right;"> 0.6608 </td>
   <td style="text-align:right;"> 0.6843 </td>
   <td style="text-align:right;"> 0.6608 </td>
   <td style="text-align:right;"> 0.6843 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> min </td>
   <td style="text-align:left;"> arr_delay ~ distance + air_time + (1|carrier) </td>
   <td style="text-align:left;"> distance </td>
   <td style="text-align:right;"> -0.0863 </td>
   <td style="text-align:right;"> -0.0878 </td>
   <td style="text-align:right;"> -0.0848 </td>
   <td style="text-align:right;"> -0.0878 </td>
   <td style="text-align:right;"> -0.0848 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> min </td>
   <td style="text-align:left;"> arr_delay ~ distance + month + (1|carrier) </td>
   <td style="text-align:left;"> (Intercept) </td>
   <td style="text-align:right;"> 10.3305 </td>
   <td style="text-align:right;"> 6.2897 </td>
   <td style="text-align:right;"> 14.3714 </td>
   <td style="text-align:right;"> 6.2897 </td>
   <td style="text-align:right;"> 14.3714 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> min </td>
   <td style="text-align:left;"> arr_delay ~ distance + month + (1|carrier) </td>
   <td style="text-align:left;"> distance </td>
   <td style="text-align:right;"> -0.0013 </td>
   <td style="text-align:right;"> -0.0016 </td>
   <td style="text-align:right;"> -0.0011 </td>
   <td style="text-align:right;"> -0.0016 </td>
   <td style="text-align:right;"> -0.0011 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> min </td>
   <td style="text-align:left;"> arr_delay ~ distance + month + (1|carrier) </td>
   <td style="text-align:left;"> month </td>
   <td style="text-align:right;"> -0.2190 </td>
   <td style="text-align:right;"> -0.2635 </td>
   <td style="text-align:right;"> -0.1745 </td>
   <td style="text-align:right;"> -0.2635 </td>
   <td style="text-align:right;"> -0.1745 </td>
  </tr>
</tbody>
</table>

### Compare confidence intervals

Determine whether or not the two methods of calculating the confidence 
intervals produce identical results.


```r
identical(results_df$conf.low, results_df$`2.5 %`)
```

```
## [1] TRUE
```

```r
identical(results_df$conf.high, results_df$`97.5 %`)
```

```
## [1] TRUE
```

## Use a single pipeline

Since the results showed the two methods for producing confidence intervals are
equivalent, we will now use a single pipeline, without running `confint.merMod()`, 
so we can compare performance.


```r
# Start timer.
tic()

# Fit the models with lmer() using future_map() and extract the estimates and 
# confidence intervals with broom.mixed::tidy() using map().
results_df <- formula_df %>% 
  mutate(model = future_map(formula, lmer, data = data_df)) %>%
  mutate(est = map(model, broom.mixed::tidy, conf.int = TRUE, 
                   conf.method = "Wald", conf.level = 0.95)) %>%
  select(-model) %>% unnest(cols = everything()) %>%
  filter(is.na(group)) %>% 
  select(-group, -effect, -std.error, -statistic) %>%
  arrange(fgroup, formula, term)
  
# Stop timer.
toc()
```

```
## 13.207 sec elapsed
```

Display the results.


```r
results_df %>% knitr::kable(digits = 4)
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> fgroup </th>
   <th style="text-align:left;"> formula </th>
   <th style="text-align:left;"> term </th>
   <th style="text-align:right;"> estimate </th>
   <th style="text-align:right;"> conf.low </th>
   <th style="text-align:right;"> conf.high </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> crude </td>
   <td style="text-align:left;"> arr_delay ~ air_time + (1|carrier) </td>
   <td style="text-align:left;"> (Intercept) </td>
   <td style="text-align:right;"> 5.5096 </td>
   <td style="text-align:right;"> 0.6767 </td>
   <td style="text-align:right;"> 10.3424 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> crude </td>
   <td style="text-align:left;"> arr_delay ~ air_time + (1|carrier) </td>
   <td style="text-align:left;"> air_time </td>
   <td style="text-align:right;"> 0.0085 </td>
   <td style="text-align:right;"> 0.0065 </td>
   <td style="text-align:right;"> 0.0105 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> crude </td>
   <td style="text-align:left;"> arr_delay ~ distance + (1|carrier) </td>
   <td style="text-align:left;"> (Intercept) </td>
   <td style="text-align:right;"> 8.9182 </td>
   <td style="text-align:right;"> 4.8971 </td>
   <td style="text-align:right;"> 12.9394 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> crude </td>
   <td style="text-align:left;"> arr_delay ~ distance + (1|carrier) </td>
   <td style="text-align:left;"> distance </td>
   <td style="text-align:right;"> -0.0014 </td>
   <td style="text-align:right;"> -0.0016 </td>
   <td style="text-align:right;"> -0.0011 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> crude </td>
   <td style="text-align:left;"> arr_delay ~ month + (1|carrier) </td>
   <td style="text-align:left;"> (Intercept) </td>
   <td style="text-align:right;"> 8.5815 </td>
   <td style="text-align:right;"> 4.1367 </td>
   <td style="text-align:right;"> 13.0263 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> crude </td>
   <td style="text-align:left;"> arr_delay ~ month + (1|carrier) </td>
   <td style="text-align:left;"> month </td>
   <td style="text-align:right;"> -0.2242 </td>
   <td style="text-align:right;"> -0.2686 </td>
   <td style="text-align:right;"> -0.1797 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max </td>
   <td style="text-align:left;"> arr_delay ~ distance + air_time + month + (1|carrier) </td>
   <td style="text-align:left;"> (Intercept) </td>
   <td style="text-align:right;"> -2.7542 </td>
   <td style="text-align:right;"> -6.7541 </td>
   <td style="text-align:right;"> 1.2457 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max </td>
   <td style="text-align:left;"> arr_delay ~ distance + air_time + month + (1|carrier) </td>
   <td style="text-align:left;"> air_time </td>
   <td style="text-align:right;"> 0.6717 </td>
   <td style="text-align:right;"> 0.6599 </td>
   <td style="text-align:right;"> 0.6835 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max </td>
   <td style="text-align:left;"> arr_delay ~ distance + air_time + month + (1|carrier) </td>
   <td style="text-align:left;"> distance </td>
   <td style="text-align:right;"> -0.0862 </td>
   <td style="text-align:right;"> -0.0877 </td>
   <td style="text-align:right;"> -0.0847 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max </td>
   <td style="text-align:left;"> arr_delay ~ distance + air_time + month + (1|carrier) </td>
   <td style="text-align:left;"> month </td>
   <td style="text-align:right;"> -0.0443 </td>
   <td style="text-align:right;"> -0.0881 </td>
   <td style="text-align:right;"> -0.0006 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> min </td>
   <td style="text-align:left;"> arr_delay ~ air_time + month + (1|carrier) </td>
   <td style="text-align:left;"> (Intercept) </td>
   <td style="text-align:right;"> 6.9904 </td>
   <td style="text-align:right;"> 2.1389 </td>
   <td style="text-align:right;"> 11.8419 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> min </td>
   <td style="text-align:left;"> arr_delay ~ air_time + month + (1|carrier) </td>
   <td style="text-align:left;"> air_time </td>
   <td style="text-align:right;"> 0.0086 </td>
   <td style="text-align:right;"> 0.0066 </td>
   <td style="text-align:right;"> 0.0106 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> min </td>
   <td style="text-align:left;"> arr_delay ~ air_time + month + (1|carrier) </td>
   <td style="text-align:left;"> month </td>
   <td style="text-align:right;"> -0.2262 </td>
   <td style="text-align:right;"> -0.2706 </td>
   <td style="text-align:right;"> -0.1817 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> min </td>
   <td style="text-align:left;"> arr_delay ~ distance + air_time + (1|carrier) </td>
   <td style="text-align:left;"> (Intercept) </td>
   <td style="text-align:right;"> -3.0548 </td>
   <td style="text-align:right;"> -7.0448 </td>
   <td style="text-align:right;"> 0.9351 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> min </td>
   <td style="text-align:left;"> arr_delay ~ distance + air_time + (1|carrier) </td>
   <td style="text-align:left;"> air_time </td>
   <td style="text-align:right;"> 0.6725 </td>
   <td style="text-align:right;"> 0.6608 </td>
   <td style="text-align:right;"> 0.6843 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> min </td>
   <td style="text-align:left;"> arr_delay ~ distance + air_time + (1|carrier) </td>
   <td style="text-align:left;"> distance </td>
   <td style="text-align:right;"> -0.0863 </td>
   <td style="text-align:right;"> -0.0878 </td>
   <td style="text-align:right;"> -0.0848 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> min </td>
   <td style="text-align:left;"> arr_delay ~ distance + month + (1|carrier) </td>
   <td style="text-align:left;"> (Intercept) </td>
   <td style="text-align:right;"> 10.3305 </td>
   <td style="text-align:right;"> 6.2897 </td>
   <td style="text-align:right;"> 14.3714 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> min </td>
   <td style="text-align:left;"> arr_delay ~ distance + month + (1|carrier) </td>
   <td style="text-align:left;"> distance </td>
   <td style="text-align:right;"> -0.0013 </td>
   <td style="text-align:right;"> -0.0016 </td>
   <td style="text-align:right;"> -0.0011 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> min </td>
   <td style="text-align:left;"> arr_delay ~ distance + month + (1|carrier) </td>
   <td style="text-align:left;"> month </td>
   <td style="text-align:right;"> -0.2190 </td>
   <td style="text-align:right;"> -0.2635 </td>
   <td style="text-align:right;"> -0.1745 </td>
  </tr>
</tbody>
</table>
