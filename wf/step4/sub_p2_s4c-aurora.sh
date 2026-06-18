#!/bin/bash

# SUB P2 S4C AURORA

#PBS -A IMPECCAFLOW
#PBS -N m4_getenv(NAME)
# Merge streams:
#PBS -o m4_getenv(OUTPUT)
#PBS -j oe
#PBS -l walltime=m4_getenv(WALLTIME)
#PBS -q m4_getenv(QUEUE)
#PBS -l nodes=m4_getenv(NODES):ppn=64
#PBS -l filesystems=home:flare

set -eu

SITE=aurora
LABEL=m4_getenv(NAME)
NODES=m4_getenv(NODES)
PPN=m4_getenv(PPN)

WORKFLOW_STEP=m4_getenv(WORKFLOW_STEP)
cd $WORKFLOW_STEP

echo "JOB:" $PBS_JOBID

source $WORKFLOW_STEP/../utils.sh

SETTINGS_IMPECCABLE=m4_getenv(SETTINGS_IMPECCABLE)
source-checked $SETTINGS_IMPECCABLE

source $WORKFLOW_STEP/sub_p2_s4c-setup.sh

# export NAMDBINDIR=/lustre/orion/stf006/world-shared/dilipa/NAMD/NAMD31A3
# export NAMDVER=NAMD_3.1alpha3_Linux-x86_64-multicore-HIP
# export NAMDBIN=$NAMDBINDIR/$NAMDVER/namd3

NAMDBIN=$HOME/proj/uni-impecc/namd3_md_example/namd3
export namdargs=''

export ZE_FLAT_DEVICE_HIERARCHY=FLAT

START=

# Executing runs
for ((i=0; i < $N_COMPS; i++))
do
  msgf "run: %3i/%3i\n" $i $N_COMPS
  pwd
  mkdir -pv min/$i
  cd min/$i
  sed "s/LIG/$i/g" $WORK_DIR/model-inputs/eq0.conf > eq0.conf
  #sed -i "s/minimize 200/minimize 100/" eq0.conf
  #sed -i "s/dcdfreq             200/dcdfreq             100/" eq0.conf
  #srun -N1 -n1 -c56 $NAMDBIN --tclmain eq0.conf +stdout eq0.log
  # srun -N1 -n1 -c56 --ntasks-per-node=1 --gpus-per-task=1 --gpu-bind=closest --mpi=none --kill-on-bad-exit=0
  $NAMDBIN +p56 +devices 0 $namdargs --tclmain eq0.conf +stdout eq0.log
  cd ../..
done
