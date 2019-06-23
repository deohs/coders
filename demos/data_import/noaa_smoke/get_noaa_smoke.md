---
title: 'Automating Downloads: NOAA Smoke Shapefiles'
author: "Brian High"
date: "23 June, 2019"
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

Our task:

__Get all "hms_smoke" files ending in .dbf, .shp, and .shx from May-September for the years 2008-2017.__

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
res <- sapply(seq(2008, 2017), function(year) { 
  URL <- "http://satepsanone.nesdis.noaa.gov" %s+%  
    "/pub/volcano/FIRE/HMS_ARCHIVE/" %s+% year %s+% "/GIS/SMOKE/"
  
  # Get all links from the index page that match our regular expression.
  # Need dbf, shp, and shx files from May-September for the years 2008-2017.
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

## The regular expression

We used this regular expression to filter our file links for a specific pattern.


```r
regexp <- 'hms_smoke[0-9]{4}0[5-9]{1}[0-9]{2}\\.(dbf|shp|shx)\\.gz$'
```

We can decode this expression as follows:

* Contains the string `hms_smoke` followed by ...
* 4 digits (year), a `0` and 1 digit from `5-9` (month) and 2 digits (day) and ...
* A (literal) period (escaped with `\\`) and one of three filename suffixes and...
* A (literal) period (escaped with `\\`) and the file suffix `gz` and ...
* The very end of the string (`$`) with no characters following.

## Exercises

1. Go through the code and make sure you understand how it works. Look the the
   online help for each function you are unsure of, including what parameters 
   are being used, the values being supplied to them, and what they return. 
   Run parts of the code with test variables to confirm your understanding.
2. Look at the strucure of the web page we are using to fetch the links. You
   view the source of a web page using Ctrl-U (or Cmd-U on a Mac) or you can 
   use the "developer console" included in some web browsers. Find the links 
   that we are extracting and locate the HTML tags (elements) we used (and 
   their attributes) so you can see how the content extraction worked. Try 
   alternate CSS selectors or XPATH expressions to obtain the same results.
3. Try alternate regular expressions with `grep()` to achieve the same results, 
   or modify your code to extract different types of links. 
4. Try using a CSS selector or an XPATH expression to grab only the
   links that start with 'hms_smoke'. (There is a special syntax for this.)
5. Look at the structure of the code we have for this. Find where there are 
   two functions embedded in the code. Rewrite the code so those two functions 
   are defined separately from the `sapply()` function calls which invoke them.
   That is, define them outside of the `sapply()` calls and give them function
   names. Call those functions from within the `sapply()` calls. What benefit 
   is there to this this approach?

## Alternative: Using `wget` in Bash

Since there is a sytem utility for automating bulk downloading called 
[wget](https://www.gnu.org/software/wget/) that can be run from a `Bash` 
shell or script, this task is easier to do in `Bash` than in `R`. (Well, 
technically, you can also run `wget` from within R, as you can with many 
languages.)


```bash
#!/bin/bash
# Get daily SMOKE files from May through Sept. for the years 2008-2017.
URL='http://satepsanone.nesdis.noaa.gov/pub/volcano/FIRE/HMS_ARCHIVE'
regex='hms_smoke[0-9]{4}0[5-9]{1}[0-9]{2}\.(dbf|shp|shx)\.gz$'
for YEAR in $(seq 2008 2017); do \
  wget -r -nc -nH --cut-dirs=6 -np --accept-regex "$regex" "$URL/$YEAR/GIS/SMOKE/"
done
```

The `wget` options used above are:

* `-r`, `--recursive` ... Descend (and maybe ascend) into the file heirarchy.
* `-nc`, `--no-clobber` ... Don't download a file again if you already have it.
* `-nH`, `--no-host-directories` ... Omit the hostname in the saved file path.
* `--cut-dirs=n` ... Skip the top `n` levels of the heirarchy when saving files.
* `-np`, `--no-parent` ... Don't ascend when retrieving recursively
* `--accept-regex` ... Filename must match regular expression provided.

## Alternative: Using `scrapy` in Python

```
import re, os.path, urlparse, scrapy
from scrapy.http import Request
from scrapy.crawler import CrawlerProcess

class get_hms_shapefiles(scrapy.Spider):
    """Get daily SMOKE files from May through Sept. for the years 2008-2017."""
    name = "get_hms_shapefiles"
    domain = "satepsanone.nesdis.noaa.gov"
    allowed_domains = [domain]
    start_urls = [ "http://%s/pub/volcano/FIRE/HMS_ARCHIVE/%s/GIS/SMOKE/" %
                     (domain, year) for year in range(2008, 2017) ]

    def parse(self, response):
        for href in response.xpath('//a/@href').extract():
            regexp = r'hms_smoke[0-9]{4}0[5-9]{1}[0-9]{2}\.(dbf|shp|shx)\.gz$'
            if re.match(regexp, href):
                yield Request(url=response.urljoin(href), callback=self.save_file)

    def save_file(self, response):
        path = response.url.split('/')[-1]
        if not os.path.exists(path):
            with open(path, 'wb') as f: f.write(response.body)

process = CrawlerProcess()
process.crawl(get_hms_shapefiles) & process.start()
```
