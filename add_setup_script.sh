#!/bin/bash
SCRIPT="setup_mu2e_python_env.sh"
DESTINATION="${CONDA_PREFIX}/etc/conda/activate.d/"
cp $SCRIPT $DESTINATION
echo "✅ Copied ${SCRIPT} to ${DESTINATION}" 