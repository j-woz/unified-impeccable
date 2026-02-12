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



THIS=$( realpath $( dirname $0 ) )
cd $THIS

export SITE=aurora

source $THIS/../impeccable-settings.sh

module load frameworks/2024.2.1_u1
set -eu
source $THIS/sub_p1_s3-setup.sh \
       /opt/aurora/24.180.3/oneapi/intel-conda-miniforge \
       /tmp/PY-IMPECCABLE/step3

       # Roots:
       # /opt/aurora/24.180.3/oneapi/intel-conda-miniforge
       # /opt/aurora/25.190.0/oneapi/intel-conda-miniforge

       # Environments:
       # /tmp/frameworks-2024.2.1_2026-02-11
       # /tmp/frameworks-2025.2.0_2026-02-11
       # /tmp/frameworks-2024.180.3
       # /tmp/PY-IMPECCABLE/steps123

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
  PATH=/opt/cray/pals/1.8/bin:$PATH

  set -x

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
