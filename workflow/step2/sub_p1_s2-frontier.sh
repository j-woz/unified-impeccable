#!/bin/bash

#SBATCH -A chm155_004
#SBATCH -J p1_s2
# Merge streams:
#SBATCH -o %x-%j.out
#SBATCH -e %x-%j.out
#SBATCH -t 1:00:00
#SBATCH -p batch
#SBATCH -q debug
#SBATCH -N 1
#SBATCH --tasks-per-node 8
#SBATCH -S 0

export THIS=$SLURM_SUBMIT_DIR
cd $THIS

export SITE=frontier

source $THIS/../impeccable-settings.sh
source $THIS/sub_p1_s2-setup.sh oepython_new

# Setting environments
module reset
module load PrgEnv-gnu
module load rocm/6.0.0

export TF_FORCE_GPU_ALLOW_GROWTH=true
export MIOPEN_USER_DB_PATH=/tmp/$USER/miopen-cache
export MIOPEN_CUSTOM_CACHE_DIR=$MIOPEN_USER_DB_PATH
if [[ -d $MIOPEN_USER_DB_PATH ]]
then
  rm -r  $MIOPEN_USER_DB_PATH
fi
mkdir -p $MIOPEN_USER_DB_PATH

conda activate st_train

# Setting paths
set -x
MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
mkdir -p $MEM_DIR
STEP1_DIR=$WORK_DIR/../step1/mem$MEM_ID

set -x
# Executing runs
# srun -N ${NNODES} -n $((NNODES*TASKS_PER_NODE)) -S 0
python3 $WORK_DIR/smiles_regress_transformer_run.py

# Validating runs
cd $MEM_DIR
python $WORK_DIR/validate_2.py
