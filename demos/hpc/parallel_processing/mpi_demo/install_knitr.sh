#!/bin/sh

module load R/R-4.0.0

Rscript -e 'if (!require(pacman)) install.packages("pacman", repos = "http://cran.us.r-project.org");
            pacman::p_load(knitr, dplyr, ggplot2, partykit, ROCR, randomForest, shiny)'

