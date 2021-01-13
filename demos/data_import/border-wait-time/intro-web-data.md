---
title: "Web Data"
author: "Brian High and Tom Kiehne"
date: "13 January, 2021"
output:
  ioslides_presentation:
    fig_caption: yes
    fig_retina: 1
    fig_width: 5
    fig_height: 3
    keep_md: true
    smaller: false
    incremental: false
    logo: img/logo_128.png
    css: inc/deohs-ioslides-theme.css
    template: inc/deohs-default-ioslides.html
---



<!-- Note: Custom CSS changes title font and removes footer gradient. -->
<!-- Note: Custom HTML template replaces logo with banner on title page.-->

## Objectives

Today we will become familiar with:

- Web data sources (static and dynamic web pages, and files)
- Web data extraction (web-scraping, RSS, APIs)
- Web data formats (HTML, XML, JSON)
- R Tools (RCurl, xml2, rvest, RSelenium, jsonlite, etc.). 
- Common challenges

## Example web site

This presentation will use examples from:

- [CBP Border Wait Times](https://bwt.cbp.gov/) web site.

From this website, we will extract data to satisfy this request:

- Get border wait time data for the San Ysidro port of entry.

Sample code will be provided.

## Web data sources

We commonly need to extract data from:

- "Static" web pages where content is embedded in HTML
- "Dynamic" web pages are displayed on demand
- Document files available for download from a web server

Ideally, we can just download data as files. If not, we must extract it.

## Web data extraction

If we cannot simply download data files, we will need to extract using:

- Web-scraping: parsing web pages to extract content
- RSS: pulling data from a "feed" using a specific URL
- APIs: using a function library or crafting URLs to pull data

## Web data formats

Web content is most commonly presented through text data formats: 

- HTML: The "markup" language used for most web pages
- XML: A general and flexible markup language
- JSON: A simple format supporting hierarchical data

Which will I use?

- If you pull data with RSS, you will usually get XML.
- If you pull data with APIs, you will often get JSON.
- If you can't do any of the above, then you "web scrape" HTML.

## Example: Inspect a web site

Often we first need to examine a web site to see what it offers.

Explore the [CBP Border Wait Times](https://bwt.cbp.gov/) web site. 

Try to find border wait times for San Ysidro as presented in ...

- HTML
- XML
- JSON
- Document files or other useful formats

## R Tools for web data

We can use the following R packages:

- RCurl and httr: For web requests, supporting cookies, etc.
- XML and xml2: To get and parse XML content
- rvest: To parse HTML and XML content
- RSelenium: To automate the operation of a web browser
- rjson and jsonlite: To get and parse JSON

## Sample code

We can extract data from the [CBP Border Wait Times](https://bwt.cbp.gov/) web site using:

- xml2 to extract current data: [bwt.R](R/bwt.R)
- jsonlite to extract current data: [bwt2.R](R/bwt2.R)
- jsonlite to extract historical data: [bwt-historical.R](R/bwt-historical.R)

Since the BWT site does not offer a good web-scraping example, we use the CBP site:

- rvest to web-scrape media releases: [bwt-media-releases.R](R/bwt-media-releases.R)

## Common challenges

We often face the following challenges when web sites:

- Are designed only for viewing information with human eyes
- Requires authentication, cookies, and Javascript to navigate
- Requires clicking through numerous pages to get content
- APIs are not documented or not supported by libraries
- Have poorly formatted (e.g., tables are not HTML tables)
- Tables are not tidy (e.g., multiple column headings)
- Dynamic content is not embedded in the page itself
- Data result page does not have specific URL
- Data are not formatted as advertised (e.g., CSV is not CSV)
- Site policy does not allow automated data collection
