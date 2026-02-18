
# SUB P2 S4A SETUP
# Portable setup script
# Assumes SITE is in the environment

if (( ${#*} != 2 ))
then
  echo "sub_p2_s4-setup: " \
       "Provide CONDA_INSTALLATION CONDA_ENVIRONMENT!"
  return 1
fi

CONDA_INSTALLATION=$1
CONDA_ENVIRONMENT=$2

source $WORKFLOW_DIR/utils.sh

source $THIS/../site-${SITE:-UNKNOWN}-settings.sh \
       $CONDA_INSTALLATION $CONDA_ENVIRONMENT

CODE_DIR=$IMPECCABLE_CODE/pose_generation
export WORK_DIR=$WORK_TOP/step4

MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID

ITER=0 # p2: 0, p3: >=1
ITR_DIR=$MEM_DIR/itr$ITER
mkdir -p $ITR_DIR
STEP3_DIR=$WORK_DIR/../step3/mem$MEM_ID

# Setting runs
cp -r $CODE_DIR/* $WORK_DIR/
cd $ITR_DIR
mkdir -p output_combined_trajectories/dcds
mkdir -p output_combined_trajectories/pdbs
mkdir -p lig_confs
mkdir -p scores
mkdir -p temp
comp_file=$STEP3_DIR/sorted_data.csv # STEP6_DIR/reinvent.csv for p3
#POSES=100 # hard-coded as "max_confs=100": add as an argument
col_id=1 # col_id=5 for p3
recep_file_dir=$WORK_DIR/../step1/input
recep_file=rec_4ui5.oedu
protein_pdb=prot.pdb
NNODES=1
TASKS_PER_NODE=64

# Pre-processing
awk -F, -v comp=$N_COMPS -v col=$col_id '(NR>1 && NR<=comp+1) {print $col"\t"NR-2}' $comp_file > compounds.smi
fixpka compounds.smi fixpka_compounds.smi
sed 's/[^+]//g' fixpka_compounds.smi | awk '{ print length }' > pos.dat
awk -F '-]' '{ print NF - 1}' fixpka_compounds.smi > neg.dat
paste pos.dat neg.dat fixpka_compounds.smi | awk '{ print $NF","$1-$2 }' > charges.csv
