# Demonstrate parallel package with mclapply with splitting by workers

# Clear the workspace
rm(list = ls())

# Unload any loaded packages and then load required packages
if (!require(pacman)) install.packages("pacman")
pacman::p_unload(pacman::p_loaded(), character.only = TRUE)
pacman::p_load(parallel, robustbase, MASS)

# Setup
workers <- 8   # number of CPU cores available
R <- 10000     # number of replicates

# Define a function that will take some time to process
#
# Calculate robust covariance given a dataframe
rc <- function(df) {
  covMcd(df, cor = TRUE)$cor[1, 2]
}
#
# Calculate robust covariance given a list of dataframes
rc_list <- function(df.list) {
  lapply(df.list, rc)
}

# Get data
data(Cars93, package = "MASS")
n <- nrow(Cars93)

# Create bootstraps (using a single core)
set.seed(1)
system.time(df.boot <- lapply(1:R, function(x) {
  Cars93[sample(1:n, replace=TRUE), c("Price", "Horsepower")]
}))

## 1.42 seconds elapsed time

# Create bootstraps (using multiple cores)
set.seed(1)
system.time(df.boot <- mclapply(1:R, function(x) {
  Cars93[sample(1:n, replace=TRUE), c("Price", "Horsepower")]
}, mc.cores = workers))

## 0.48 seconds elapsed time

# For time comparison, run the operation using a single core first
system.time(rc.boot_single <- lapply(df.boot, rc))

## 73.42 seconds elapsed time

# Total replicates (R) is much greater than the number of workers
system.time(rc.boot <- mclapply(df.boot, rc, mc.cores = workers))

## 10.11 seconds elapsed time

# Splitting replicates by number of workers should speed up processing
df.split <- split(df.boot, rep_len(1:workers, length(1:R)))
system.time(rc.boot2 <- mclapply(df.split, rc_list, mc.cores = workers))

## 10.20 seconds elapsed time

## This was a little slower, but should be a little faster

# Compare results
rc.boot <- sort(unlist(rc.boot, use.names = FALSE))
rc.boot2 <- sort(unlist(rc.boot2, use.names = FALSE))
identical(rc.boot, rc.boot2)

## The results are identical
