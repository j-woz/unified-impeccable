#!/bin/bash

# SUB P1 S1 AURORA
# Aurora-specific launch of step tasks

#PBS -A workflow_scaling
#PBS -N m4_getenv(NAME)
# Merge streams:
#PBS -o m4_getenv(OUTPUT)
#PBS -j oe
#PBS -l walltime=m4_getenv(WALLTIME)
#PBS -q m4_getenv(QUEUE)
#PBS -l nodes=m4_getenv(NODES):ppn=64
#PBS -l filesystems=home:flare

WORKFLOW_STEP=m4_getenv(WORKFLOW_STEP)
cd $WORKFLOW_STEP

export SITE=aurora
NODES=m4_getenv(NODES)
PROCS=$[ NODES / 64 ]

source $WORKFLOW_STEP/../impeccable-settings.sh

source $WORKFLOW_STEP/sub_p1_s1-setup.sh \
       /opt/aurora/24.180.3/oneapi/intel-conda-miniforge \
       /tmp/PY-IMPECCABLE/steps123
#        /opt/aurora/25.190.0/oneapi/intel-conda-miniforge \
#

LABEL=m4_getenv(NAME)

(
  set -x
  which mpiexec
  pwd -P
  tm mpiexec -n 1 \
                python $WORK_DIR/docking_openeye.py
  # 64
  # DB INSERT "sub_p1_s1/docking" OK;
)

# Validating runs
(
  VALIDATE_ARGS=( -s $MEM_DIR/scores -c config_htp.json )

  set -x

  cd $MEM_DIR
  pwd -P
  tm python $WORK_DIR/validate_1.py ${VALIDATE_ARGS[@]}
  # DB INSERT "sub_p1_s1/validate" OK;
)

echo $0 OK
