
# SUB P1 S2 SETUP
# Portable setup script
# Assumes SITE is in the environment

if (( ${#*} != 2 ))
then
  echo "sub_p1_s2-setup: " \
       "Provide CONDA_INSTALLATION CONDA_ENVIRONMENT!"
  return 1
fi

CONDA_INSTALLATION=$1
CONDA_ENVIRONMENT=$2

source $WORKFLOW_DIR/utils.sh

source $THIS/../site-${SITE:-UNKNOWN}-settings.sh \
       $CONDA_INSTALLATION $CONDA_ENVIRONMENT

# Setting paths
CODE_DIR=$IMPECCABLE_CODE/surrogate_training
export WORK_DIR=$WORK_TOP/step2
MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
mkdir -p $MEM_DIR
STEP1_DIR=$WORK_DIR/../step1/mem$MEM_ID

# Setting runs
cp -r $CODE_DIR/* $WORK_DIR/
cd $MEM_DIR
mkdir -p trainoutput
#rm model.weights.h5

cp -v $WORK_DIR/config_training.json .

sed -i "s@PLACEHOLDER_DIR/VocabFiles@${WORK_DIR}/VocabFiles@g" config_training.json
sed -i "s/ 300,/ 10,/g" config_training.json
(
  set -x
  python $WORK_DIR/preprocess.py -s $STEP1_DIR/scores -o trainoutput
)
NNODES=1
TASKS_PER_NODE=8
