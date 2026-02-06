#!/bin/bash

# INSTALL CONDA PKGS SH
# User can tar this Anaconda installation for faster reuse
#   See python-aurora.sh

# Install OpenEye by copying from Frontier

CHANNELS=( -c conda-forge
           -c openeye
         )
PKGS=( pydantic-settings
       openeye-toolkits
       # Step 4a:
       mdanalysis
     )

conda install ${CHANNELS[@]} ${PKGS[@]}
