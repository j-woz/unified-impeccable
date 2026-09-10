#!/bin/bash
set -eu

# COUNT SMILES SH
# Count SMILES in DATs created by step3

THIS=$( dirname $( realpath $0 ) )
source $THIS/../utils.sh

if (( ${#} != 1 ))
then
  crash "Provide output DIR!  E.g. .../work-Large-1b/step3"
fi

DIR=$1

cd $DIR


GROSS=$( find $DIR -name '*.dat'                    | \
           xargs --max-args 4 --no-run-if-empty cat | \
           wc -l )

FILE_COUNT=$( find $DIR -name '*.dat' | wc -l )

echo SMILES: $[ GROSS - FILE_COUNT ]
