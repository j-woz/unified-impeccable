#!/bin/bash

#SBATCH -A CHM155_004
#SBATCH -J p1_s3
# Merge streams:
#SBATCH -o %x-%j.out
#SBATCH -e %x-%j.out
#SBATCH -t 10:00
#SBATCH -p batch
#SBATCH -q debug
#SBATCH -N 1
#SBATCH --tasks-per-node 8
#SBATCH -S 0

set -eu

export THIS=$SLURM_SUBMIT_DIR
cd $THIS

export SITE=frontier

source $THIS/../impeccable-settings.sh
source $THIS/sub_p1_s3-setup.sh st_mpi_base

# Setting environments
set +eu
module reset
module load PrgEnv-gnu
module load rocm/6.0.0
set -eu

export TF_FORCE_GPU_ALLOW_GROWTH=true
export MIOPEN_USER_DB_PATH=/tmp/$USER/miopen-cache
export MIOPEN_CUSTOM_CACHE_DIR=$MIOPEN_USER_DB_PATH
if [[ -d $MIOPEN_USER_DB_PATH ]]
then
  rm -r  $MIOPEN_USER_DB_PATH
fi
mkdir -p $MIOPEN_USER_DB_PATH

set -x

# Executing runs
srun -N ${NNODES} -n $((NNODES*TASKS_PER_NODE)) -S 0 python3 $WORK_DIR/smiles_regress_transformer_run_large.py -w $STEP2_DIR/model.weights.h5 -d $DATASET

# post-processing
cd $MEM_DIR
python3 $WORK_DIR/sorting.py

# Validating runs
cd $MEM_DIR
python $WORK_DIR/validate_3.py

