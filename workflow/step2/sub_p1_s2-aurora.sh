#!/bin/bash

# SUB P1 S2 AURORA

#PBS -A IMPECCAFLOW
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
export NODES=m4_getenv(NODES)
PPN=m4_getenv(PPN)

source $WORKFLOW_STEP/../utils.sh

# module load mpich

echo "JOB: $LABEL" $PBS_JOBID

SETTINGS_IMPECCABLE=m4_getenv(SETTINGS_IMPECCABLE)
source-checked $SETTINGS_IMPECCABLE

source $WORKFLOW_STEP/sub_p1_s2-setup.sh \
              /opt/aurora/25.190.0/oneapi/intel-conda-miniforge \
              /tmp/PY-IMPECCABLE/step2

module list

export TF_FORCE_GPU_ALLOW_GROWTH=true
export MIOPEN_USER_DB_PATH=./miopen-cache
export MIOPEN_CUSTOM_CACHE_DIR=$MIOPEN_USER_DB_PATH
mkdir -pv $MIOPEN_USER_DB_PATH

# echo $CONDA_PREFIX
# echo $CONDA_EXE

MPIEXEC_FLAGS=(
  -n    $PROCS
  --ppn $PPN
  # $TASKS_PER_NODE
)

LABEL=p1_s2
hostname
# Catch errors: TF/HVD crash on exit on Aurora:
if tm mpiexec ${MPIEXEC_FLAGS[@]} python3 $WORK_DIR/smiles_regress_transformer_run.py
then
  msg "mpiexec python: OK"
else
  CODE=${?}
  if (( CODE == 139 ))
  then
    msg "python SIGSEGV: ignoring..."
  elif (( CODE == 143 ))
  then
    msg "python SIGTERM: ignoring..."
  else
    msg "python error CODE=$CODE : abort!"
    exit 1
  fi
fi

# Validating runs
msg "validating..."
cd $MEM_DIR
python $WORK_DIR/validate_2.py

msg "DONE."
