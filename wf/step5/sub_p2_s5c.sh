#!/bin/bash

#SBATCH -A CHM155_001
#SBATCH -J p2_s5c
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
WORK_DIR=/lustre/orion/chm155/proj-shared/apbhati/IMPECCABLE_2.0/DEBUG_RUN/step5
MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
ITER=0 # p2: 0, p3: >=1
ITR_DIR=$MEM_DIR/itr$ITER
STEP4_DIR=$WORK_DIR/../step4/mem$MEM_ID/itr$ITER

# Setting runs
cd $ITR_DIR
N_COMPS=50
n_replicas=2
NNODES=1
TASKS_PER_NODE=64

# Executing runs
for ((i=0; i<$N_COMPS; i++)); do
	for ((j=0; j<$n_replicas; j++)); do
	cd $ITR_DIR/$i/replicas/rep$j/simulation/mmpbsa
	srun -N ${NNODES} -n $((NNODES*TASKS_PER_NODE)) -S 0 --ntasks-per-node=64 MMPBSA.py.MPI -i mmpbsa.in -sp $ITR_DIR/$i/build/complex.top -cp $ITR_DIR/$i/build/com.top -rp $ITR_DIR/$i/build/rec.top -lp $ITR_DIR/$i/build/lig.top -y ../sim1.dcd
	rm -f reference.frc *.inpcrd *.pdb *.mdin* *.mdcrd*
done

# Post processing
cd $ITR_DIR
bash $WORK_DIR/esmacs_analysis.sh $N_COMPS $WORK_DIR/input $STEP4_DIR 

# Validating runs
python $WORK_DIR/validate_5.py -d $N_COMPS

