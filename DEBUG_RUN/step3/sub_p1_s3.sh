#!/bin/bash

#SBATCH -A CHM155_001
#SBATCH -J p1_s3
#SBATCH -o %x-%j.out
#SBATCH -e %x-%j.err
#SBATCH -t 1:00:00
#SBATCH -p batch
#SBATCH -q debug
#SBATCH -N 1
#SBATCH --tasks-per-node 8
#SBATCH -S 0

# Setting environments
module reset
module load PrgEnv-gnu
module load rocm/6.0.0
export TF_FORCE_GPU_ALLOW_GROWTH=true
export MIOPEN_USER_DB_PATH=./miopen-cache
export MIOPEN_CUSTOM_CACHE_DIR=$MIOPEN_USER_DB_PATH
mkdir -p $MIOPEN_USER_DB_PATH
source /ccs/proj/chm155/IMPECCABLE/activate_conda.sh
conda activate st_mpi_base

# Setting paths
CODE_DIR=/lustre/orion/chm155/proj-shared/apbhati/IMPECCABLE_2.0/surrogate_inference
WORK_DIR=/lustre/orion/chm155/proj-shared/apbhati/IMPECCABLE_2.0/DEBUG_RUN/step3
MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
mkdir -p $MEM_DIR
STEP2_DIR=$WORK_DIR/../step2/mem$MEM_ID

# Setting runs
cp -r $CODE_DIR/* $WORK_DIR/
cd $MEM_DIR
DATASET=BDB
mkdir -p output/$DATASET
mkdir -p Sorting_all
#rm -f model.weights.h5
cp $WORK_DIR/config_inference.json $MEM_DIR
sed -i "s/ZIN/$DATASET/g" config_inference.json
sed -i "s/\.\/VocabFiles/\.\.\/VocabFiles/g" config_inference.json
sed -i "s/ 400,/ 100,/g" config_inference.json
NNODES=1
TASKS_PER_NODE=8

# Executing runs
srun -N ${NNODES} -n $((NNODES*TASKS_PER_NODE)) -S 0 python3 $WORK_DIR/smiles_regress_transformer_run_large.py -w $STEP2_DIR/model.weights.h5 -d $DATASET

# post-processing
cd $MEM_DIR
python3 $WORK_DIR/sorting.py

# Validating runs
cd $MEM_DIR
python $WORK_DIR/validate_3.py

