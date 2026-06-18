#!/bin/bash

# SUB P2 S4A AURORA

#PBS -A IMPECCAFLOW
#PBS -N m4_getenv(NAME)
# Merge streams:
#PBS -o m4_getenv(OUTPUT)
#PBS -j oe
#PBS -l walltime=m4_getenv(WALLTIME)
#PBS -q m4_getenv(QUEUE)
#PBS -l nodes=m4_getenv(NODES):ppn=m4_getenv(PPN)
#PBS -l filesystems=home:flare

set -eu

export SITE=aurora
NAME=m4_getenv(NAME)
LABEL=$NAME
export NODES=m4_getenv(NODES)
export PPN=m4_getenv(PPN)

WORKFLOW_STEP=m4_getenv(WORKFLOW_STEP)
cd $WORKFLOW_STEP

echo "JOB:" $PBS_JOBID

source $WORKFLOW_STEP/../utils.sh

SETTINGS_IMPECCABLE=m4_getenv(SETTINGS_IMPECCABLE)
source-checked $SETTINGS_IMPECCABLE

source $WORKFLOW_STEP/sub_p2_s4a-setup.sh \
       /opt/aurora/25.190.0/oneapi/intel-conda-miniforge \
       /tmp/PY-IMPECCABLE/step4

LABEL=$NAME

MPIEXEC_FLAGS=(
  -n   $PROCS
  -ppn $PPN # $TASKS_PER_NODE
)

A=( -s fixpka_compounds.smi
    -r $recep_file_dir/$recep_file
    -p $WORK_DIR/input/$protein_pdb
    -o output_combined_trajectories
  )

(
  PATH=/opt/cray/pals/1.8/bin:$PATH
  which mpiexec
  tm mpiexec ${MPIEXEC_FLAGS[@]} \
     python $WORK_DIR/docking_openeye_pose.py ${A[@]}
)

msg OK
