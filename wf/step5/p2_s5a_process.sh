#!/bin/bash
set -eu

# P2 S5A PROCESS
# Assumes WORK_DIR in the environment

lig=$1

MEM_ID=0
ITER=0
STEP4_DIR=$WORK_DIR/../step4/mem$MEM_ID/itr$ITER
n_replicas=2
recep_name=rec_4ui5
lig_name=UNL
nframes_per_rep=2
f_start=1
f_end=$nframes_per_rep


mkdir -p $lig/build
cd $lig/build

# Extracting the pose
pose=`sort -n $STEP4_DIR/min/$lig/dg_poses.dat | grep -v NA | head -1 | awk '{print $2}'`
$WORK_DIR/input/catdcd -o com_pose.pdb -otype pdb -stype pdb -s $STEP4_DIR/output_combined_trajectories/pdbs/$recep_name.$lig.pdb -first $pose -last $pose $STEP4_DIR/output_combined_trajectories/dcds/$recep_name.$lig.dcd
grep $lig_name com_pose.pdb > lig_pose.pdb

# Building model
cp $WORK_DIR/input/tleap.in .
sed -i "s|STEP4_MODEL_INPUTS|$WORK_DIR/../step4/model-inputs|g;s|STEP4_ITR_DIR|$STEP4_DIR|g;s|LIG|$lig|g" tleap.in
tleap -s -f tleap.in > tleap.log
awk -f $WORK_DIR/input/constraint.awk complex.pdb $WORK_DIR/input/prot4cons.pdb > cons.pdb

# Building topologies
cp $WORK_DIR/input/tleap-mmpbsa.in .
sed -i "s|STEP4_MODEL_INPUTS|$WORK_DIR/../step4/model-inputs|g;s|STEP4_ITR_DIR|$STEP4_DIR|g;s|LIG|$lig|g" tleap-mmpbsa.in
tleap -s -f tleap-mmpbsa.in > tleap-mmpbsa.log

# Creating MD Input conf  - eq0 (Minimization)
cp $WORK_DIR/input/eq0.conf .
cell=`bash ${WORK_DIR}/input/set-box.sh`
sed -i "s/CELL/$cell/" eq0.conf
cd ../..

for ((j=0 ; j< $n_replicas ; j++ )); do
	# Creating MD input conf - eq1 and sim1 (simulations)
	mkdir -p $lig/replicas/rep$j/equilibration
	cp $lig/build/eq0.conf $lig/replicas/rep$j/equilibration 
	cp $WORK_DIR/input/eq1.conf $lig/replicas/rep$j/equilibration
	mkdir -p $lig/replicas/rep$j/simulation/mmpbsa
	cp $WORK_DIR/input/sim1.conf $lig/replicas/rep$j/simulation

	# Creating MMPBSA input files
	sed "s/START/$f_start/;s/END/$f_end/" $WORK_DIR/input/mmpbsa_template.in > $lig/replicas/rep$j/simulation/mmpbsa/mmpbsa.in

	# Creating links
	#ln -s $ITR_DIR/$lig/replicas/rep$j $ITR_DIR/links/run_$l
	#((l++))
done


