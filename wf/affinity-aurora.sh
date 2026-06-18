#!/usr/bin/env bash

# Sets up 

# From ALCF
# https://docs.alcf.anl.gov/aurora/compiling-and-linking/aurora-example-program-makefile

# PALS:
RANK=$PALS_LOCAL_RANKID
# MPICH:
# RANK=$PMI_RANK

# Convert PPN into affinity settings:
if [[ ${PPN:-} == "" ]]
then
  echo "affinity-aurora: Set PPN!"
  exit 1
elif (( PPN == 12 ))
then
  export AURORA_GPUS=6
  export AURORA_TILES=2
elif (( PPN <= 6 || PPN >= 1 ))
then
  export AURORA_GPUS=$PPN
  export AURORA_TILES=1
else
  echo "bad affinity setting: PPN=$PPN"
  exit 1
fi

NUM_GPU=$AURORA_GPUS
NUM_TILE=$AURORA_TILES

GPU_ID=$((  ( RANK / NUM_TILE ) % NUM_GPU ))
TILE_ID=$((   RANK % NUM_TILE   ))

unset EnableWalkerPartition
export ZE_ENABLE_PCI_ID_DEVICE_ORDER=1
export ZE_AFFINITY_MASK=$GPU_ID.$TILE_ID
export ZE_ENABLE_API_TRACING=0

# printf "RANK= %4i gpu= ${GPU_ID}  tile= ${TILE_ID} MASK=$ZE_AFFINITY_MASK\n" $RANK

# Execute the user command!
# https://stackoverflow.com/a/28099707/7674852
"$@"

# if [[ ${AURORA_GPUS:-} == "" ]]
# then
#   if [[ ${RANK:-0} == 0 ]]
#   then
#     echo "affinity-aurora.sh: Set AURORA_GPUS!"
#     exit 1
#   fi
# fi
# if [[ ${AURORA_TILES:-} == "" ]]
# then
#   if [[ ${RANK:-0} == 0 ]]
#   then
#     echo "affinity-aurora.sh: Set AURORA_TILES!"
#     exit 1
#   fi
# fi
