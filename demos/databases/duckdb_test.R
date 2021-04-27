# Compare data read times for "rds", "sqlite", and "duckdb" files.
# Data source: https://www.cdc.gov/brfss/annual_data/annual_data.htm
# For R code to download BRFSS, see: https://github.com/brianhigh/brfss
#
# Size of BRFSS "data.table" for years 2012-2019 is 21076 MB in memory.
# Size of dataset is   343 MB as (compressed) "rds" file.
# Size of dataset is  3180 MB as "sqlite" file.
# Size of dataset is 17567 MB as "duckdb" file. (Larger size due to indexing.)
# Dataset contains 3665603 observations and 764 variables.
#
# Summary of results:
#
# - readRDS is much faster than Sqlite but not much faster than DuckDB.
# - DuckDB is much faster than SQlite when reading entire tables.
# - DuckDB is much faster than SQlite when running queries.

# Load packages
if (!require(pacman)) install.packages("pacman")
pacman::p_load(data.table, DBI, RSQLite, duckdb)

# Read "rds" file
system.time(brfss <- readRDS(file.path("data", "brfss_data.rds")))

##   user  system elapsed 
## 67.032  10.699  77.705 

# Create the SQLite database
con <- dbConnect(RSQLite::SQLite(), "brfss_data.sqlite")
dbWriteTable(con, "brfss", brfss)

# We don't have to read the whole database to use it, but let's time it anyway.
system.time(brfss_data <- dbReadTable(con, "brfss"))

##    user  system elapsed 
## 651.522  57.603 708.933 

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
## 2.673   3.796   6.467 

# Running a second time will likely be faster due to the index (and caching).
system.time(res <- dbGetQuery(con, query))

##  user  system elapsed 
## 2.478   2.615   5.092

# Close the connection
dbDisconnect(con)

# Create the DuckDB database
con_duck <- dbConnect(duckdb::duckdb(), 'brfss_data.duckdb')
dbWriteTable(con_duck, "brfss", brfss)

# List tables in the database
dbListTables(con_duck)

# We don't have to read the whole database to use it, but let's time it anyway.
system.time(brfss_data <- dbReadTable(con_duck, "brfss"))

##    user  system elapsed 
##  41.850  41.608  83.380 

# Remove the object to free the memory
rm("brfss_data")

# This runs fast the first time because it's already indexed.
system.time(res <- dbGetQuery(con_duck, query))

##  user  system elapsed 
## 0.152   0.000   0.153 

# Running a second time may run faster due to caching.
system.time(res <- dbGetQuery(con_duck, query))

##  user  system elapsed 
## 0.148   0.000   0.147

# Close the connection
dbDisconnect(con_duck, shutdown=TRUE)
