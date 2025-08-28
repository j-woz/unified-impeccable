#!/bin/bash

#SBATCH -A CHM155_001
#SBATCH -J p2_s4a
#SBATCH -o %x-%j.out
#SBATCH -e %x-%j.err
#SBATCH -t 1:00:00
#SBATCH -p batch
#SBATCH -q debug
#SBATCH -N 1
#SBATCH --tasks-per-node 64
#SBATCH -S 0

# Setting environments
module reset
export PATH=$PATH:/lustre/orion/chm155/proj-shared/openeye/arch/redhat-RHEL8-x64/quacpac:/lustre/orion/chm155/proj-shared/openeye/bin
export OE_LICENSE=/ccs/proj/chm155/IMPECCABLE/High-Throughput-Docking/oe_license.txt
source /ccs/proj/chm155/IMPECCABLE/activate_conda.sh
conda activate oepython_new

# Setting paths
CODE_DIR=/lustre/orion/chm155/proj-shared/apbhati/IMPECCABLE_2.0/pose_generation
WORK_DIR=/lustre/orion/chm155/proj-shared/apbhati/IMPECCABLE_2.0/DEBUG_RUN/step4
MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
ITER=0 # p2: 0, p3: >=1
ITR_DIR=$MEM_DIR/itr$ITER
mkdir -p $ITR_DIR
STEP3_DIR=$WORK_DIR/../step3/mem$MEM_ID

# Setting runs
cp -r $CODE_DIR/* $WORK_DIR/
cd $ITR_DIR
mkdir -p output_combined_trajectories/dcds
mkdir -p output_combined_trajectories/pdbs
mkdir -p lig_confs
mkdir -p scores
mkdir -p temp
comp_file=$STEP3_DIR/sorted_data.csv # STEP6_DIR/reinvent.csv for p3
N_COMPS=50
#POSES=100 # hard-coded as "max_confs=100": add as an argument
col_id=1 # col_id=5 for p3
recep_file_dir=$WORK_DIR/../step1/input
recep_file=rec_4ui5.oedu
protein_pdb=prot.pdb
NNODES=1
TASKS_PER_NODE=64

# Pre-processing
awk -F, -v comp=$N_COMPS -v col=$col_id '(NR>1 && NR<=comp+1) {print $col"\t"NR-2}' $comp_file > compounds.smi
fixpka compounds.smi fixpka_compounds.smi
sed 's/[^+]//g' fixpka_compounds.smi | awk '{ print length }' > pos.dat
awk -F '-]' '{ print NF - 1}' fixpka_compounds.smi > neg.dat
paste pos.dat neg.dat fixpka_compounds.smi | awk '{ print $NF","$1-$2 }' > charges.csv

# Executing runs
srun -N ${NNODES} -n $((NNODES*TASKS_PER_NODE)) -S 0 --ntasks-per-node=64 python $WORK_DIR/docking_openeye_pose.py -s fixpka_compounds.smi -r $recep_file_dir/$recep_file -p $WORK_DIR/input/$protein_pdb -o output_combined_trajectories

