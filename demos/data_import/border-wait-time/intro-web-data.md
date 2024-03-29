---
title: "Web Data"
author: "Brian High and Tom Kiehne"
date: "08 February, 2021"
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

## What is the Web?

Using the HyperText Transfer Protocol (http or https), we:

- send commands via a client (browser, script, etc.)...
- over a network (using TCP/IP) to a server...
- and receive structured text in response...
- that is processed by the client

Some definitions:

- HTTP command = Uniform Resource Locator (URL)
- Structured text = a stream of characters that contains markup or metadata that conforms to a convention

## Structured text & HTML

- Structured text can be any of a littany of formats (e.g.: text, PDF, proprietary formats, video, audio, etc.)
- Default for the Web is typically HyperText Markup Language (HTML)
- What does it look like?
  - Go to the [U.S. Customs and Border Protection Newsroom](https://www.cbp.gov/newsroom/media-releases/all)
  - Right-click in window to "View Source" in your browser
  - Explore the markup
- HTML is good for visual display of information, not as good for data

## Structured text & XML

- XML is a sibling of HTML meant for data exchange (e.g. [RSS](https://en.wikipedia.org/wiki/RSS))
- XML formats are often explicit and rigid in their structure
- Browsers can display XML, but the format is meant for non-visual use:
  - Go to [CBP Border Wait Times](https://bwt.cbp.gov/)
  - Find and click "XML" in the header
  - Right-click in window to "View Source" in your browser
  - Compare with the HTML we saw previously
- Not as universal as CSV, but much better than HTML for data

Note: [RSS](https://en.wikipedia.org/wiki/RSS) stands for "Really Simple Syndication".

## "Dynamic" Web sites

As Web technologies matured and computing power increased, the emphasis shifted to client-side scripting via Javascript

- Go back to [CBP Border Wait Times](https://bwt.cbp.gov/)
- Right-click and select "Inspect" (or press F12 key)
- This is the "Inspector" which shows the page markup as rendered and manipulated in the client
- Compare to "View Source"

The content that is displayed is not what was originally returned in the server response!

Click the "Network" tab in Inspector to see what happened...

## Strutured text & JSON

Filter the Network requests by clicking XHR (XML Http Request)

You can now see the structured data retrieved by the client-side application from an [API](https://en.wikipedia.org/wiki/API).

This is a serialized representation of Javascript data structure called [JSON](https://www.json.org/). Compare with the XML data we saw earlier.

Still not as universal as CSV, but about as good as XML for data

Notes:

- [API](https://en.wikipedia.org/wiki/API) stands for "application programming interface".
- [JSON](https://www.json.org/) stands for "JavaScript Object Notation".

## Which will I use?

- If the Web site publishes data files (CSV, etc.), use that
- If the site has an API with XML or JSON data, use that
- If you can't do any of the above, then you "web scrape" HTML.

Exercise: Explore the [CBP Border Wait Times](https://bwt.cbp.gov/) Web site to see what's available.

## R Tools for web data

We can use the following R packages:

- RCurl and httr: For web requests, supporting cookies, etc.
- xml2 and rvest: To get and parse XML and HTML content
- jsonlite and rjson: To get and parse JSON

There is some overlap in functionality of these packages.

Usually rvest, xml2, and jsonlite will be sufficient.

## Sample code

We can extract data from the [CBP Border Wait Times](https://bwt.cbp.gov/) Web site using:

- xml2 to extract current data: [bwt.R](R/bwt.R)
- jsonlite to extract current data: [bwt2.R](R/bwt2.R)
- jsonlite to extract historical data: [bwt-historical.R](R/bwt-historical.R)

Since the BWT site does not offer a good web-scraping example, we use the CBP site:

- rvest to web-scrape media releases: [bwt-media-releases.R](R/bwt-media-releases.R)

## Common challenges

We often face the following challenges when Web sites:

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
