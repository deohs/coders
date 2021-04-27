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

# Create the SQLite database
con <- dbConnect(RSQLite::SQLite(), "brfss_data.sqlite")
dbWriteTable(con, "brfss", brfss)

# We don't have to read the whole database to use it, but let's time it anyway.
system.time(brfss_data <- dbReadTable(con, "brfss"))

##    user  system elapsed 
## 644.020  58.490 702.359 

# Remove the object to free the memory
rm("brfss_data")

# List tables in the database
dbListTables(con)

# Create a test query
query <- '
SELECT IYEAR AS Year, COUNT(*) AS Respondents
FROM brfss
GROUP BY IYEAR
ORDER BY IYEAR;
'

# Running this query the first time creates an index for later.
system.time(res <- dbGetQuery(con, query))

##  user  system elapsed 
## 2.719   5.393   8.109 

# Running a second time will likely be faster due to the index (and caching).
system.time(res <- dbGetQuery(con, query))

##  user  system elapsed 
## 2.403   2.636   5.035

dbDisconnect(con)

# Create the DuckDB database
con_duck <- dbConnect(duckdb::duckdb(), 'brfss_data.duckdb')
dbWriteTable(con_duck, "brfss", brfss)

# List tables in the database
dbListTables(con_duck)

# We don't have to read the whole database to use it, but let's time it anyway.
system.time(brfss_data <- dbReadTable(con_duck, "brfss"))

##    user  system elapsed 
##  63.605 304.157 367.658 

# Remove the object to free the memory
rm("brfss_data")

# This runs fast the first time because it's already indexed.
system.time(res <- dbGetQuery(con_duck, query))

##  user  system elapsed 
## 0.161   0.188   0.349 

# Running a second time may run faster due to caching.
system.time(res <- dbGetQuery(con_duck, query))

##  user  system elapsed 
## 0.140   0.000   0.141

dbDisconnect(con_duck)
