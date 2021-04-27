# Compare data read times for "rds", "sqlite", and "duckdb" files.
# Data source: https://www.cdc.gov/brfss/annual_data/annual_data.htm
# For R code to download BRFSS, see: https://github.com/brianhigh/brfss
#
# Size of BRFSS "data.table" for years 2012-2018 is 16973.8 MB in memory.
# Size of dataset is   342.8 MB as (compressed) "rds" file.
# Size of dataset is  3179.6 MB as "sqlite" file.
# Size of dataset is 17596.0 MB as "duckdb" file. (Large size due to indexing.)
# Dataset contains 3247335 observations and 685 variables.
#
# Summary of results:
#
# - readRDS is much faster at reading than Sqlite but not faster than DuckDB.
# - DuckDB is much faster than SQlite when reading entire tables.
# - DuckDB is much faster than SQlite when running new queries.
# - DuckDB is faster than SQlite for queries which have been run before.

# Load packages
if (!require(pacman)) install.packages("pacman")
pacman::p_load(data.table, DBI, RSQLite, duckdb)

# Read "rds" file
system.time(brfss <- readRDS(file.path("data", "brfss_data.rds")))

##   user  system elapsed 
## 51.987  14.104  66.076 

con <- dbConnect(RSQLite::SQLite(), "brfss_data.sqlite")
dbWriteTable(con, "brfss", brfss)
system.time(brfss_data <- dbReadTable(con, "brfss"))

##    user  system elapsed 
## 644.020  58.490 702.359 

query <- '
SELECT IYEAR AS Year, COUNT(*) AS Respondents
FROM brfss
GROUP BY IYEAR
ORDER BY IYEAR;
'

# Running this query the first time creates an index for later.
system.time(res <- dbGetQuery(con, query))

##  user  system elapsed 
## 2.829   4.985   7.812 

# Running a second time will be faster because of the new index (and caching).
system.time(res <- dbGetQuery(con, query))

##  user  system elapsed 
## 2.608   2.553   5.159

dbDisconnect(con)

con_duck <- dbConnect(duckdb::duckdb(), 'brfss_data.duckdb')
dbWriteTable(con_duck, "brfss", brfss)
system.time(brfss_data <- dbReadTable(con_duck, "brfss"))

##    user  system elapsed 
##  63.605 304.157 367.658 

# This runs fast the first time because it's already indexed.
system.time(res <- dbGetQuery(con_duck, query))

##  user  system elapsed 
## 0.168   0.000   0.168 

# Running a second time may (or may not) run faster because of caching.
system.time(res <- dbGetQuery(con_duck, query))

##  user  system elapsed 
## 0.152   0.000   0.152

dbDisconnect(con_duck)
