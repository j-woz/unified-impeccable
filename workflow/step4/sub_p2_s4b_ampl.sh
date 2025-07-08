#!/bin/bash

#SBATCH -A CHM155_001
#SBATCH -J p2_s4a_ampl
#SBATCH -o %x-%j.out
#SBATCH -e %x-%j.err
#SBATCH -t 1:00:00
#SBATCH -p batch
##SBATCH -q debug
#SBATCH -N 1
#SBATCH --tasks-per-node 8
#SBATCH -S 0

# Setting environments
module reset
source /ccs/proj/chm155/IMPECCABLE/activate_conda.sh
conda activate atomsci160

# Setting paths
WORK_DIR=/lustre/orion/chm155/proj-shared/apbhati/IMPECCABLE_2.0/DEBUG_RUN/step4
MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
ITER=0 # p2: 0, p3: >=1
ITR_DIR=$MEM_DIR/itr$ITER
export DEEPCHEM_DATA_DIR=$ITR_DIR/deepchem-cache
mkdir -p $DEEPCHEM_DATA_DIR

# Setting runs
cd $ITR_DIR
NNODES=1
TASKS_PER_NODE=8
tasks=$((NNODES*TASKS_PER_NODE))

# Pre-processing
python3 $WORK_DIR/ampl/training_params_generator.py --node_count $NNODES

# Model training
for ((i=0; i<$tasks; i++)); do
	srun -n1 -N1 -c1 --gpus 1 --gpus-per-node 1 --gpu-bind=closest python3 $WORK_DIR/ampl/model_training.py --index $i &
done
wait

# Post Processing - Selecting trained model
srun -N1 -n1 -c1 --gpus 1 --gpus-per-node 1 --gpu-bind=closest python3 $WORK_DIR/ampl/select_model.py

