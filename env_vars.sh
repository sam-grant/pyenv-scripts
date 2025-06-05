#!/bin/bash
export PATH="$CONDA_PREFIX/bin:$PATH" # Interpreter 
export PYTHONPATH="$CONDA_PREFIX/lib/python3.12/site-packages:$PYTHONPATH" # Packages
export QT_QPA_PLATFORM_PLUGIN_PATH="$CONDA_PREFIX/lib/qt6/plugins/platforms" # Matplotlib GUI plugin 
export FONTCONFIG_FILE="$CONDA_PREFIX/etc/fonts/fonts.conf" # Matplotlib fonts 
export JUPYTER_PATH="$CONDA_PREFIX/share/jupyter/kernels:$JUPYTER_PATH" # Path to kernel
