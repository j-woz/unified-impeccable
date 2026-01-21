#!/bin/bash

# SUB P1 S1 AURORA

#PBS -A workflow_scaling
#PBS -N p1_s3
# Merge streams:
#PBS -o sub_p1_s3.out
#PBS -j oe
#PBS -l walltime=1:00:00
#PBS -q debug
#PBS -l nodes=1:ppn=64
#PBS -l filesystems=home:flare

set -eu

THIS=$( realpath $( dirname $0 ) )
cd $THIS

export SITE=aurora

source $THIS/../impeccable-settings.sh
source $THIS/sub_p1_s3-setup.sh base

MPIEXEC_FLAGS=(
  -n  1 #  $((NNODES*TASKS_PER_NODE))
  -ppn 2 # $TASKS_PER_NODE
)

APP=(
  $WORK_DIR/smiles_regress_transformer_run_large.py
  -w $STEP2_DIR/model.weights.h5
  -d $DATASET
)

# Executing runs
(
  set -x
  PATH=/opt/cray/pals/1.8/bin:$PATH
  which mpiexec
  mpiexec ${MPIEXEC_FLAGS[@]} python ${APP[@]}
)

set -x
# post-processing
cd $MEM_DIR
python3 $WORK_DIR/sorting.py

# Validating runs
cd $MEM_DIR
python $WORK_DIR/validate_3.py
