
CONDA_ENVIRONMENT=$1
source $THIS/../site-${SITE:-UNKNOWN}-settings.sh $CONDA_ENVIRONMENT

export WORK_DIR=$WORK_TOP/step4

# Setting paths
CODE_DIR=$IMPECCABLE_CODE/esmacs
export WORK_DIR=$WORK_TOP/step5
MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
ITER=0 # p2: 0, p3: >=1
ITR_DIR=$MEM_DIR/itr$ITER
mkdir -p $ITR_DIR
#mkdir -p $ITR_DIR/links
STEP4_DIR=$WORK_DIR/../step4/mem$MEM_ID/itr$ITER

echo CODE_DIR $CODE_DIR

# Setting runs
cp -ur $CODE_DIR/* p2_s5a_process.sh $WORK_DIR/
N_COMPS=5
n_replicas=2
recep_name=rec_4ui5
lig_name=UNL
nframes_per_rep=2
fstart=1
fend=$nframes_per_rep
