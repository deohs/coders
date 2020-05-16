#!/bin/bash

R=100000
Q=sheppardlab.q

for i in 2 4 8 16 24 32; do \

pe=mpi
workers=$i
slots=$(( $workers + 1 ))

cat << EOF | sed -e "s/%Q%/${Q}/g" -e "s/%P%/${pe}/g" -e "s/%S%/${slots}/g" \
          -e "s/%W%/${workers}/g" -e "s/%R%/$R/g" > "${pe}_demo_${workers}.sh"
#!/bin/bash
#$ -q %Q% 
#$ -pe %P% %S%
#$ -cwd
#$ -S /bin/bash

module purge
module load MPICH/mpich-3.3
module load R/R-4.0.0

mpirun -rmk sge -envlist PATH,LD_LIBRARY_PATH,MKL_NUM_THREADS -np 1 \\
  /share/apps/R/R-4.0.0/bin/R CMD BATCH -q --no-save \\
  '--args cl_type="MPI" workers=%W% R=%R%' cluster_demo.R \\
  demo_%P%.out
EOF

pe=smp
workers=$i
slots=$(( $workers + 1 ))

cat << EOF | sed -e "s/%Q%/${Q}/g" -e "s/%P%/${pe}/g" -e "s/%S%/${slots}/g" \
          -e "s/%W%/${workers}/g" -e "s/%R%/$R/g" > "${pe}_demo_${workers}.sh"
#!/bin/bash
#$ -q %Q%
#$ -pe %P% %S%
#$ -cwd
#$ -S /bin/bash

module load R/R-4.0.0

R CMD BATCH -q --no-save '--args cl_type="SOCK" workers=%W% R=%R%' \\
  cluster_demo.R demo_%P%.out
EOF

done

chmod +x *_demo_*.sh

