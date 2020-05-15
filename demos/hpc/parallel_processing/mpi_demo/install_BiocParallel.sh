#!/bin/bash

# Install BiocParallel from Bioconductor.

Rscript -e '.lib <- ifelse(file.access(.Library, 2) == 0, .Library,
                           .libPaths()[1])
            if (!requireNamespace("BiocManager", quietly = TRUE))
              install.packages("BiocManager", 
                repos = "http://cran.us.r-project.org", lib = .lib)
            BiocManager::install("BiocParallel", lib = .lib)'

