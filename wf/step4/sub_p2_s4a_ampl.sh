#!/bin/bash

#SBATCH -A CHM155_001
#SBATCH -J p2_s4a_ampl
#SBATCH -o %x-%j.out
#SBATCH -e %x-%j.err
#SBATCH -t 1:00:00
#SBATCH -p batch
##SBATCH -q debug
#SBATCH -N 1
#SBATCH --tasks-per-node 64
#SBATCH -S 0

# Setting environments
module reset
source /ccs/proj/chm155/IMPECCABLE/activate_conda.sh
conda activate data_prep_env

# Setting paths
WORK_DIR=/lustre/orion/chm155/proj-shared/apbhati/IMPECCABLE_2.0/DEBUG_RUN/step4
MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
ITER=0 # p2: 0, p3: >=1
ITR_DIR=$MEM_DIR/itr$ITER
mkdir -p $ITR_DIR
TRAJ_DIR=$ITR_DIR/output_combined_trajectories
PDB_DIR=$TRAJ_DIR/pdbs
DCD_DIR=$TRAJ_DIR/dcds
SMILES_FILE=$ITR_DIR/fixpka_compounds.smi # Double check --> compounds.smi vs fixpka_compounds.smi?
MMPBSA_DIR=$ITR_DIR/min
MODE=training
export DEEPCHEM_DATA_DIR=$ITR_DIR/deepchem-cache
mkdir -p $DEEPCHEM_DATA_DIR

# Setting runs
cd $ITR_DIR
NNODES=1
TASKS_PER_NODE=64

# Executing runs
srun -N ${NNODES} -n $((NNODES*TASKS_PER_NODE)) -S 0 --ntasks-per-node=64 python3 $WORK_DIR/ampl/feature_generation_general.py --batch_size 50 --pdb_dir $PDB_DIR --dcd_dir $DCD_DIR --mmpbsa_dir $MMPBSA_DIR --smiles_file $SMILES_FILE --num_processes $TASKS_PER_NODE --mode $MODE

