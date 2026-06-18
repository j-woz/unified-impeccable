#!/bin/bash

#SBATCH -A CHM155_004
#SBATCH -J p2_s4a
# Merge streams:
#SBATCH -o %x-%j.out
#SBATCH -e %x-%j.out
#SBATCH -t 05:00
#SBATCH -p batch
#SBATCH -q debug
#SBATCH -N 1
#SBATCH --tasks-per-node 64
#SBATCH -S 0

export THIS=$SLURM_SUBMIT_DIR
cd $THIS

export SITE=frontier

source $THIS/../impeccable-settings.sh
source $THIS/sub_p2_s4a-setup.sh oepython_new

# TMP CHANGE!
TASKS_PER_NODE=32

# Executing runs
(
  set -x
  srun -N ${NNODES} --ntasks=$((NNODES*TASKS_PER_NODE)) -S 0 --ntasks-per-node=$TASKS_PER_NODE python $WORK_DIR/docking_openeye_pose.py -s fixpka_compounds.smi -r $recep_file_dir/$recep_file -p $WORK_DIR/input/$protein_pdb -o output_combined_trajectories
)

echo $0: OK
