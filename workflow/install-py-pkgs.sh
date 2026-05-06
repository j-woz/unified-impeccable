#!/bin/bash

# INSTALL CONDA PKGS SH
# User can tar this Anaconda installation for faster reuse
#   See python-aurora.sh

# Install OpenEye by copying from Frontier

THIS=$( dirname $0 )
LABEL="install-py-pkgs"

source $THIS/utils.sh

msg START

module list

if ! conda info >& /dev/null
then
  crash "conda command fails!"
fi

CONDA_BASE=$( conda info --base )
show CONDA_BASE
source $CONDA_BASE/bin/activate

ENVIRONMENT=step12345
show ENVIRONMENT
ENVDIR=/tmp/PY-IMPECCABLE/envs/$ENVIRONMENT
if ! [[ -d $ENVDIR ]]
then
  @ -e conda create --yes -p $ENVDIR
fi
@   -e conda activate        $ENVDIR

set -eu

CHANNELS=( -c conda-forge
           -c openeye
         )

# Installation steps12:
# try module frameworks/2024.2.1_u1 in /opt/aurora/24.180.3 - DELETED 2026-03-11
# try module frameworks/2025.3.1 in /opt/aurora/26.26

# Installation step3
# module tensorflow is
#  conda  /opt/aurora/25.190.0/oneapi/intel-conda-miniforge
#  env    /opt/aurora/25.190.0/frameworks/aurora_tensorflow-2025.2.0

# Installation step4a:
# try module frameworks/2025.3.1 plus conda packages below

PKGS_CONDA=(
  # Step 1
  pydantic-settings
  openeye-toolkits
  rdkit
  pyyaml
  # Install mpi4py from GitHub checkout using ./install-mpi4py.sh

  # Step 2 +PIP
  exceptiongroup
  # Also needed (but use PIP):
  # horovod keras tensorflow ipython

  # Step 3 +PIP
  pandas 'numpy==1.26.4'

  # Step 4a:
  mdanalysis openeye-toolkits rdkit
  # Step 5b:
  # Works with all in frameworks/2024
  ambertools
)
PKGS_PIP=(
  # Step 2
  pandas IPython scikit-learn SmilesPE transformers
  # must pin 'numpy==1.26.4' to retain ALCF version!
  # do not allow version change!

  # Step 3
  # Install mpi4py from GitHub checkout using ./install-mpi4py.sh
  SmilesPE IPython transformers
)

@ conda install --yes ${CHANNELS[@]} ${PKGS_CONDA[@]}

exit  #  WAIT ON STEP 6

set +eu

ENVIRONMENT=step6
show ENVIRONMENT
@ -e conda create --yes -p /tmp/PY-IMPECCABLE/envs/$ENVIRONMENT
@ -e conda activate /tmp/PY-IMPECCABLE/envs/$ENVIRONMENT

# REINVENT
# Needs its own environment, conflicts with learning libraries
set -eu
mkdir -pv /tmp/$USER
cd        /tmp/$USER
@ git clone --quiet git@github.com:MolecularAI/REINVENT4.git
cd REINVENT4
# Approach 1: Works but installs to ~/.local
# python install.py cpu
# PATH=$HOME/.local/aurora/frameworks/2024.2.1_u1/bin:$PATH
# Approach 2: Works
python3 -m venv /tmp/PY-IMPECCABLE/envs/step6/venv_reinvent --system-site-packages
set +eu
@ -e source /tmp/PY-IMPECCABLE/envs/step6/venv_reinvent/bin/activate
set -eu
@ python install.py cpu

echo
msg SUCCESS
