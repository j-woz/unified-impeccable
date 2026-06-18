#!/bin/bash

# SUB P1 S1 AURORA
# Aurora-specific launch of step tasks

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

LABEL=m4_getenv(NAME)

WORKFLOW_STEP=m4_getenv(WORKFLOW_STEP)
cd $WORKFLOW_STEP

export SITE=aurora
LABEL=m4_getenv(NAME)
export NODES=m4_getenv(NODES)
PPN=m4_getenv(PPN)

source $WORKFLOW_STEP/../utils.sh

SETTINGS_IMPECCABLE=m4_getenv(SETTINGS_IMPECCABLE)
source-checked $SETTINGS_IMPECCABLE

echo "JOB:" $PBS_JOBID

source $WORKFLOW_STEP/sub_p1_s1-setup.sh \
       /opt/aurora/26.26.0/spack/unified/1.1.1/install/linux-x86_64/miniforge3-25.11.0-1-khkcc6i \
       /tmp/PY-IMPECCABLE/step1

GPUS=$[ NODES * 12 ]

MPIEXEC_FLAGS=(
  -n   $PROCS
  --ppn $PPN # $TASKS_PER_NODE
)

(
  printf "using mpiexec: "
  which mpiexec
  show PWD
  LABEL=p1_s1_dock
  tm mpiexec ${MPIEXEC_FLAGS[@]} python $WORK_DIR/docking_openeye.py
  # 64
  # DB INSERT "sub_p1_s1/docking" OK;
)

# Validating runs
(
  VALIDATE_ARGS=( -s $MEM_DIR/scores -c $MEM_DIR/config_htp.json )

  cd $MEM_DIR
  pwd -P
  LABEL=p1_s1_validate
  tm python $WORK_DIR/validate_1.py ${VALIDATE_ARGS[@]}
  # DB INSERT "sub_p1_s1/validate" OK;
)

LABEL=p1_s1
msg "DONE."
