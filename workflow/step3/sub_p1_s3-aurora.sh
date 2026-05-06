#!/bin/bash

# SUB P1 S3 AURORA

#PBS -A workflow_scaling
#PBS -N m4_getenv(NAME)
# Merge streams:
#PBS -o m4_getenv(OUTPUT)
#PBS -j oe
#PBS -l walltime=m4_getenv(WALLTIME)
#PBS -q m4_getenv(QUEUE)
#PBS -l nodes=m4_getenv(NODES):ppn=8
#PBS -l filesystems=home:flare

LABEL=m4_getenv(NAME)
NODES=m4_getenv(NODES)
PPN=m4_getenv(PPN)

WORKFLOW_STEP=m4_getenv(WORKFLOW_STEP)
cd $WORKFLOW_STEP

export SITE=aurora

source $WORKFLOW_STEP/../impeccable-settings.sh

source $WORKFLOW_STEP/sub_p1_s3-setup.sh \
       /opt/aurora/25.190.0/oneapi/intel-conda-miniforge \
       /tmp/PY-IMPECCABLE/step3

set -eu

MPIEXEC_FLAGS=(
  -n   $PROCS
  -ppn $PPN # $TASKS_PER_NODE
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

  which mpiexec python
  echo CONDA_PREFIX=$CONDA_PREFIX
  mpiexec ${MPIEXEC_FLAGS[@]} python ${APP[@]}
)

set -x
# post-processing
cd $MEM_DIR
python3 $WORK_DIR/sorting.py

# Validating runs
cd $MEM_DIR
python $WORK_DIR/validate_3.py
