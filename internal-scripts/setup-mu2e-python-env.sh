#!/bin/bash
# Samuel Grant 2024-2025
# Environment setup & protection

# Define environment configuration
setup_mu2e_python_env() { # Long & specific name to avoid conflicts
    # Clean and set PATH
    PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "$CONDA_PREFIX" | tr '\n' ':' | sed 's/:$//')
    export PATH="$CONDA_PREFIX/bin:$PATH"
    
    # Clean and set PYTHONPATH
    PYTHONPATH=$(echo "$PYTHONPATH" | tr ':' '\n' | grep -v "$CONDA_PREFIX" | tr '\n' ':' | sed 's/:$//')
    export PYTHONPATH="$CONDA_PREFIX/lib/python3.12/site-packages:$PYTHONPATH"
    
    # Clean and set JUPYTER_PATH
    JUPYTER_PATH=$(echo "$JUPYTER_PATH" | tr ':' '\n' | grep -v "$CONDA_PREFIX" | tr '\n' ':' | sed 's/:$//')
    export JUPYTER_PATH="$CONDA_PREFIX/share/jupyter/kernels:$JUPYTER_PATH"
    
    # Set other environment variables 
    export QT_QPA_PLATFORM_PLUGIN_PATH="$CONDA_PREFIX/lib/qt6/plugins/platforms"
    export FONTCONFIG_FILE="$CONDA_PREFIX/etc/fonts/fonts.conf"

    # Fix git SSL within conda environment
    export GIT_SSL_CAINFO="/etc/pki/tls/certs/ca-bundle.crt"

    # Fix terminal info databse
    export TERMINFO="$CONDA_PREFIX/share/terminfo"
    
    # This one is unique to pyroot
    export CONDA_BUILD_SYSROOT="$CONDA_PREFIX/x86_64-conda-linux-gnu/sysroot"

    # For CUDA (GPU support)

    # Log levels
    export TF_CPP_MIN_LOG_LEVEL=3
    export ZFIT_DISABLE_TF_WARNINGS=1
    # Library paths
    LD_LIBRARY_PATH=$(echo "$LD_LIBRARY_PATH" | tr ':' '\n' | grep -v "$CONDA_PREFIX" | tr '\n' ':' | sed 's/:$//')
    export LD_LIBRARY_PATH="$CONDA_PREFIX/lib:$LD_LIBRARY_PATH"
}

# Initial setup
setup_mu2e_python_env

# Create wrapper functions for protected commands
for cmd in python pip jupyter conda mamba; do
    eval "${cmd}() {
        setup_mu2e_python_env
        command ${cmd} \"\$@\"
    }"
    export -f "$cmd"
done

# Export the setup function for manual use if needed
export -f setup_mu2e_python_env

