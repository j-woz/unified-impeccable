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

export THIS=$SLURM_SUBMIT_DIR
cd $THIS

export SITE=frontier

source $THIS/../impeccable-settings.sh
source $THIS/sub_p2_s4d-setup.sh AmberTools23_Frontier-Balint

# Executing runs
set -eux
for ((i=0; i<$N_COMPS; i++)); do
	mkdir -pv min/$i/mmpbsa
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
