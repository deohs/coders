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
R <- 100000
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
cor.fun <- function(x, ...) {
  data(Cars93, package = "MASS")
  n <- nrow(Cars93)
  robustbase::covMcd(Cars93[sample(1:n, replace=TRUE),
                              c("Price", "Horsepower")], cor = TRUE)$cor[1,2]
}

fun.sapply <- function(x, f = cor.fun, ...) sapply(x, f, ...)

# Summarize results
quant.fun <- function(x, alpha = 0.05, dec = 5) {
  round(t(quantile(x, probs = c(alpha / 2, 1 - alpha / 2))), dec)
}
```

## Serial Processing


```r
set.seed(seed)
st <- system.time(ci_boot <- lapply(1:R, cor.fun))
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
st <- system.time(ci_boot <- mclapply(1:R, fun.sapply, mc.cores = workers))
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
st <- system.time(ci_boot <- mclapply(X.split, fun.sapply, mc.cores = workers))
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
res <- clusterExport(cl, "cor.fun")
st <- system.time(ci_boot <- clusterApply(cl = cl, 1:R, fun.sapply))
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
res <- clusterExport(cl, "cor.fun")
X.split <- clusterSplit(cl, 1:R)
st <- system.time(ci_boot <- clusterApply(cl = cl, X.split, fun.sapply))
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
st <- system.time(ci_boot <- parLapply(cl = cl, 1:R, cor.fun))
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
st <- system.time(ci_boot <- bplapply(1:R, fun.sapply, BPPARAM = param))
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
st <- system.time(ci_boot <- bplapply(X.split, fun.sapply, BPPARAM = param))
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
base           lapply         R           938.359   0.76973    0.95076
parallel       mclapply       R           138.262   0.76927    0.95107
parallel       mclapply       workers     133.065   0.76927    0.95107
parallel       clusterApply   R           843.991   0.76917    0.95113
parallel       clusterApply   workers     136.484   0.76921    0.95113
parallel       parLapply      workers     138.687   0.76921    0.95113
BiocParallel   bplapply       R           149.616   0.77082    0.95123
BiocParallel   bplapply       workers     145.422   0.77074    0.95037
