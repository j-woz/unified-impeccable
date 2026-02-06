#!/bin/bash
lig=$1
ITR_DIR=$2
WORK_DIR=$3

#Execute commands for each ligand
# Parameter generation
mkdir -p par-gen/$lig
cd par-gen/$lig
chrg=`awk -F, -v lig=$lig '($1==lig) {print $2}' $ITR_DIR/charges.csv`
antechamber -i $ITR_DIR/lig_confs/$lig/0.pdb -fi pdb -c bcc -nc $chrg -at gaff2 -o $lig.mol2 -fo mol2
parmchk2 -i $lig.mol2 -f mol2 -o $lig.frcmod -s 2
cd ../..

# Model Building
mkdir -p models/$lig
cd models/$lig
sed "s/LIG/$lig/g" $WORK_DIR/model-inputs/tleap-nowat.in > tleap.in
tleap -s -f tleap.in > tleap.log
cd ../..

