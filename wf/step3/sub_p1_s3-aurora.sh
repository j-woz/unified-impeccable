#!/bin/bash

# SUB P1 S3 AURORA

#PBS -A workflow_scaling
#PBS -N m4_getenv(NAME)
# Merge streams:
#PBS -o m4_getenv(OUTPUT)
#PBS -j oe
#PBS -l walltime=m4_getenv(WALLTIME)
#PBS -q m4_getenv(QUEUE)
#PBS -l nodes=m4_getenv(NODES):ppn=m4_getenv(PPN)
#PBS -l filesystems=home:flare

set -eu

LABEL=m4_getenv(NAME)

WORKFLOW_STEP=m4_getenv(WORKFLOW_STEP)
cd $WORKFLOW_STEP

NODES=m4_getenv(NODES)
export PPN=m4_getenv(PPN)

source $WORKFLOW_STEP/../utils.sh

echo "JOB:" $PBS_JOBID

SETTINGS_IMPECCABLE=m4_getenv(SETTINGS_IMPECCABLE)
source-checked $SETTINGS_IMPECCABLE

export SITE=aurora

source $WORKFLOW_STEP/sub_p1_s3-setup.sh \
       /opt/aurora/25.190.0/oneapi/intel-conda-miniforge \
       /tmp/PY-IMPECCABLE/step3

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
  echo CONDA_PREFIX=$CONDA_PREFIX
  set -x

  which mpiexec python
  mpiexec ${MPIEXEC_FLAGS[@]} $AFFINITY python ${APP[@]}
)

# Moved sorting.py to step4a

# TODO: Come up with some other validation
