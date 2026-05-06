#!/bin/bash

# SUB P2 S4A AURORA

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

SITE=aurora
LABEL=m4_getenv(NAME)
export NODES=m4_getenv(NODES)
export PPN=m4_getenv(PPN)

WORKFLOW_STEP=m4_getenv(WORKFLOW_STEP)
cd $WORKFLOW_STEP

source $WORKFLOW_STEP/../impeccable-settings.sh

source $WORKFLOW_STEP/sub_p2_s4a-setup.sh \
       /opt/aurora/25.190.0/oneapi/intel-conda-miniforge \
       /tmp/PY-IMPECCABLE/step4

# TMP CHANGE!
TASKS_PER_NODE=32

A=( -s fixpka_compounds.smi
    -r $recep_file_dir/$recep_file
    -p $WORK_DIR/input/$protein_pdb
    -o output_combined_trajectories
  )

(
  set -x
  PATH=/opt/cray/pals/1.8/bin:$PATH
  which mpiexec

  python $WORK_DIR/docking_openeye_pose.py ${A[@]}
)

echo $0: OK
