#!/bin/bash

# SUB P1 S2 AURORA

#PBS -A workflow_scaling
#PBS -N m4_getenv(NAME)
# Merge streams:
#PBS -o m4_getenv(OUTPUT)
#PBS -j oe
#PBS -l walltime=m4_getenv(WALLTIME)
#PBS -q m4_getenv(QUEUE)
#PBS -l nodes=m4_getenv(NODES):ppn=8
#PBS -l filesystems=home:flare

set -eu

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
source $WORKFLOW_STEP/sub_p1_s2-setup.sh \
              /opt/aurora/25.190.0/oneapi/intel-conda-miniforge \
              /tmp/PY-IMPECCABLE/step2

# /opt/aurora/25.190.0/frameworks/aurora_tensorflow-2025.2.0

export TF_FORCE_GPU_ALLOW_GROWTH=true
export MIOPEN_USER_DB_PATH=./miopen-cache
export MIOPEN_CUSTOM_CACHE_DIR=$MIOPEN_USER_DB_PATH
mkdir -pv $MIOPEN_USER_DB_PATH

# echo $CONDA_PREFIX
# echo $CONDA_EXE

hostname
# Catch errors: TF/HVD crash on exit on Aurora:
if mpiexec -n $PROCS --ppn $PPN python3 $WORK_DIR/smiles_regress_transformer_run.py
then
  : OK
else
  CODE=${?}
  if (( CODE == 139 ))
  then
    echo "sub_p1_s2: python segfault: ignoring..."
  else
    echo "sub_p1_s2: python code error: abort!"
    exit 1
  fi
fi

# Validating runs
cd $MEM_DIR
python $WORK_DIR/validate_2.py
