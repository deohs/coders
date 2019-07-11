# wa_wqi

This folder contains scripts for data collection and cleanup of data from the 
WA State Department of Ecology's [River and Stream Monitoring Program](https://ecology.wa.gov/Research-Data/Monitoring-assessment/River-stream-monitoring).

These two Markdown documents show process of two different datasets found on
data.gov:

* [WA WQI with Tidyverse](get_wa_wqi.md)
* [WA WQI Alternate Dataset](get_wa_wqi_alt.md)

This document shows processing of the first dataset using only base-R functions:

* [WA WQI with base-R](get_wa_wqi_2013_with_base_R.md)

This document shows how to use "web scraping" to read the station list from a web page:

* [WA WQI Stations](get_wa_wqi_stations.md)

This document shows how to get station details and WQI data with web scraping:

* [WA WQI Station Details and WQI Data](get_wa_wqi_per_station.md)

This script goes through some checks to compare all of the above datasets.

* [Compare WA WQI 2013 datasets](compare_stations_2013_wa_wqi.R)
