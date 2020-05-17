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
dec <- 5
alpha <- 0.05

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

f2 <- function(X.seq, ...) {
  data(Cars93, package = "MASS")
  n <- nrow(Cars93)
  robustbase::covMcd(Cars93[sample(1:n, replace=TRUE),
                              c("Price", "Horsepower")], cor = TRUE)$cor[1,2]
}

# Summarize results
quant.fun <- function(x, alpha = 0.05, dec = 5) {
  round(t(quantile(x, probs = c(alpha / 2, 1 - alpha / 2))), dec)
}
```

## Serial Processing


```r
set.seed(seed)
st <- system.time(ci_boot <- lapply(1:R, f2))
ci <- quant.fun(unlist(ci_boot), alpha = alpha, dec = dec)
results[[1]] <- data.frame(pkg = 'base', fun = 'lapply', 
                           splitlen = 'R', 
                           elapsed = round(st[['elapsed']], dec),
                           ci = ci, stringsAsFactors = FALSE, 
                           check.names = FALSE)
```

## Parallel Processing

### "parallel::mclapply()" and split length == R


```r
set.seed(seed)
st <- system.time(ci_boot <- mclapply(1:R, f, mc.cores = workers))
ci <- quant.fun(unlist(ci_boot), alpha = alpha, dec = dec)
results[[2]] <- data.frame(pkg = 'parallel', fun = 'mclapply', 
                           splitlen = 'R', 
                           elapsed = round(st[['elapsed']], dec), 
                           ci = ci, stringsAsFactors = FALSE, 
                           check.names = FALSE)
```

### "parallel::mclapply()" and split length == workers


```r
set.seed(seed)
X.split <- split(1:R, rep_len(1:workers, length(1:R)))
st <- system.time(ci_boot <- mclapply(X.split, f, mc.cores = workers))
ci <- quant.fun(unlist(ci_boot), alpha = alpha, dec = dec)
results[[3]] <- data.frame(pkg = 'parallel', fun = 'mclapply', 
                           splitlen = 'workers', 
                           elapsed = round(st[['elapsed']], dec), 
                           ci = ci, stringsAsFactors = FALSE, 
                           check.names = FALSE)
```

### "parallel::clusterApply()" and split length == R


```r
cl <- makeCluster(spec = workers, type = "SOCK")
res <- clusterSetRNGStream(cl, iseed = seed)
st <- system.time(ci_boot <- clusterApply(cl = cl, 1:R, f))
stopCluster(cl)
ci <- quant.fun(unlist(ci_boot), alpha = alpha, dec = dec)
results[[4]] <- data.frame(pkg = 'parallel', fun = 'clusterApply', 
                           splitlen = 'R', 
                           elapsed = round(st[['elapsed']], dec), 
                           ci = ci, stringsAsFactors = FALSE, 
                           check.names = FALSE)
```

### "parallel::clusterApply()" and split length == workers


```r
cl <- makeCluster(spec = workers, type = "SOCK")
res <- clusterSetRNGStream(cl, iseed = seed)
X.split <- clusterSplit(cl, 1:R)
st <- system.time(ci_boot <- clusterApply(cl = cl, X.split, f))
stopCluster(cl)
ci <- quant.fun(unlist(ci_boot), alpha = alpha, dec = dec)
results[[5]] <- data.frame(pkg = 'parallel', fun = 'clusterApply', 
                           splitlen = 'workers', 
                           elapsed = round(st[['elapsed']], dec), 
                           ci = ci, stringsAsFactors = FALSE, 
                           check.names = FALSE)
```

### "parallel::parLapply()" and split length == workers


```r
cl <- makeCluster(spec = workers, type = "SOCK")
res <- clusterSetRNGStream(cl, iseed = seed)
st <- system.time(ci_boot <- parLapply(cl = cl, 1:R, f2))
stopCluster(cl)
ci <- quant.fun(unlist(ci_boot), alpha = alpha, dec = dec)
results[[6]] <- data.frame(pkg = 'parallel', fun = 'parLapply', 
                           splitlen = 'workers', 
                           elapsed = round(st[['elapsed']], dec), 
                           ci = ci, stringsAsFactors = FALSE, 
                           check.names = FALSE)
```

### "BiocParallel::bplapply()" and split length == R


```r
param <- MulticoreParam(workers = workers, RNGseed = seed)
st <- system.time(ci_boot <- bplapply(1:R, f, BPPARAM = param))
ci <- quant.fun(unlist(ci_boot), alpha = alpha, dec = dec)
results[[7]] <- data.frame(pkg = 'BiocParallel', fun = 'bplapply', 
                           splitlen = 'R', 
                           elapsed = round(st[['elapsed']], dec), 
                           ci = ci, stringsAsFactors = FALSE, 
                           check.names = FALSE)
```

### "BiocParallel::bplapply()" and split length == workers


```r
param <- MulticoreParam(workers = workers, RNGseed = seed)
X.split <- split(1:R, rep_len(1:workers, length(1:R)))
st <- system.time(ci_boot <- bplapply(X.split, f, BPPARAM = param))
ci <- quant.fun(unlist(ci_boot), alpha = alpha, dec = dec)
results[[8]] <- data.frame(pkg = 'BiocParallel', fun = 'bplapply', 
                           splitlen = 'workers', 
                           elapsed = round(st[['elapsed']], dec), 
                           ci = ci, stringsAsFactors = FALSE, 
                           check.names = FALSE)
```

## Results


```r
results <- do.call('rbind', results)
write.csv(results, "split_test_results.csv", row.names = FALSE)
knitr::kable(results)
```



pkg            fun            splitlen    elapsed   ci.2.5%   ci.97.5%
-------------  -------------  ---------  --------  --------  ---------
base           lapply         R            94.321   0.76782    0.95185
parallel       mclapply       R            14.648   0.77245    0.95134
parallel       mclapply       workers       9.071   0.77245    0.95134
parallel       clusterApply   R            85.563   0.77115    0.95141
parallel       clusterApply   workers       9.554   0.77127    0.95134
parallel       parLapply      workers      15.269   0.77127    0.95134
BiocParallel   bplapply       R            15.696   0.76633    0.95088
BiocParallel   bplapply       workers      10.001   0.77098    0.94974
