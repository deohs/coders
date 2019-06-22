---
title: 'Automating Downloads: NOAA Smoke Shapefiles'
author: "Brian High"
date: "22 June, 2019"
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







## Automating Downloads

Today's example demonstrates these objectives:

* Use a public dataset freely available on the web.
* Automate data processing from start to finish (importing to reporting).
* Use "web scraping" techniques to extract data from web pages.
* Create functions to modularize code and facilitate automation.
* Use "regular expressions" to match patterns and filter data.
* Use "literate programming" to provide a reproducable report.
* Use a consistent coding [style](https://google.github.io/styleguide/Rguide.xml).
* Share code through a public [repository](https://github.com/deohs/coders) to 
  facilitate collaboration.

We will be using the R language, but several other tools could do the job.

The code and this presentation are free to share and modify according to the 
[MIT License](https://github.com/deohs/coders/blob/master/LICENSE).

## Thousands of Shapefiles

Get daily smoke shapefiles from NOAA by year. We automate this task to 
avoid the tedium of downloading thousands of individual files manually.

We will download daily [Hazard Mapping System Fire and Smoke](https://www.ospo.noaa.gov/Products/land/hms.html) shapefiles from the 
[GOES Products Server](https://satepsanone.nesdis.noaa.gov/).

Since we will download several years of daily files, this amounts to several 
thousand files. It would be nice if NOAA offered a "zip" (compressed archive) 
file containing all files for each year, but they don't. You have to download 
each file individually, three per day. We will automate this tedious task.

_Credit: We thank Annie Doubleday for presenting us with this challenge._

## Web Scraping with `rvest`

We will use web scraping techniques to get a list of links for each year and 
then automate the process of downloading the files by following the links.

There are several R packages that facilitate web scraping. We will use 
[rvest](https://rvest.tidyverse.org/), which is part of the 
[tidyverse](https://www.tidyverse.org/).

Knowing how to find your way around the HTML in a web page is essential.

To extract data from a web page, you need to know where in the page the 
data will be found. That usually means finding a table or other page 
element that contains the data, plus some means of identifying that particular
element.

Ideally, the element will have an "id" or at least a "class" or other 
identifier. If not, you will have to get all elements of the type that contains 
your data, then choose among them by number or a pattern match. To select 
elements, use a [CSS selector](https://www.w3schools.com/cssref/css_selectors.asp) 
or [XPATH expression](https://www.w3schools.com/xml/xml_xpath.asp). 

You will then need to parse the content or extract attributes of the elements 
to get the data you want. `rvest` includes functions to help you do all of this, 
so let's get started.

## Setup

Load packages with `pacman` to auto-install any missing packages.


```r
# Load packages.
if (! suppressPackageStartupMessages(require(pacman))) {
  install.packages('pacman', repos = 'http://cran.us.r-project.org')
}
pacman::p_load(rvest, stringi)
```

We are loading:

* `rvest` for `read_html()`, `html_nodes()` and `html_attr()` -- [tidyverse](https://www.tidyverse.org/) functions for extracting data from web pages
* `stringi` for `%s+%` -- an operator like `+` (plus) that is shorthand for `paste()`

## Download the files

Running this code takes at least an hour. The chunk has been set to `eval=FALSE`.


```r
# Create the destination folder if it does not already exist.
data_dir <- file.path('data', 'smoke')
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

# For each year, load the index page, get a list of files and download them.
res <- sapply(seq(2006, 2017), function(year) { 
  URL <- "http://satepsanone.nesdis.noaa.gov" %s+%  
    "/pub/volcano/FIRE/HMS_ARCHIVE/" %s+% year %s+% "/GIS/SMOKE/"
  
  # Get all links from the index page that match our regular expression.
  regexp <- 'hms_smoke[0-9]{4}0[5-9]{1}[0-9]{2}\\.(dbf|shp|shx)\\.gz$'
  files <- read_html(URL) %>% html_nodes("a") %>% html_attr("href") %>% 
    grep(regexp, ., value=TRUE)
  
  # Be efficient: only download files we do not already have.
  sapply(files, function(file) {
    dest <- file.path(data_dir, file)
    if (!file.exists(dest)) download.file(URL %s+% file, dest, quiet = TRUE)
  })
})
```
