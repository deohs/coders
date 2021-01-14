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

- Web data sources (web pages and files)
- Web data extraction (web-scraping, RSS, APIs)
- Web data formats (HTML, XML, JSON)
- R Tools (RCurl, xml2, rvest, jsonlite, etc.). 
- Common challenges

## Example web site

This presentation will use examples from:

- [CBP Border Wait Times](https://bwt.cbp.gov/) web site.

From this website, we will extract data to satisfy this request:

- Get border wait time data for the San Ysidro port of entry.

Sample code will be provided.

## Web data sources

We commonly need to extract data from:

- "Static" web pages where content is stored in HTML files
- "Dynamic" pages that show data from databases on demand
- Document files available for download from a web server

Ideally, we can download data as well-structured files.

If not, we must extract it from web pages.

## Web data extraction

Most web data extraction uses one of these methods:

- Web-scraping: parsing web pages to extract content
- RSS: pulling data from a "feed" using a specific URL
- APIs: using a function library or crafting URLs to pull data

Notes:

- [RSS](https://en.wikipedia.org/wiki/RSS) stands for "Really Simple Syndication".
- [API](https://en.wikipedia.org/wiki/API) stands for "application programming interface".

## Web data formats

Web content is most commonly presented through text data formats: 

- HTML: The "markup" language used for most web pages
- XML: A general and flexible markup language
- JSON: A simple format supporting hierarchical data

Which will I use?

- If you pull data with RSS, you will usually get XML.
- If you pull data with APIs, you will usually get XML or JSON.
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
- xml2 and rvest: To get and parse XML and HTML content
- jsonlite and rjson: To get and parse JSON

There is some overlap in functionality of these packages.

Usually rvest, xml2, and jsonlite will be sufficient.

## Sample code

We can extract data from the [CBP Border Wait Times](https://bwt.cbp.gov/) web site using:

- xml2 to extract current data: [bwt.R](R/bwt.R)
- jsonlite to extract current data: [bwt2.R](R/bwt2.R)
- jsonlite to extract historical data: [bwt-historical.R](R/bwt-historical.R)

Since the BWT site does not offer a good web-scraping example, we use the CBP site:

- rvest to web-scrape media releases: [bwt-media-releases.R](R/bwt-media-releases.R)

## Common challenges

We often face the following challenges when web sites:

- Are designed for viewing information with human eyes only
- Require authentication, cookies, and Javascript to navigate
- Require clicking through numerous pages to get content
- Have undocumented APIs or APIs without R package support
- Have poor HTML (e.g., tables are not HTML tables)
- Have untidy tables (e.g., multiple column headings)
- Have content that is passed dynamically through Javascript
- Have data result pages without specific URLs
- Have data not formatted as advertised (e.g., CSV is not CSV)
- Have policies not allowing automated data collection