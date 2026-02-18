#!/bin/bash

# SUB P1 S1 AURORA

#PBS -A workflow_scaling
#PBS -N p2_s4c
# Merge streams:
#PBS -o sub_p2_s4c.out
#PBS -j oe
#PBS -l walltime=0:05:00
#PBS -q debug
#PBS -l nodes=1:ppn=64
#PBS -l filesystems=home:flare

# #SBATCH -A CHM155_001
# #SBATCH -J p2_s4c
# #SBATCH -o %x-%j.out
# #SBATCH -e %x-%j.err
# #SBATCH -t 1:00:00
# #SBATCH -p batch
# ##SBATCH -q debug
# #SBATCH -N 1
# ##SBATCH --tasks-per-node 64
# #SBATCH -S 0

set -eu

THIS=$( realpath $( dirname $0 ) )
cd $THIS

export SITE=aurora

source $THIS/../impeccable-settings.sh
source $THIS/sub_p2_s4c-setup.sh

# export NAMDBINDIR=/lustre/orion/stf006/world-shared/dilipa/NAMD/NAMD31A3
# export NAMDVER=NAMD_3.1alpha3_Linux-x86_64-multicore-HIP
# export NAMDBIN=$NAMDBINDIR/$NAMDVER/namd3

NAMDBIN=$HOME/proj/uni-impec/namd3_md_example/namd3
export namdargs=''

export ZE_FLAT_DEVICE_HIERARCHY=FLAT

LABEL="S4C:NAMD"

# Executing runs
for ((i=0; i < $N_COMPS; i++))
do
  printf "run: %3i/%3i\n" $i $N_COMPS
  pwd
  mkdir -pv min/$i
  cd min/$i
  sed "s/LIG/$i/g" $WORK_DIR/model-inputs/eq0.conf > eq0.conf
  #sed -i "s/minimize 200/minimize 100/" eq0.conf
  #sed -i "s/dcdfreq             200/dcdfreq             100/" eq0.conf
  #srun -N1 -n1 -c56 $NAMDBIN --tclmain eq0.conf +stdout eq0.log
  # srun -N1 -n1 -c56 --ntasks-per-node=1 --gpus-per-task=1 --gpu-bind=closest --mpi=none --kill-on-bad-exit=0
  tm $NAMDBIN +p56 +devices 0 $namdargs --tclmain eq0.conf +stdout eq0.log
  cd ../..
done
