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

# Calculate robust covariance foreach bootstrap using a single core
rc <- function(X.seq) {
  data(Cars93, package = "MASS")
  n <- nrow(Cars93)
  
  sapply(X.seq, function(x) {
    covMcd(Cars93[sample(1:n, replace=TRUE),
      c("Price", "Horsepower")], cor = TRUE)$cor[1,2]
  })
}

# For comparison, time the operation using a single core first
system.time(rc_boot_single <- lapply(1:R, rc))

## 93 seconds elapsed time

# Total replicates (R) is much greater than the number of workers
system.time(rc_boot <- mclapply(1:R, rc, mc.cores = workers))

## 12 seconds elapsed time (8x speed improvement)

# Splitting replicates by number of workers will speed up processing
X.split <- split(1:R, rep_len(1:workers, length(1:R)))
system.time(rc_boot2 <- mclapply(X.split, rc, mc.cores = workers))

## 10 seconds elapsed time (1.2x speed improvement)
