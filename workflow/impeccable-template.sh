
# Per-user workflow settings- exported to M4 filter
# Do not commit user changes to git!

WORKFLOW_DIR=$( realpath $( dirname $BASH_SOURCE ) )

# Location relative to WORK_DIR
export SMILES_INPUT=input/Training.smi
# Location relative to WORK_DIR
export RECEP_FILE=input/rec_4ui5.oedu
# export INFERENCE_DATA=/lustre/orion/chm155/proj-shared/wozniak/InferenceData
export INFERENCE_DATA=/lustre/orion/chm155/proj-shared/avasan/InferenceData
export DATASET=BDB
# Number of samples.  Reduce for shorter workflow.
export SAMPLE_SIZE=1000

# Used for Step 4+...
N_COMPS=50
