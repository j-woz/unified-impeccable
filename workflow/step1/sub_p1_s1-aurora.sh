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

LABEL=m4_getenv(NAME)

WORKFLOW_STEP=m4_getenv(WORKFLOW_STEP)
cd $WORKFLOW_STEP

export SITE=aurora
if [[ ${NODES:-} == "" ]]
then
  export NODES=m4_getenv(NODES)
  PPN=m4_getenv(PPN)
fi
PROCS=$[ NODES * PPN ]

source $WORKFLOW_STEP/../impeccable-settings.sh

source $WORKFLOW_STEP/sub_p1_s1-setup.sh \
       /opt/aurora/26.26.0/spack/unified/1.1.1/install/linux-x86_64/miniforge3-25.11.0-1-khkcc6i \
       /tmp/PY-IMPECCABLE/step1

LABEL=m4_getenv(NAME)

GPUS=$[ NODES * 12 ]

(
  printf "using mpiexec: "
  which mpiexec
  show PWD
  LABEL=p1_s1_train
  tm mpiexec -n $PROCS --ppn $PPN \
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
  LABEL=p1_s1_validate
  tm python $WORK_DIR/validate_1.py ${VALIDATE_ARGS[@]}
  # DB INSERT "sub_p1_s1/validate" OK;
)

echo $0 OK
