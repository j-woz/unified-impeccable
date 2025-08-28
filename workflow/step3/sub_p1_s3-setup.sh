
# SUB P1 S3 SETUP
# Portable setup script
# Assumes SITE, THIS are in the environment

CONDA_ENVIRONMENT=$1

source $THIS/../site-${SITE:-UNKNOWN}-settings.sh $CONDA_ENVIRONMENT

CODE_DIR=$IMPECCABLE_CODE/surrogate_inference
export WORK_DIR=$WORK_TOP/step3

MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
mkdir -p $MEM_DIR
STEP2_DIR=$WORK_DIR/../step2/mem$MEM_ID

# Setting runs
cp -r $CODE_DIR/* $WORK_DIR/
cd $MEM_DIR
DATASET=BDB
mkdir -p output/$DATASET
mkdir -p Sorting_all
#rm -f model.weights.h5
cp $WORK_DIR/config_inference.json $MEM_DIR
sed -i "s/ZIN/$DATASET/g" config_inference.json
sed -i "s@PLACEHOLDER_DIR/VocabFiles@${WORK_DIR}/VocabFiles@g" config_inference.json
sed -i "s/ 400,/ 5,/g" config_inference.json
set -x
NNODES=1
TASKS_PER_NODE=8
set +x
