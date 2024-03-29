---
title: 'Data Cleaning in Base-R: WA WQI'
author: "Brian High"
date: "24 June, 2019"
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







## Using Base-R to Clean WA WQI 2013

Read the 2013 WA WQI file and parse coordinates into `lat` and `lon` using base-R.

Today's example demonstrates these objectives:

* Use a public dataset freely available on the web.
* Try various ways to clean up a dataset using only "base-R" functions.
* Use "regular expressions" to simplify data manipulation.
* Use "literate programming" to provide a reproducable report.
* Use a consistent coding [style](https://google.github.io/styleguide/Rguide.xml).
* Share code through a public [repository](https://github.com/deohs/coders) to 
  facilitate collaboration.

The code and this presentation are free to share and modify according to the 
[MIT License](https://github.com/deohs/coders/blob/master/LICENSE).

## Read the data

All five variations of cleanup will use the same dataset imported with:


```r
url <- 'https://data.wa.gov/api/views/h7j9-vgr3/rows.csv?accessType=DOWNLOAD'
wa_wqi <- read.csv(url)
str(wa_wqi, vec.len = 1)
```

```
## 'data.frame':	89 obs. of  16 variables:
##  $ ID             : int  3 4 ...
##  $ STATION        : Factor w/ 89 levels "01A050","01A120",..: 3 4 ...
##  $ STATION.NAME   : Factor w/ 89 levels "Abernathy Cr nr mouth",..: 65 57 ...
##  $ OVERALLWQI.2013: int  86 86 ...
##  $ WQIFC          : int  94 79 ...
##  $ WQIOXY         : int  82 77 ...
##  $ WQIPH          : int  92 93 ...
##  $ WQITSS         : int  66 87 ...
##  $ WQITEMP        : int  84 86 ...
##  $ WQITPN         : int  98 41 ...
##  $ WQITP          : int  89 84 ...
##  $ WQITURB        : int  85 87 ...
##  $ CORE           : Factor w/ 4 levels "B","C","P","S": 2 2 ...
##  $ CAT            : int  1 1 ...
##  $ Location.1     : Factor w/ 89 levels "POINT (-117.0352 48.1847)",..: 63 64 ...
##  $ Counties       : int  3212 3212 ...
```

## Variation 1: strsplit and lapply


```r
v1 <- wa_wqi
coords <- as.data.frame(do.call('rbind', strsplit(
    gsub('POINT |[()]', '', v1$Location.1), ' ')), stringsAsFactors = FALSE)
coords <- as.data.frame(lapply(coords, as.numeric), col.names = c('lon', 'lat'))
v1 <- cbind(v1, coords)

head(v1[, c('STATION', 'OVERALLWQI.2013', 'lon', 'lat')])
```

```
##   STATION OVERALLWQI.2013       lon     lat
## 1  03A060              86 -122.3352 48.4451
## 2  03B050              86 -122.3382 48.5458
## 3  04A100              75 -121.4290 48.5268
## 4  05A065              79 -122.2470 48.2100
## 5  05A070              79 -122.2101 48.1969
## 6  05A090              69 -122.1190 48.2007
```

```r
str(v1[ , c('lon', 'lat')])
```

```
## 'data.frame':	89 obs. of  2 variables:
##  $ lon: num  -122 -122 -121 -122 -122 ...
##  $ lat: num  48.4 48.5 48.5 48.2 48.2 ...
```

## Variation 2: strsplit and sapply


```r
v2 <- wa_wqi
coords <- data.frame(t(sapply(strsplit(trimws(
  gsub('[^0-9. -]', '', v2$Location.1)), ' '), as.numeric)))
names(coords) <- c('lon', 'lat')
v2 <- cbind(v2, coords)

head(v2[, c('STATION', 'OVERALLWQI.2013', 'lon', 'lat')])
```

```
##   STATION OVERALLWQI.2013       lon     lat
## 1  03A060              86 -122.3352 48.4451
## 2  03B050              86 -122.3382 48.5458
## 3  04A100              75 -121.4290 48.5268
## 4  05A065              79 -122.2470 48.2100
## 5  05A070              79 -122.2101 48.1969
## 6  05A090              69 -122.1190 48.2007
```

```r
str(v2[ , c('lon', 'lat')])
```

```
## 'data.frame':	89 obs. of  2 variables:
##  $ lon: num  -122 -122 -121 -122 -122 ...
##  $ lat: num  48.4 48.5 48.5 48.2 48.2 ...
```

## Variation 3: gsub (twice)


```r
# We can just copy, paste, and modify our gsub() code for each variable.
v3 <- wa_wqi
regex <- c(lon = '^.*\\(([0-9.-]+) .*$', lat = '^.*\\(.* ([0-9.-]+)\\)$')
v3$lon <- as.numeric(gsub(regex[['lon']], '\\1', v3$Location.1))
v3$lat <- as.numeric(gsub(regex[['lat']], '\\1', v3$Location.1))

head(v3[, c('STATION', 'OVERALLWQI.2013', 'lon', 'lat')])
```

```
##   STATION OVERALLWQI.2013       lon     lat
## 1  03A060              86 -122.3352 48.4451
## 2  03B050              86 -122.3382 48.5458
## 3  04A100              75 -121.4290 48.5268
## 4  05A065              79 -122.2470 48.2100
## 5  05A070              79 -122.2101 48.1969
## 6  05A090              69 -122.1190 48.2007
```

```r
str(v3[ , c('lon', 'lat')])
```

```
## 'data.frame':	89 obs. of  2 variables:
##  $ lon: num  -122 -122 -121 -122 -122 ...
##  $ lat: num  48.4 48.5 48.5 48.2 48.2 ...
```

## Variation 4: gsub and lapply


```r
# We can use lapply() to iterate through out regexs, applying gsub() to each.
v4 <- wa_wqi
regex <- c(lon = '^.*\\(([0-9.-]+) .*$', lat = '^.*\\(.* ([0-9.-]+)\\)$')
v4[, names(regex)] <- lapply(names(regex), function(x) {
  as.numeric(gsub(regex[[x]], '\\1', v4$Location.1)) })

head(v4[, c('STATION', 'OVERALLWQI.2013', 'lon', 'lat')])
```

```
##   STATION OVERALLWQI.2013       lon     lat
## 1  03A060              86 -122.3352 48.4451
## 2  03B050              86 -122.3382 48.5458
## 3  04A100              75 -121.4290 48.5268
## 4  05A065              79 -122.2470 48.2100
## 5  05A070              79 -122.2101 48.1969
## 6  05A090              69 -122.1190 48.2007
```

```r
str(v4[ , c('lon', 'lat')])
```

```
## 'data.frame':	89 obs. of  2 variables:
##  $ lon: num  -122 -122 -121 -122 -122 ...
##  $ lat: num  48.4 48.5 48.5 48.2 48.2 ...
```

## Variation 5: cbind and read.table


```r
# read.table() reads a file or a "text", splitting by a separator.
v5 <- wa_wqi
v5 <- cbind(v5, read.table(sep = ' ', col.names = c('lon', 'lat'), 
  text = gsub('^POINT \\((.*)\\)$', '\\1', v5$Location.1)))

head(v5[, c('STATION', 'OVERALLWQI.2013', 'lon', 'lat')])
```

```
##   STATION OVERALLWQI.2013       lon     lat
## 1  03A060              86 -122.3352 48.4451
## 2  03B050              86 -122.3382 48.5458
## 3  04A100              75 -121.4290 48.5268
## 4  05A065              79 -122.2470 48.2100
## 5  05A070              79 -122.2101 48.1969
## 6  05A090              69 -122.1190 48.2007
```

```r
str(v5[ , c('lon', 'lat')])
```

```
## 'data.frame':	89 obs. of  2 variables:
##  $ lon: num  -122 -122 -121 -122 -122 ...
##  $ lat: num  48.4 48.5 48.5 48.2 48.2 ...
```

## Compare results

Are the all of the variables indentical in all of the variations? Perform a 
pairwise comparison of the 1st variation against each of the others to find out.


```r
c(identical(v1, v2),
  identical(v1, v3),
  identical(v1, v4),
  identical(v1, v5))
```

```
## [1] TRUE TRUE TRUE TRUE
```

Since we generally do not like to copy and paste code over and over, we may 
prefer this alternative:


```r
sapply(list(v2, v3, v4, v5), 
       function(x) identical(v1, x))
```

```
## [1] TRUE TRUE TRUE TRUE
```

## Exercises

1. In Var. 1, what does `as.data.frame(do.call('rbind', ...` do and what is 
   the tidyverse replacement for this idiom? What does `as.data.frame(lapply( ...`
   do and what tidyverse function will accomplish this?
2. In Var. 2, what data structure does `strplit()` return? What did `sapply()` 
   do and why was `t()` needed?
3. In Var. 3, what are the two regular expressions doing. Explain each piece of
   each expression and what it matches.
4. In Var. 4, the method of Var. 3 was implemented using `lapply()`. Aside from
   wanting to avoid copy-and-paste, why would anyone want to go to the trouble?
5. In Var. 5, we did not need to use `as.numeric()` to set the correct variable 
   types as we did on the other 4 variations. How was this possible?
6. Are these results identical with those produced with tidyverse functions 
   `mutate()` and `separate()`?


```r
library(tidyverse)
v6 <- read_csv(url) %>% 
  mutate(Location.1 = gsub('POINT |[()]', '', `Location 1`)) %>%
  separate(col = Location.1, into = c('lon', 'lat'), sep = ' ', convert = TRUE)
identical(as_tibble(v1[, c('lat', 'lon')]), v6[, c('lat', 'lon')])
```

## Bonus

Try the various regular expressions used here, or your own, on 
[regex101.com](https://regex101.com/).

![](regex0.png) &nbsp;&nbsp;&nbsp;
![](regex3lon.png)

* In R, we have to use `\\` as the escape, but in most other languages, you 
  would use `\` instead. You will need to modify your R regular expressions 
  for them to work on regex101.com.
* In R, we refer to the matched replacement variables as `\\1`, `\\2`, etc. In
  most other languages this would be either `\1`, `\2`, etc. or `$1`, `$2`, etc.
  Again, we will need to make this adjustment for regex101.com.
