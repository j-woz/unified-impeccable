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

# Setting environments
module reset
module load cpe/23.09
module load PrgEnv-gnu
source /ccs/proj/chm155/IMPECCABLE/activate_conda.sh
conda activate AmberTools23_Frontier-Balint

# Setting paths
CODE_DIR=/lustre/orion/chm155/proj-shared/apbhati/IMPECCABLE_2.0/esmacs
WORK_DIR=/lustre/orion/chm155/proj-shared/apbhati/IMPECCABLE_2.0/DEBUG_RUN/step5
MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
ITER=0 # p2: 0, p3: >=1
ITR_DIR=$MEM_DIR/itr$ITER
mkdir -p $ITR_DIR
#mkdir -p $ITR_DIR/links
STEP4_DIR=$WORK_DIR/../step4/mem$MEM_ID/itr$ITER

# Setting runs
cp -r $CODE_DIR/* $WORK_DIR/
N_COMPS=50
n_replicas=2
recep_name=rec_4ui5
lig_name=UNL
nframes_per_rep=2
fstart=1
fend=$nframes_per_rep

# Executing runs
cd $ITR_DIR
#l=0
for ((i=0; i<$N_COMPS; i++)); do
	srun -n1 -N1 -c1 bash $WORK_DIR/p2_s5a_process.sh $i &
	sleep 0.2
done

wait

