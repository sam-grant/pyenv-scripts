#!/bin/bash

echo "👋 ana or rootana?"
read -r ENV_TYPE

# SCRIPT=""

# if [[ "$ENV_TYPE" == "ana" ]]; then 
#     SCRIPT="setup_mu2e_python_env.sh"
# elif [[ "$ENV_TYPE" == "rootana" ]]; then 
#     SCRIPT="setup_mu2e_pyroot_env.sh"
# else
#     echo "❌ Invalid entry" 
#     return 1
# fi

SCRIPT="setup_mu2e_python_env.sh"

DESTINATION="${CONDA_PREFIX}/etc/conda/activate.d/"

cp $SCRIPT $DESTINATION

echo "✅ Copied ${SCRIPT} to ${DESTINATION}" 