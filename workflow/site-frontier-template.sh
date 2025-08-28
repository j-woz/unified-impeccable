
# SITE FRONTIER SETTINGS
# Software setup for Frontier
# Should contain:
# 1. General software settings (modules, schedulers, etc.)
# 2. Any Python settings so that the python in PATH is ready to run
# 3. User settings including the IMPECCABLE clone and output directory

CONDA_ENVIRONMENT=$1

## GENERAL SOFTWARE

# OpenEye license
export OE_LICENSE=/ccs/proj/chm155/IMPECCABLE/High-Throughput-Docking/oe_license.txt

## PYTHON SETTINGS

# These functions trigger errors:
set +eu
source /ccs/proj/chm155/IMPECCABLE/activate_conda.sh
echo "site-frontier-settings.sh: activating:" $CONDA_ENVIRONMENT
conda activate $CONDA_ENVIRONMENT
set -eu

echo "site-frontier-settings.sh: python:" $( which python )
echo "site-frontier-settings.sh: CONDA_PREFIX:" ${CONDA_PREFIX}

## USER SETTINGS
# Do not commit changes here to git: they are specific to the user

TOP=/lustre/orion/chm155/proj-shared/wozniak

# This is the user's git clone of IMPECCABLE:
IMPECCABLE_CODE=$TOP/IMPECCABLE.jw

# Per-user top-level output directory
# Each step has a separate directory under here:
WORK_TOP=$TOP/wf-out
