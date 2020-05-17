---
title: "Split Test"
output: 
  html_document:
    keep_md: yes
editor_options: 
  chunk_output_type: console
---



## Setup


```r
# Load packages
library(parallel)
library(BiocParallel)

# Set defaults
workers <- 8
R <- 10000
seed <- 123

# Setup random number generator for mclapply()
RNGkind("L'Ecuyer-CMRG")

# Create list for storing results
results <- list()
```

## Define Functions


```r
# Calculate robust covariance for each bootstrap using a single core
f <- function(X.seq, ...) {
  data(Cars93, package = "MASS")
  n <- nrow(Cars93)
  sapply(X.seq, function(x) {
    robustbase::covMcd(Cars93[sample(1:n, replace=TRUE),
                              c("Price", "Horsepower")], cor = TRUE)$cor[1,2]
  })
}
```

## Serial Processing


```r
set.seed(seed)
st <- system.time(ci_boot <- lapply(1:R, f))
elapsed <- st[['elapsed']]
results[[1]] <- data.frame(pkg = 'base', fun = 'lapply', 
                           splitlen = 'R', elapsed = elapsed,
                           stringsAsFactors = FALSE)
```

## Parallel Processing

### "parallel::mclapply()" and split length == R


```r
set.seed(seed)
st <- system.time(ci_boot <- mclapply(1:R, f, mc.cores = workers))
elapsed <- st[['elapsed']]
results[[2]] <- data.frame(pkg = 'parallel', fun = 'mclapply', 
                           splitlen = 'R', elapsed = elapsed, 
                           stringsAsFactors = FALSE)
```

### "parallel::mclapply()" and split length == workers


```r
set.seed(seed)
X.split <- split(1:R, rep_len(1:workers, length(1:R)))
st <- system.time(ci_boot <- mclapply(X.split, f, mc.cores = workers))
elapsed <- st[['elapsed']]
results[[3]] <- data.frame(pkg = 'parallel', fun = 'mclapply', 
                           splitlen = 'workers', elapsed = elapsed, 
                           stringsAsFactors = FALSE)
```

### "BiocParallel::bplapply()" and split length == R


```r
param <- MulticoreParam(workers = workers, RNGseed = seed)
st <- system.time(ci_boot <- bplapply(1:R, f, BPPARAM = param))
elapsed <- st[['elapsed']]
results[[4]] <- data.frame(pkg = 'BiocParallel', fun = 'bplapply', 
                           splitlen = 'R', elapsed = elapsed, 
                           stringsAsFactors = FALSE)
```

### "BiocParallel::bplapply()" and split length == workers


```r
param <- MulticoreParam(workers = workers, RNGseed = seed)
X.split <- split(1:R, rep_len(1:workers, length(1:R)))
st <- system.time(ci_boot <- bplapply(X.split, f, BPPARAM = param))
elapsed <- st[['elapsed']]
results[[5]] <- data.frame(pkg = 'BiocParallel', fun = 'bplapply', 
                           splitlen = 'workers', elapsed = elapsed, 
                           stringsAsFactors = FALSE)
```

## Results


```r
results <- do.call('rbind', results)
write.csv(results, "split_test_results.csv", row.names = FALSE)
knitr::kable(results)
```



pkg            fun        splitlen    elapsed
-------------  ---------  ---------  --------
base           lapply     R            88.698
parallel       mclapply   R            13.815
parallel       mclapply   workers       9.096
BiocParallel   bplapply   R            15.818
BiocParallel   bplapply   workers       9.811
