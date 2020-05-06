---
title: 'Building R Packages'
author: "Brian High"
date: "05 May, 2020"
output:
  ioslides_presentation:
    fig_caption: yes
    fig_retina: 1
    fig_width: 5
    fig_height: 3
    keep_md: yes
    smaller: yes
    template: ../../../templates/ioslides_template.html
  html_document:
    template: ../../../templates/html_template.html
editor_options: 
  chunk_output_type: console
---







## Building R Packages

Today's example demonstrates these objectives:

* [Create an R package](https://hub.packtpub.com/how-to-create-your-own-r-package-with-rstudio-tutorial/) from some functions [using RStudio](https://support.rstudio.com/hc/en-us/articles/200486488-Developing-Packages-with-RStudio).
* Use [Roxygen comments](http://r-pkgs.had.co.nz/man.html) to generate package documentation.
* Include working examples for functions.
* Publish the package to Github.

The code and this presentation are free to share and modify according to the 
[MIT License](https://github.com/deohs/coders/blob/master/LICENSE).

## What's in an R package?

Normally, you will want to create a package from functions you find generally 
useful.

You may also include small data files for use in examples.

Some packages just offer data files, such as the `datasets` package.

All packages should have documentation for each function and dataset included.

## Requirements

You need to have the following packages installed to create R packages:

* `devtools`
* `roxygen2`

## Example: Many Models

We will build a package called `many.models` from two functions:


```r
extract.elem <- function(.data, .formula, .fun, elem, ...) {
  as.data.frame(do.call('rbind', lapply(.formula, function(f) {
    df <- as.data.frame(
      do.call(.fun, list(formula = quote(f), data = .data, ...))[[elem]])
    names(df) <- c('value')
    df$variable <- row.names(df)
    df$formula <- f
    row.names(df) <- NULL
    df
  })), optional = TRUE)
}

elem.to.wide <- function(.data) {
  df.wide <- stats::reshape(.data, 
                 timevar = 'variable', 
                 idvar = 'formula', 
                 direction = 'wide')
  names(df.wide) <- gsub('^value\\.', '', names(df.wide))
  row.names(df.wide) <- NULL
  df.wide
}
```

## Example usage: `extract.elem`

To see what these functions do, let's look at a simple example.


```r
library(datasets)
data(mtcars)

formulas <- c('mpg ~ cyl', 'mpg ~ cyl + disp', 'mpg ~ cyl + disp + hp')
df <- extract.elem(.data = mtcars, .formula = formulas, 
                   .fun = 'lm', elem = 'coefficients')
df
```

```
##         value    variable               formula
## 1 37.88457649 (Intercept)             mpg ~ cyl
## 2 -2.87579014         cyl             mpg ~ cyl
## 3 34.66099474 (Intercept)      mpg ~ cyl + disp
## 4 -1.58727681         cyl      mpg ~ cyl + disp
## 5 -0.02058363        disp      mpg ~ cyl + disp
## 6 34.18491917 (Intercept) mpg ~ cyl + disp + hp
## 7 -1.22741994         cyl mpg ~ cyl + disp + hp
## 8 -0.01883809        disp mpg ~ cyl + disp + hp
## 9 -0.01467933          hp mpg ~ cyl + disp + hp
```

## Example usage: `elem.to.wide`

The second function is just for reshaping.


```r
df.wide <- elem.to.wide(df)
df.wide
```

```
##                 formula (Intercept)       cyl        disp          hp
## 1             mpg ~ cyl    37.88458 -2.875790          NA          NA
## 2      mpg ~ cyl + disp    34.66099 -1.587277 -0.02058363          NA
## 3 mpg ~ cyl + disp + hp    34.18492 -1.227420 -0.01883809 -0.01467933
```

## More examples

These functions were written to be flexible. Here we see some variations on 
their use.


```r
df.residuals <- extract.elem(.data = mtcars, .formula = formulas, 
                             .fun = 'lm', elem = 'residuals')

set.seed(1)
weights <- c(abs(rnorm(nrow(mtcars))))

df.weighted <- extract.elem(.data = mtcars, .formula = formulas, 
                            .fun = 'lm', elem = 'coefficients',
                            weights = weights)

df.inv.gauss <- extract.elem(.data = mtcars, .formula = formulas, 
                             .fun = 'glm', elem = 'coefficients',
                             family = 'inverse.gaussian')
```

## Building the package

Here are the steps we will take:

1. Save each function in it's own file.
2. Create a new RStudio project, selecting:

     "File" -> "New Project" -> "New Directory" -> "R Package"

3. Type in the package name of "many.models".
4. Add the function files to the package.
5. Check the checkbox for "Create a git repository".
6. Click "Create Project".

## Adding documentation

We will add documention by:

1. Editing the DESCRIPTION file.
2. Adding a LICENSE file.
3. Adding Roxygen comments to the R files.
4. Include examples with Roxygen comments.
5. Add a `README.md file` (optional but recommended).

## Building the package

First, we will test the package with: 

     "Build" -> "Test Package"
     
Then we will build the package with: 

     "Build" -> "Clean and Rebuild"

This will generate the Markdown files (*.md) for the function help files from 
the Roxygen comments we added to the functions.

Then it will build the package and install it into our local system.

## Testing the package

We can test the package by viewing the help and running the examples.


```r
?extract.elem
?elem.to.wide
example("elem.to.wide", "many.models")
```

## Posting to Github

We will post to Github by:

1. Creating an empty repository on Github
2. Adding files with the Terminal command `git add .`
3. Committing with `git commit -m 'First commit.'`
4. Adding an "origin" with: 

     `git remote add origin https://github.com/username/reponame`

5. Pushing the commit with: `git push origin master`

## Testing the package again

We can install the package to a different environment, like a different 
computer, and test as before:


```r
pacman::p_load_gh("brianhigh/many.models")

# Or:
#devtools::install_github("brianhigh/many.models")
#library(many.models)

?extract.elem
?elem.to.wide
example("elem.to.wide", "many.models")
```
