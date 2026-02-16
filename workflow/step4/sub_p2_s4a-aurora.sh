#!/bin/bash

# SUB P1 S1 AURORA

#PBS -A workflow_scaling
#PBS -N p2_s4a
# Merge streams:
#PBS -o sub_p2_s4.out
#PBS -j oe
#PBS -l walltime=0:05:00
#PBS -q debug
#PBS -l nodes=1:ppn=64
#PBS -l filesystems=home:flare

set -eu

THIS=$( realpath $( dirname $0 ) )
cd $THIS

export SITE=aurora

source $THIS/../impeccable-settings.sh
source $THIS/sub_p2_s4a-setup.sh \
       /opt/aurora/24.180.3/oneapi/intel-conda-miniforge \
       /tmp/PY-IMPECCABLE/steps123

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
