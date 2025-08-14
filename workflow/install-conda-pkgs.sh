#!/bin/bash

# INSTALL CONDA PKGS SH
# User can tar this Anaconda installation for faster reuse
#   See python-aurora.sh

CHANNELS=( -c conda-forge
           -c openeye
         )
PKGS=( pydantic-settings
       openeye-toolkits
     )

conda install ${CHANNELS[@]} ${PKGS[@]}
