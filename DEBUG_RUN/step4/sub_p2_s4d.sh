#!/bin/bash

#SBATCH -A CHM155_001
#SBATCH -J p2_s4d
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
WORK_DIR=/lustre/orion/chm155/proj-shared/apbhati/IMPECCABLE_2.0/DEBUG_RUN/step4
MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
ITER=0 # p2: 0, p3: >=1
ITR_DIR=$MEM_DIR/itr$ITER

# Setting runs
cd $ITR_DIR
#mkdir -p min/links 
N_COMPS=50
f_start=1
POSES=100
f_end=$POSES
NNODES=1
TASKS_PER_NODE=64
sed -i "s/{0..\$ndir}\///g; s/mdout.0/mdout.{0..\$ndir}/g" $WORK_DIR/sort_poses.sh

# Executing runs
for ((i=0; i<$N_COMPS; i++)); do
	mkdir -p min/$i/mmpbsa
	sed "s/START/$f_start/;s/END/$f_end/" $WORK_DIR/model-inputs/mmpbsa.in > $ITR_DIR/min/$i/mmpbsa/mmpbsa.in
	#ln -s $ITR_DIR/min/$i/mmpbsa $ITR_DIR/min/links/$i
	cd min/$i/mmpbsa
	srun -N ${NNODES} -n $((NNODES*TASKS_PER_NODE)) -S 0 --ntasks-per-node=64 MMPBSA.py.MPI -i mmpbsa.in -sp $ITR_DIR/models/$i/complex.top -cp $ITR_DIR/models/$i/com.top -rp $ITR_DIR/models/$i/rec.top -lp $ITR_DIR/models/$i/lig.top -y $ITR_DIR/min/$i/min.dcd
	rm -f reference.frc *.inpcrd *.pdb *.mdin* *.mdcrd*
	cd ..
	bash $WORK_DIR/sort_poses.sh $TASKS_PER_NODE
	cd ../..
done

# Validating runs
cd $ITR_DIR
python $WORK_DIR/validate_4.py -s $N_COMPS

