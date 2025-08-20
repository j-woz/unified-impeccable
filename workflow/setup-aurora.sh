
# SETUP AURORA
# Software setup for Aurora
# Should contain:
# 1. General software settings (modules, schedulers, etc.)
# 2. Any Python settings so that the python in PATH is ready to run
# 3. User settings including the IMPECCABLE clone and output directory

## GENERAL SOFTWARE

# OpenEye license
export OE_LICENSE=/lus/flare/projects/workflow_scaling/wozniak/IMPECCABLE/oe_license.txt

# For mpiexec:
PATH=/opt/cray/pals/1.4/bin:$PATH

## PYTHON SETTINGS

if [[ ! -e /tmp/TF ]]
then
  # TAR=/lus/flare/projects/candle_aesp_CNDA/sfw/TF.tar
  TAR=~/W/wozniak/conda-tgz/TF-IMPECCABLE.tar
  echo "setup-aurora.sh: extracting $TAR ..."
  tar xf $TAR -C /tmp
  echo "setup-aurora.sh: extracted."
fi

# These functions trigger errors:
echo "setup-aurora.sh: module load frameworks..."
set +eu
# This source suppresses warnings about conda deactivate:
source /opt/aurora/24.347.0/oneapi/intel-conda-miniforge/etc/profile.d/conda.sh
module load frameworks
echo "setup-aurora.sh: activating anaconda..."
conda activate /tmp/TF
set -eu

echo "setup-aurora.sh: python:" $( which python )
echo "setup-aurora.sh: CONDA_PREFIX:" ${CONDA_PREFIX}

## USER SETTINGS

# Frontier:
# CODE_DIR=/lustre/orion/chm155/proj-shared/$USER/IMPECCABLE_2.0/htp_docking
# WORK_TOP=/lustre/orion/chm155/proj-shared/$USER/IMPECCABLE_2.0/workflow/step1

# This is the user's git clone of IMPECCABLE:
IMPECCABLE_CODE=$HOME/proj/IMPECCABLE_2.0

# Per-user top-level output directory
# Each step has a separate directory under here:
WORK_TOP=/lus/flare/projects/workflow_scaling/wozniak/IMPECCABLE/workflow
