#!/bin/sh

# Install Rmpi from source.

module purge
module load MPICH/mpich-3.3
module load R/R-4.0.0

FILE=Rmpi_0.6-9.tar.gz

[[ -f "$FILE" ]] || \
  wget "https://cran.r-project.org/src/contrib/$FILE"

R CMD INSTALL "$FILE" \
  --configure-args="--with-Rmpi-include=/opt/mpich3/gnu/include \
  --with-Rmpi-libpath=/opt/mpich3/gnu/lib --with-Rmpi-type=MPICH2" \
  --no-test-load

