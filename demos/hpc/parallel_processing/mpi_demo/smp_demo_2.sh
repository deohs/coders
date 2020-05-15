#!/bin/bash
#$ -q sheppardlab.q
#$ -pe smp 3
#$ -cwd
#$ -S /bin/bash

module load R/R-4.0.0

R CMD BATCH -q --no-save '--args cl_type="SOCK" slots=2 R=100000' \
  cluster_demo.R demo_smp.out
