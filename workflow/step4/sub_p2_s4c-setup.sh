
# SUB P2 S4C SETUP

if (( ${#*} != 0 ))
then
  echo "sub_p2_s4c-setup: Provide no arguments!"
  return 1
fi

source $WORKFLOW_DIR/utils.sh

source $THIS/../site-${SITE:-UNKNOWN}-settings.sh - -

export WORK_DIR=$WORK_TOP/step4
MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
ITER=0 # p2: 0, p3: >=1
ITR_DIR=$MEM_DIR/itr$ITER
mkdir -pv $ITR_DIR

# Setting runs
cd $ITR_DIR
