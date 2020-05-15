#!/bin/bash

R=100000
Q=sheppardlab.q

for i in 2 4 8 16 24 32; do \

pe=mpi
slots=$i
n=$(( $slots + 1 ))

cat << EOF | sed -e "s/QQ/${Q}/g" -e "s/II/${pe}/g" -e "s/XX/${n}/g" -e "s/YY/${slots}/g" -e "s/ZZ/$R/g" > "${pe}_demo_${slots}.sh"
#!/bin/bash
#$ -q QQ 
#$ -pe II XX
#$ -cwd
#$ -S /bin/bash

module purge
module load MPICH/mpich-3.3
module load R/R-4.0.0

mpirun -rmk sge -envlist PATH,LD_LIBRARY_PATH,MKL_NUM_THREADS -np 1 \\
  /share/apps/R/R-4.0.0/bin/R CMD BATCH -q --no-save \\
  '--args cl_type="MPI" slots=YY R=ZZ' cluster_demo.R \\
  demo_II.out
EOF

pe=smp
slots=$i
n=$(( $slots + 1 ))

cat << EOF | sed -e "s/QQ/${Q}/g" -e "s/II/${pe}/g" -e "s/XX/${n}/g" -e "s/YY/${slots}/g" -e "s/ZZ/$R/g" > "${pe}_demo_${slots}.sh"
#!/bin/bash
#$ -q QQ
#$ -pe II XX
#$ -cwd
#$ -S /bin/bash

module load R/R-4.0.0

R CMD BATCH -q --no-save '--args cl_type="SOCK" slots=YY R=ZZ' \\
  cluster_demo.R demo_II.out
EOF

done

chmod +x *_demo_*.sh

