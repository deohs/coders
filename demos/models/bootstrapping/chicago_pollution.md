---
title: "Many Models in Base-R"
author: "Brian High and Rachel Shaffer"
date: "27 April, 2020"
output:
  ioslides_presentation:
    fig_caption: yes
    fig_retina: 1
    fig_width: 5
    fig_height: 3
    keep_md: yes
    smaller: yes
    incremental: false
    logo: img/logo_128.png
    css: inc/deohs-ioslides-theme.css
    template: inc/deohs-default-ioslides.html
editor_options: 
  chunk_output_type: console
---



## Objectives

Many models:

* Automate "many models" with base-R using Chicago pollution data.
* Produce a table of model estimates for various combinations of covariates.

Background processing:

* Demonstrate alternative ways to render (knit) Rmd files.
* Explore the use of the `screen` utility.

Modular programming:

* Demonstrate use of the `source` function to read code from other R scripts.
* Compare using `source` for functions to creating and using packages.

## Setup


```r
# Set knitr options
knitr::opts_chunk$set(echo = TRUE, cache = FALSE)
options("kableExtra.html.bsTable" = TRUE)
```


```r
# Load packages
pacman::p_load(dlnm, ThermIndex, kableExtra)
```

## Get the data

Import the `chicagoNMMAPS` dataset from the `dlnm` package:


```r
data(chicagoNMMAPS)
df <- chicagoNMMAPS
```

From `help('chicagoNMMAPS', dlnm)`:

```
date:   Date in the period 1987-2000.
time:   The sequence of observations
year:   Year
month:  Month (numeric)
doy:    Day of the year
dow:    Day of the week (factor)
death:  Counts of all cause mortality excluding accident
cvd:    Cardiovascular Deaths
resp:   Respiratory Deaths
temp:   Mean temperature (in Celsius degrees)
dptp:   Dew point temperature
rhum:   Mean relative humidity
pm10:   PM10
o3:     Ozone
```

## Prepare the base models

Create base model formulas from vectors of outcomes and exposures.


```r
# Calculate humidex
df$hmdx <- with(df, humidex(temp, rhum))

# Make vector of outcomes
outcomes <- c("death", "cvd", "resp")

# Make vector of exposures
exposures <- c("pm10", "o3")

# Make formula of outcomes associated w/exposures for each possible combination
base_models <- paste0(outcomes, " ~ ", rep(exposures, each = length(outcomes)))
```

Here are the resulting base model formulas:


```r
base_models
```

```
## [1] "death ~ pm10" "cvd ~ pm10"   "resp ~ pm10"  "death ~ o3"   "cvd ~ o3"    
## [6] "resp ~ o3"
```

## Add the covariates to models

From a vector of covariates, create a vector of model formulas.


```r
# Make a vector of model covariates expanded as "A", "A + B", "A + B + C", etc.
sep <- ' + '
covariate <- c("temp", "dptp", "rhum", "hmdx", "dow")
covariates <- unlist(sapply(seq_along(covariate), 
                     function(i) paste(covariate[1:i], collapse = sep)))

# Develop all combinations of exposures, outcomes, covariates 
models <- paste0(rep(base_models, each = length(covariates)), sep, covariates)
```

## View the models

<table class="table table-condensed" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Exposure = pm10 </th>
   <th style="text-align:left;"> Exposure = o3 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> death ~ pm10 + temp </td>
   <td style="text-align:left;"> death ~ o3 + temp </td>
  </tr>
  <tr>
   <td style="text-align:left;"> death ~ pm10 + temp + dptp </td>
   <td style="text-align:left;"> death ~ o3 + temp + dptp </td>
  </tr>
  <tr>
   <td style="text-align:left;"> death ~ pm10 + temp + dptp + rhum </td>
   <td style="text-align:left;"> death ~ o3 + temp + dptp + rhum </td>
  </tr>
  <tr>
   <td style="text-align:left;"> death ~ pm10 + temp + dptp + rhum + hmdx </td>
   <td style="text-align:left;"> death ~ o3 + temp + dptp + rhum + hmdx </td>
  </tr>
  <tr>
   <td style="text-align:left;"> death ~ pm10 + temp + dptp + rhum + hmdx + dow </td>
   <td style="text-align:left;"> death ~ o3 + temp + dptp + rhum + hmdx + dow </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cvd ~ pm10 + temp </td>
   <td style="text-align:left;"> cvd ~ o3 + temp </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cvd ~ pm10 + temp + dptp </td>
   <td style="text-align:left;"> cvd ~ o3 + temp + dptp </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cvd ~ pm10 + temp + dptp + rhum </td>
   <td style="text-align:left;"> cvd ~ o3 + temp + dptp + rhum </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cvd ~ pm10 + temp + dptp + rhum + hmdx </td>
   <td style="text-align:left;"> cvd ~ o3 + temp + dptp + rhum + hmdx </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cvd ~ pm10 + temp + dptp + rhum + hmdx + dow </td>
   <td style="text-align:left;"> cvd ~ o3 + temp + dptp + rhum + hmdx + dow </td>
  </tr>
  <tr>
   <td style="text-align:left;"> resp ~ pm10 + temp </td>
   <td style="text-align:left;"> resp ~ o3 + temp </td>
  </tr>
  <tr>
   <td style="text-align:left;"> resp ~ pm10 + temp + dptp </td>
   <td style="text-align:left;"> resp ~ o3 + temp + dptp </td>
  </tr>
  <tr>
   <td style="text-align:left;"> resp ~ pm10 + temp + dptp + rhum </td>
   <td style="text-align:left;"> resp ~ o3 + temp + dptp + rhum </td>
  </tr>
  <tr>
   <td style="text-align:left;"> resp ~ pm10 + temp + dptp + rhum + hmdx </td>
   <td style="text-align:left;"> resp ~ o3 + temp + dptp + rhum + hmdx </td>
  </tr>
  <tr>
   <td style="text-align:left;"> resp ~ pm10 + temp + dptp + rhum + hmdx + dow </td>
   <td style="text-align:left;"> resp ~ o3 + temp + dptp + rhum + hmdx + dow </td>
  </tr>
</tbody>
</table>

## Create the bootstrap samples

Create `boot_samples` with `sample` function using `lapply`.


```r
nBoot <- 10
set.seed(12345)
boot_samples <- lapply(1:nBoot, 
                       function(x) df[sample(1:nrow(df), replace = TRUE), ])
```

Examine the resulting list of dataframes.


```r
print(c(list.length = length(boot_samples), df1.dim = dim(boot_samples[[1]])))
```

```
## list.length    df1.dim1    df1.dim2 
##          10        5114          15
```

```r
colnames(boot_samples[[1]])
```

```
##  [1] "date"  "time"  "year"  "month" "doy"   "dow"   "death" "cvd"   "resp" 
## [10] "temp"  "dptp"  "rhum"  "pm10"  "o3"    "hmdx"
```

## Define a function to run models

Define a function to run models and return a data frame of model results.


```r
get_model_results <- function(.data, .formula, alpha = 0.05, weights = NULL) {
  # .data is a list of dataframes of bootstraps, .formula is model formula.
  # Credit: This function was modified from code by Cooper Schumacher.
  out <- list()
  out$formula <- .formula
  .formula <- as.formula(.formula)
  coefs <- as.data.frame(matrix(unlist(lapply(.data, function(y) {
        if (!is.null(weights)) lm(.formula, y, weights = weights)$coef
        else lm(.formula, y)$coef
      })), nrow = length(seq_along(.data)), byrow = TRUE))
  colnames(coefs) <- names(lm(.formula, .data[[1]])$coef)
  
  est <- apply(coefs, 2, mean)
  LCI <- apply(coefs, 2, function(z) quantile(z, alpha / 2))
  UCI <- apply(coefs, 2, function(z) quantile(z, 1 - alpha / 2))
  out$estimates <- data.frame(cbind(estimate = est, LCI = LCI, UCI = UCI))
  out
}
```

## Define functions to combine results

Define functions to combine the results into single dataframe with columns: 
model, variable, estimate, LCI, UCI.


```r
model_result_to_df <- function(.data) {
  # .data is a list containing a dataframe of estimates for one model.
  df <- .data$estimates
  df$variable <- rownames(df)
  df$model <- .data$formula
  df[, c("model", "variable", "estimate", "LCI", "UCI")]
}

combine_model_results <- function(.data) {
  # .data is a list of models, each with a list with a dataframe of estimates.
  df <- do.call('rbind', lapply(.data, model_result_to_df))
  df[order(df$model, df$variable), ]
}
```

## Run models and combine results

Run all models, extract the results, and combine them into a dataframe.


```r
model_results <- lapply(models, 
                        function(model) get_model_results(boot_samples, model))
df_results <- combine_model_results(model_results)
```

Filter to keep only those rows where `variable` contains the string "pm10".


```r
df_results_pm10 <- df_results[df_results$variable == 'pm10', ]
row.names(df_results_pm10) <- NULL
```

## View the results

<table class="table table-condensed" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> model </th>
   <th style="text-align:left;"> variable </th>
   <th style="text-align:right;"> estimate </th>
   <th style="text-align:right;"> LCI </th>
   <th style="text-align:right;"> UCI </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> cvd ~ pm10 + temp </td>
   <td style="text-align:left;"> pm10 </td>
   <td style="text-align:right;"> 0.0520236 </td>
   <td style="text-align:right;"> 0.0393346 </td>
   <td style="text-align:right;"> 0.0668540 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cvd ~ pm10 + temp + dptp </td>
   <td style="text-align:left;"> pm10 </td>
   <td style="text-align:right;"> 0.0511083 </td>
   <td style="text-align:right;"> 0.0383196 </td>
   <td style="text-align:right;"> 0.0662777 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cvd ~ pm10 + temp + dptp + rhum </td>
   <td style="text-align:left;"> pm10 </td>
   <td style="text-align:right;"> 0.0473119 </td>
   <td style="text-align:right;"> 0.0362884 </td>
   <td style="text-align:right;"> 0.0602035 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cvd ~ pm10 + temp + dptp + rhum + hmdx </td>
   <td style="text-align:left;"> pm10 </td>
   <td style="text-align:right;"> 0.0440634 </td>
   <td style="text-align:right;"> 0.0331879 </td>
   <td style="text-align:right;"> 0.0592219 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cvd ~ pm10 + temp + dptp + rhum + hmdx + dow </td>
   <td style="text-align:left;"> pm10 </td>
   <td style="text-align:right;"> 0.0437042 </td>
   <td style="text-align:right;"> 0.0331400 </td>
   <td style="text-align:right;"> 0.0582670 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> death ~ pm10 + temp </td>
   <td style="text-align:left;"> pm10 </td>
   <td style="text-align:right;"> 0.1145648 </td>
   <td style="text-align:right;"> 0.1014364 </td>
   <td style="text-align:right;"> 0.1313425 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> death ~ pm10 + temp + dptp </td>
   <td style="text-align:left;"> pm10 </td>
   <td style="text-align:right;"> 0.1163644 </td>
   <td style="text-align:right;"> 0.1036797 </td>
   <td style="text-align:right;"> 0.1333185 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> death ~ pm10 + temp + dptp + rhum </td>
   <td style="text-align:left;"> pm10 </td>
   <td style="text-align:right;"> 0.1087425 </td>
   <td style="text-align:right;"> 0.0965766 </td>
   <td style="text-align:right;"> 0.1236963 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> death ~ pm10 + temp + dptp + rhum + hmdx </td>
   <td style="text-align:left;"> pm10 </td>
   <td style="text-align:right;"> 0.1060289 </td>
   <td style="text-align:right;"> 0.0923862 </td>
   <td style="text-align:right;"> 0.1234868 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> death ~ pm10 + temp + dptp + rhum + hmdx + dow </td>
   <td style="text-align:left;"> pm10 </td>
   <td style="text-align:right;"> 0.1054414 </td>
   <td style="text-align:right;"> 0.0937138 </td>
   <td style="text-align:right;"> 0.1211341 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> resp ~ pm10 + temp </td>
   <td style="text-align:left;"> pm10 </td>
   <td style="text-align:right;"> 0.0104443 </td>
   <td style="text-align:right;"> 0.0076588 </td>
   <td style="text-align:right;"> 0.0131852 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> resp ~ pm10 + temp + dptp </td>
   <td style="text-align:left;"> pm10 </td>
   <td style="text-align:right;"> 0.0110167 </td>
   <td style="text-align:right;"> 0.0083609 </td>
   <td style="text-align:right;"> 0.0135813 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> resp ~ pm10 + temp + dptp + rhum </td>
   <td style="text-align:left;"> pm10 </td>
   <td style="text-align:right;"> 0.0122123 </td>
   <td style="text-align:right;"> 0.0089700 </td>
   <td style="text-align:right;"> 0.0154710 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> resp ~ pm10 + temp + dptp + rhum + hmdx </td>
   <td style="text-align:left;"> pm10 </td>
   <td style="text-align:right;"> 0.0137187 </td>
   <td style="text-align:right;"> 0.0108019 </td>
   <td style="text-align:right;"> 0.0167244 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> resp ~ pm10 + temp + dptp + rhum + hmdx + dow </td>
   <td style="text-align:left;"> pm10 </td>
   <td style="text-align:right;"> 0.0141906 </td>
   <td style="text-align:right;"> 0.0113721 </td>
   <td style="text-align:right;"> 0.0168547 </td>
  </tr>
</tbody>
</table>

## Appendix A: Alternate ways to render

### In the R console:

```
rmarkdown::render("chicago_pollution.Rmd")
```

### In the Terminal (Bash):

```
Rscript -e 'rmarkdown::render("chicago_pollution.Rmd")'
```

### In the Jobs tab:

* Create a R script containing: `rmarkdown::render("chicago_pollution.Rmd")`
* In the Jobs tab, click "Start Local Job" and configure to run R script.

## Appendix B: The "screen" utility

With the "screen" utility you can run multiple shell processes simultaneously.

* `screen` creates a new screen. (Use Ctrl+A D to detach.)
* `screen -S "NAME"` creates a new screen named "NAME".
* `screen -dmS "NAME" CMD` creates a screen "NAME", runs CMD, and detaches.
* `screen -r` connects to a running screen. (Or use `screen -r "NAME"`.)
* `screen -list` or `screen -ls` shows running screens.

![Use Ctrl+A D to detach from a screen.](ctrl-a-d_388x220.jpg)

## Appendix C: Read code with "source"

As an alternative to defining the function in the Rmd file as we did above, we
can also save the function in a separate file and import it using the `source`
function.


```r
source('model_lib.R')
```

This might be useful if the Rmd was exceedingly long and unwieldy to work with.

However, storing code separately like this may make it harder for others to 
follow or to verify reproducibility. One school of thought favors modularity 
for managability and code reuse, while the other prefers a monolithic approach.

## Discussion: "source" versus packages

If your functions are generally useful independently of this project, it may 
be wise to share them as a package insted of using `source`. What do you think?
