#!/bin/bash
set -u

# P2 S4B PROCESS
# Runs antechamber, tleap, parmchk2
# Checks for errors, writes log.txt in each subdirectory
# If an error occurs, touches file ERROR
#                     and puts timestamps in logs

lig=$1
ITR_DIR=$2
WORK_DIR=$3

HNAME=$(hostname)
LABEL="p2_s4b_process.sh:${TURBINE_APP_LABEL:-}:$HNAME"
msg()
# MeSsaGe
# Copied from utils.sh to here for speed
{
  echo $( date "+%Y-%m-%d %H:%M:%S" ) ${LABEL:-}: "${*}"
}

handle-error()
{
  msg "ERROR" ${*}
  touch par-gen/$lig/ERROR models/$lig/ERROR
  msg "ERROR" >> par-gen/$lig/log.txt
  msg "ERROR" >> models/$lig/log.txt
}

mkdir -p par-gen/$lig models/$lig

PDB=$ITR_DIR/lig_confs/$lig/0.pdb

if [[ -f $PDB ]]
then
  echo "PDB: $PDB" $( stat --format "%s" $PDB )
else
  handle-error "PDB not found: $PDB"
  exit # Normal exit, allow workflow to proceed
fi

# These are in conda package ambertools
which antechamber tleap parmchk2 > /dev/null || exit 1

(
  set -eu
  T0=$SECONDS
  cd par-gen/$lig
  exec > log.txt 2>&1

  msg "par-gen" $lig $ITR_DIR $WORK_DIR START

  #Execute commands for each ligand
  # Parameter generation
  # mkdir -p par-gen/$lig

  chrg=`awk -F, -v lig=$lig '($1==lig) {print $2}' $ITR_DIR/charges.csv`
  antechamber -i $ITR_DIR/lig_confs/$lig/0.pdb -fi pdb -c bcc \
              -nc $chrg -at gaff2 -o $lig.mol2 -fo mol2 > antechamber.out
  parmchk2 -i $lig.mol2 -f mol2 -o $lig.frcmod -s 2 > parmchk2.out
  # cd ../..
  T1=$SECONDS
  msg "par-gen" $lig "TIME:" $[ T1 - T0 ]
)
if (( ${?} ))
then
  handle-error "for par-gen in lig=$lig"
  exit # Normal exit, allow workflow to proceed
fi

# Model Building
(
  T0=$SECONDS
  cd models/$lig
  exec > log.txt 2>&1
  msg "tleap" $lig $ITR_DIR $WORK_DIR START
  pwd
  sed "s/LIG/$lig/g" $WORK_DIR/model-inputs/tleap-nowat.in > tleap.in
  tleap -s -f tleap.in > tleap.stdout
  # cd ../..
  T1=$SECONDS
  msg "models" $lig "TIME:" $[ T1 - T0 ]
)
if (( ${?} ))
then
  handle-error "for tleap in lig=$lig"
  exit # Normal exit, allow workflow to proceed
fi
