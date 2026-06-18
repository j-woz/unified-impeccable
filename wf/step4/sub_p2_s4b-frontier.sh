#!/bin/bash

#SBATCH -A CHM155_001
#SBATCH -J p2_s4b
#SBATCH -o %x-%j.out
#SBATCH -e %x-%j.err
#SBATCH -t 1:00:00
#SBATCH -p batch
#SBATCH -q debug
#SBATCH -N 1
#SBATCH --tasks-per-node 64
#SBATCH -S 0

export THIS=$SLURM_SUBMIT_DIR
cd $THIS

export SITE=frontier

source $THIS/../impeccable-settings.sh
source $THIS/sub_p2_s4b-setup.sh AmberTools23_Frontier-Balint

# Create directory structure
# Parameterise and build models
for ((i=0; i<$N_COMPS; i++)); do
	srun -n1 -N1 -c1 bash $WORK_DIR/p2_s4b_process.sh $i $ITR_DIR $WORK_DIR &
	sleep 0.2
done

wait
