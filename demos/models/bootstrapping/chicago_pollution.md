---
title: "Many Models in Base-R"
author: "Brian High and Rachel Shaffer"
date: "28 April, 2020"
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
outcomes <- c("cvd", "death", "resp")

# Make vector of exposures
exposures <- c("o3", "pm10")

# Make formula of outcomes associated w/exposures for each possible combination
base_models <- paste0(outcomes, " ~ ", rep(exposures, each = length(outcomes)))
```

Here are the resulting base model formulas:


```r
base_models
```

```
## [1] "cvd ~ o3"     "death ~ o3"   "resp ~ o3"    "cvd ~ pm10"   "death ~ pm10"
## [6] "resp ~ pm10"
```

## Add the covariates to models

From a vector of covariates, create a vector of model formulas.


```r
# Make a vector of model covariates expanded as "A", "A + B", "A + B + C", etc.
sep <- ' + '
covariate <- c("temp", "dptp", "rhum", "hmdx", "dow")
covariates <- sapply(seq_along(covariate), 
                     function(i) paste(covariate[1:i], collapse = sep))

# Develop all combinations of exposures, outcomes, covariates 
models <- paste0(rep(base_models, each = length(covariates)), sep, covariates)
```

## View the models

<table class="table table-condensed" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Exposure = PM10 </th>
   <th style="text-align:left;"> Exposure = O3 </th>
  </tr>
 </thead>
<tbody>
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
length(boot_samples)
```

```
## [1] 10
```

```r
dim(boot_samples[[1]])
```

```
## [1] 5114   15
```

## Define a function to run models

Define a function to run models and return a data frame of model results.


```r
get_model_results <- function(.data, .formula, alpha = 0.05, weights = NULL) {
  # .data is a list of dataframes of bootstraps, .formula is model formula.
  # Credit: This function was modified from code by Cooper Schumacher.
  .model <- .formula
  .formula <- as.formula(.formula)
  coefs <- as.data.frame(matrix(unlist(lapply(.data, function(y) {
        if (!is.null(weights)) lm(.formula, y, weights = weights)$coef
        else lm(.formula, y)$coef
      })), nrow = length(seq_along(.data)), byrow = TRUE))
  colnames(coefs) <- names(lm(.formula, .data[[1]])$coef)
  
  est <- sapply(coefs, mean)
  LCI <- sapply(coefs, function(z) quantile(z, alpha / 2))
  UCI <- sapply(coefs, function(z) quantile(z, 1 - alpha / 2))
  model <- rep(.model, length(est))
  df <- data.frame(model = model, cbind(estimate = est, LCI = LCI, UCI = UCI),
                   stringsAsFactors = FALSE)
  df$variable <- rownames(df)
  rownames(df) <- NULL
  df[, c("model", "variable", "estimate", "LCI", "UCI")]
}
```

## Run the models

Run all models and combine the results into a dataframe.


```r
df_results <- do.call('rbind', lapply(models, function(model) {
  get_model_results(boot_samples, model)
}))
```

View the structure of the results dataframe.


```r
str(df_results, vec.len = 3)
```

```
## 'data.frame':	180 obs. of  5 variables:
##  $ model   : chr  "cvd ~ o3 + temp" "cvd ~ o3 + temp" "cvd ~ o3 + temp" ...
##  $ variable: chr  "(Intercept)" "o3" "temp" ...
##  $ estimate: num  52.6066 0.0893 -0.3473 52.6288 ...
##  $ LCI     : num  51.996 0.056 -0.375 51.3 ...
##  $ UCI     : num  53.086 0.117 -0.323 53.438 ...
```

## Define a function to show results


```r
show_results_table <- function(variable) {
  df_results_x <- df_results[df_results$variable == variable, ]
  rownames(df_results_x) <- NULL
  x_html <- knitr::kable(x = df_results_x, format = 'html')
  kable_styling(x_html, full_width = TRUE, bootstrap_options = 'condensed')
}
```

## O3 exposure model estimates

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
   <td style="text-align:left;"> cvd ~ o3 + temp </td>
   <td style="text-align:left;"> o3 </td>
   <td style="text-align:right;"> 0.0892533 </td>
   <td style="text-align:right;"> 0.0559730 </td>
   <td style="text-align:right;"> 0.1165423 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cvd ~ o3 + temp + dptp </td>
   <td style="text-align:left;"> o3 </td>
   <td style="text-align:right;"> 0.0890995 </td>
   <td style="text-align:right;"> 0.0536970 </td>
   <td style="text-align:right;"> 0.1208714 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cvd ~ o3 + temp + dptp + rhum </td>
   <td style="text-align:left;"> o3 </td>
   <td style="text-align:right;"> 0.0982199 </td>
   <td style="text-align:right;"> 0.0548249 </td>
   <td style="text-align:right;"> 0.1427525 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cvd ~ o3 + temp + dptp + rhum + hmdx </td>
   <td style="text-align:left;"> o3 </td>
   <td style="text-align:right;"> 0.0890608 </td>
   <td style="text-align:right;"> 0.0490651 </td>
   <td style="text-align:right;"> 0.1263183 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cvd ~ o3 + temp + dptp + rhum + hmdx + dow </td>
   <td style="text-align:left;"> o3 </td>
   <td style="text-align:right;"> 0.0984590 </td>
   <td style="text-align:right;"> 0.0558264 </td>
   <td style="text-align:right;"> 0.1374928 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> death ~ o3 + temp </td>
   <td style="text-align:left;"> o3 </td>
   <td style="text-align:right;"> 0.0897555 </td>
   <td style="text-align:right;"> 0.0529863 </td>
   <td style="text-align:right;"> 0.1264115 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> death ~ o3 + temp + dptp </td>
   <td style="text-align:left;"> o3 </td>
   <td style="text-align:right;"> 0.1092619 </td>
   <td style="text-align:right;"> 0.0719740 </td>
   <td style="text-align:right;"> 0.1515795 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> death ~ o3 + temp + dptp + rhum </td>
   <td style="text-align:left;"> o3 </td>
   <td style="text-align:right;"> 0.1286725 </td>
   <td style="text-align:right;"> 0.0804766 </td>
   <td style="text-align:right;"> 0.1953447 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> death ~ o3 + temp + dptp + rhum + hmdx </td>
   <td style="text-align:left;"> o3 </td>
   <td style="text-align:right;"> 0.1188298 </td>
   <td style="text-align:right;"> 0.0741806 </td>
   <td style="text-align:right;"> 0.1662666 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> death ~ o3 + temp + dptp + rhum + hmdx + dow </td>
   <td style="text-align:left;"> o3 </td>
   <td style="text-align:right;"> 0.1373464 </td>
   <td style="text-align:right;"> 0.0889970 </td>
   <td style="text-align:right;"> 0.1859659 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> resp ~ o3 + temp </td>
   <td style="text-align:left;"> o3 </td>
   <td style="text-align:right;"> 0.0108445 </td>
   <td style="text-align:right;"> 0.0052996 </td>
   <td style="text-align:right;"> 0.0192536 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> resp ~ o3 + temp + dptp </td>
   <td style="text-align:left;"> o3 </td>
   <td style="text-align:right;"> 0.0162771 </td>
   <td style="text-align:right;"> 0.0097483 </td>
   <td style="text-align:right;"> 0.0251458 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> resp ~ o3 + temp + dptp + rhum </td>
   <td style="text-align:left;"> o3 </td>
   <td style="text-align:right;"> 0.0211066 </td>
   <td style="text-align:right;"> 0.0088621 </td>
   <td style="text-align:right;"> 0.0285830 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> resp ~ o3 + temp + dptp + rhum + hmdx </td>
   <td style="text-align:left;"> o3 </td>
   <td style="text-align:right;"> 0.0287108 </td>
   <td style="text-align:right;"> 0.0154216 </td>
   <td style="text-align:right;"> 0.0372056 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> resp ~ o3 + temp + dptp + rhum + hmdx + dow </td>
   <td style="text-align:left;"> o3 </td>
   <td style="text-align:right;"> 0.0301120 </td>
   <td style="text-align:right;"> 0.0170970 </td>
   <td style="text-align:right;"> 0.0376039 </td>
  </tr>
</tbody>
</table>

## PM10 exposure model estimates

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
