
# SETUP AURORA
# Software settings for Aurora
# This contains:
# 1. General software settings (modules, schedulers, etc.)
# 2. Any Python settings so that the python in PATH is ready to run
#    Accepts CONDA_INSTALLATION CONDA_ENVIRONMENT
#    Can provide "-" to skip Anaconda setup
# 3. User settings including the IMPECCABLE clone and output directory
# Assumes:
#   utils.sh has been sourced
#   Environment:
#     WORKFLOW_STEP

## GENERAL SOFTWARE

LABEL="site-aurora"

if (( ${#*} != 2 ))
then
  msg "Provide CONDA_INSTALLATION CONDA_ENVIRONMENT!"
  return 1
fi

CONDA_INSTALLATION=$1
CONDA_ENVIRONMENT=$2

# OpenEye license
export OE_LICENSE=/lus/flare/projects/workflow_scaling/wozniak/IMPECCABLE/oe_license.txt

# For mpiexec:
PATH=/opt/cray/pals/1.8/bin:$PATH

# In all cases, the user sets NODES and PPN
# In case we need PROCS, we set it here:
PROCS=$[ NODES * PPN ]
show NODES PPN PROCS

msg "module list"
set +eu
# Modules
source /usr/share/lmod/lmod/init/bash
# MODULEPATH as of 2026-04-22
export MODULEPATH=/opt/aurora/25.190.0/spack/unified/0.10.1/install/modulefiles/Core:/opt/aurora/25.190.0/spack/unified/0.10.1/install/modulefiles/oneapi/2025.2.0:/usr/share/lmod/modulefiles/Linux:/usr/share/lmod/modulefiles/Core:/usr/share/lmod/lmod/modulefiles/Core:/opt/cray/pals/lmod/modulefiles/core:/opt/cray/modulefiles:/opt/aurora/26.26.0/modulefiles:/opt/aurora/25.190.0/modulefiles
set -eu

# PROGRAM SETTINGS

WORKFLOW_DIR=$( realpath $WORKFLOW_STEP/.. )
PATH=$WORKFLOW_DIR:$PATH

AFFINITY=$( realpath $WORKFLOW_STEP/../affinity-aurora.sh )

OPENEYE=/lus/flare/projects/workflow_scaling/wozniak/proj/openeye
QUACPAC=$OPENEYE/arch/redhat-RHEL8-x64/quacpac
PATH=$QUACPAC:$OPENEYE/bin:$PATH

# NAMD?

## PYTHON SETTINGS

if [[ $CONDA_INSTALLATION != "-" ]]
then
  if source $WORKFLOW_STEP/../setup-aurora-python.sh
  then
    msg "setup-aurora-python.sh OK"
  else
    echo "setup-aurora-python.sh FAILED"
    return 1
  fi

  msg "Python: installation: $CONDA_INSTALLATION"
  CONDA_SCRIPT=$CONDA_INSTALLATION/etc/profile.d/conda.sh
  if ! [[ -f $CONDA_SCRIPT ]]
  then
    msg "does not exist: $CONDA_SCRIPT"
    return 1
  fi

  # Must disable error checking while sourcing conda scripts
  # because they commonly have spurious errors:
  set +eu
  source $CONDA_SCRIPT
  set -eu
else
  msg "Not initializing a Python installation."
fi

if [[ $CONDA_ENVIRONMENT != "-" ]]
then
  msg "Python: activate:     $CONDA_ENVIRONMENT"
  set +eu
  if conda activate $CONDA_ENVIRONMENT
  then
    : OK
  else
    msg "could not activate: '$CONDA_ENVIRONMENT'"
    exit 1
  fi
  set -eu
else
  msg "Not activating a Conda environment."
fi

report-py-settings

# Need MPICH for mpi4py
set +eu
module load oneapi mpich
set -eu

## USER SETTINGS
# Do not commit changes here to git: they are specific to the user

# Frontier:
# CODE_DIR=/lustre/orion/chm155/proj-shared/$USER/IMPECCABLE_2.0/htp_docking
# IMPECCABLE_WORK=/lustre/orion/chm155/proj-shared/$USER/IMPECCABLE_2.0/workflow/step1

# This is the user's git clone of IMPECCABLE:
IMPECCABLE_CODE=$HOME/proj/IMPECCABLE_2.0
