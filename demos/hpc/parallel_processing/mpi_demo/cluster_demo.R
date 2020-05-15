# Cluster computing with "parallel" and "BiocParallel" packages.
#
# Example developed from "Simulation for Data Science with R" (Templ, 2016). 
# Book (Packt): https://bit.ly/2LsAHov Ch2 code (Github): https://bit.ly/3dLh3jJ
#
# Aside from packages loaded with "library", you will also need to install:
# - MASS
# - rlecuyer
# - Rmpi
# - robustbase

# Load packages
library(parallel)
library(BiocParallel)

# --------------
# Configuration
# --------------

# Initialize variables
skip_serial_boot <- TRUE
seed <- 123
cl_type <- ""
slots <- 0
R <- 0

# Assign variables from command-line arguments if present and valid
args <- (commandArgs(TRUE))
if(length(args) == 0){
  print("No command-line arguments supplied.")
} else {
  for(i in 1:length(args)){
    eval(parse(text=args[[i]]))
  }
}

# If "cl_type" is not valid, use "SOCK"
if (! (cl_type %in% c("SOCK", "MPI")) ) cl_type <- "SOCK"

# If the number of slots (slaves) is not valid, use 2
slots <- as.integer(slots)
if (slots <= 0) slots <- 2

# If the number of bootsreaps is not valid, use 10000
R <- as.integer(R)
if (R <= 0) R <- 10000

results_filename <- paste("rob_cov_test", R, slots, cl_type, ".csv", sep = "_")

# -----------------
# Define Functions
# -----------------

# Calculate robust covariance foreach bootstrap using a single core
f <- function(X.seq, ...) {
  # suppressPackageStartupMessages(require(robustbase))
  
  data(Cars93, package = "MASS")
  n <- nrow(Cars93)
  
  sapply(X.seq, function(x) {
    robustbase::covMcd(Cars93[sample(1:n, replace=TRUE),
                              c("Price", "Horsepower")], cor = TRUE)$cor[1,2]
  })
}

# Summarize results
quant.fun <- function(x, alpha = 0.05) {
  quantile(x, probs = c(alpha / 2, 1 - alpha / 2))
}

# Create empty results data frame
create_results_df <- function() {
  data.frame(
    R = as.numeric(NULL),
    cl_type = as.character(NULL),
    package = as.character(NULL),
    fun = as.character(NULL),
    elapsed = as.numeric(NULL),
    `2.5%` = as.numeric(NULL),
    `97.5%` = as.numeric(NULL),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}

# Combine results into a data frame
combine_results <- function(cl_type, package, fun, elapsed, ci, dec = 5) {
  data.frame(R = R, slots = slots, cl_type = cl_type, 
             package = package, fun = fun, elapsed = round(elapsed, dec), 
             t(round(ci, dec)), stringsAsFactors = FALSE, check.names = FALSE)
}

# ------------------
# Serial Processing
# ------------------

# Get data
data(Cars93, package = "MASS")
n <- nrow(Cars93)

# Calculate robust covariance
robustbase::covMcd(Cars93[, c("Price", "Horsepower")], cor = TRUE)$cor[1,2]

if (skip_serial_boot == FALSE) {
  # Perform robust covariance calculation with serial computing
  set.seed(seed)
  st <- system.time(ci <- f(X.seq = 1:R))
  res <- quant.fun(ci)
  
  # Combine results
  results <- combine_results(cl_type = 'none', 
                             package = 'none', fun = 'none', 
                             elapsed = st[['elapsed']], ci = res)
} else {
  results <- create_results_df()
}

# ------------------------------------
# Parallel Processing with "parallel"
# ------------------------------------

# Make a cluster of "slave nodes" with a type of either "SOCK" or "MPI".
# As a maximum, use one less than the total number of cores (or cluster slots).

cl <- makeCluster(spec = slots, type = cl_type)
cl

# Make the data, function and package "robustbase" available for all slots
#res <- clusterEvalQ(cl, library("robustbase"))
#res <- clusterEvalQ(cl, data(Cars93, package = "MASS"))
#res <- clusterExport(cl, "n")

# Set a random seed for all slots
res <- clusterSetRNGStream(cl, iseed = seed)

# Split bootstrap sequence (1:R) into a list of n = slots vectors
X.split <- clusterSplit(cl, 1:R)

# Perform calculation with parallel computing using "parallel::clusterApply()"
st <- system.time(ci_boot <- clusterApply(cl, x = X.split, fun = f))
res <- quant.fun(unlist(ci_boot))

# Stop the cluster
stopCluster(cl)

# Combine results
results <- rbind(results, 
                 combine_results(cl_type = cl_type, 
                                 package = 'parallel', fun = 'clusterApply', 
                                 elapsed = st[['elapsed']], ci = res))

# If running with "SOCK", compare with "FORK" using "parallel::mclapply()"
if (cl_type == "SOCK" && Sys.info()[['sysname']] != "Windows") {
  set.seed(seed)
  st <- system.time(ci_boot <- mclapply(X = X.split, FUN = f, mc.cores = slots))
  res <- quant.fun(unlist(ci_boot))
  
  # Combine results
  results <- rbind(results, 
                   combine_results(cl_type = 'FORK', 
                                   package = 'parallel', fun = 'mclapply', 
                                   elapsed = st[['elapsed']], ci = res))
}

# ----------------------------------------
# Parallel Processing with "BiocParallel"
# ----------------------------------------

# "BiocParallel" is like "parallel" in that it implements the functionality
# of earlier "snow" and "multicore" packages, but with a simpler method of
# switching between computation backends using a more consistent interface.

# Split bootstrap sequence (1:R) into a list of n = slots vectors
# Similar to: X.split <- clusterSplit(cl, 1:R)
X.split <- split(1:R, rep_len(1:slots, length(1:R)))

# Perform calculation with parallel computing using "BiocParallel::bplapply()"
param <- SnowParam(workers = slots, type = cl_type, RNGseed = seed)
st <- system.time(ci_boot <- bplapply(X = X.split, FUN = f, BPPARAM = param))
res <- quant.fun(unlist(ci_boot))

# Combine results
results <- rbind(results, 
                 combine_results(cl_type = cl_type, 
                                 package = 'BiocParallel', fun = 'bplapply', 
                                 elapsed = st[['elapsed']], ci = res))

# If running with "SOCK", compare with "FORK", the default for "MulticoreParam"
if (cl_type == "SOCK" && Sys.info()[['sysname']] != "Windows") {
  param <- MulticoreParam(workers = slots, RNGseed = seed)
  st <- system.time(ci_boot <- bplapply(X = X.split, FUN = f, BPPARAM = param))
  res <- quant.fun(unlist(ci_boot))

  # Combine results
  results <- rbind(results, 
                   combine_results(cl_type = 'FORK', 
                                   package = 'BiocParallel', fun = 'bplapply', 
                                   elapsed = st[['elapsed']], ci = res))
}

# Save test results
write.csv(results, results_filename, row.names = FALSE)
