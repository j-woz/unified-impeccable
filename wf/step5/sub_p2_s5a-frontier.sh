#!/bin/bash

#SBATCH -A CHM155_001
#SBATCH -J p2_s5a
#SBATCH -o %x-%j.out
#SBATCH -e %x-%j.err
#SBATCH -t 1:00:00
#SBATCH -p batch
##SBATCH -q debug
#SBATCH -N 1
#SBATCH --tasks-per-node 64
#SBATCH -S 0

set -eu

export THIS=$SLURM_SUBMIT_DIR
cd $THIS

export SITE=frontier

source $THIS/../impeccable-settings.sh
source $THIS/sub_p2_s5a-setup.sh AmberTools23_Frontier-Balint

# # Setting environments
# module reset
# module load cpe/23.09
# module load PrgEnv-gnu
# source /ccs/proj/chm155/IMPECCABLE/activate_conda.sh
# conda activate AmberTools23_Frontier-Balint

# Executing runs
cd $ITR_DIR
#l=0
for ((i=0; i<$N_COMPS; i++)); do
	srun -n1 -N1 -c1 bash $WORK_DIR/p2_s5a_process.sh $i &
	sleep 0.2
done

wait
