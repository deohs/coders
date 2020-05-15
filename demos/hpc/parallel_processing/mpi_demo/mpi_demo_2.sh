#!/bin/bash
#$ -q sheppardlab.q 
#$ -pe mpi 3
#$ -cwd
#$ -S /bin/bash

module purge
module load MPICH/mpich-3.3
module load R/R-4.0.0

mpirun -rmk sge -envlist PATH,LD_LIBRARY_PATH,MKL_NUM_THREADS -np 1 \
  /share/apps/R/R-4.0.0/bin/R CMD BATCH -q --no-save \
  '--args cl_type="MPI" slots=2 R=100000' cluster_demo.R \
  demo_mpi.out
