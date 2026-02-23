
# SUB PS S5C SETUP

if (( ${#*} != 2 ))
then
  echo "sub_p2_s5c-setup: " \
       "Provide CONDA_INSTALLATION CONDA_ENVIRONMENT!"
  return 1
fi

CONDA_INSTALLATION=$1
CONDA_ENVIRONMENT=$2

source $WORKFLOW_DIR/utils.sh

source $THIS/../site-${SITE:-UNKNOWN}-settings.sh \
       $CONDA_INSTALLATION $CONDA_ENVIRONMENT

export WORK_DIR=$WORK_TOP/step5

# Setting paths
MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
ITER=0 # p2: 0, p3: >=1
ITR_DIR=$MEM_DIR/itr$ITER
STEP4_DIR=$WORK_DIR/../step4/mem$MEM_ID/itr$ITER

# Setting runs
cd $ITR_DIR
NNODES=1
TASKS_PER_NODE=1
