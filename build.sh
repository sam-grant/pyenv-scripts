#!/bin/bash
# Build environment from YAML
# Samuel Grant 2025 
# source this script

echo "👋 Enter new environment name:"
read -r ENV_NAME

if [[ -z "$ENV_NAME" ]]; then 
    echo "❌ Please enter environment name" 
    return 1
else 
    echo "✅ Environment name is ${ENV_NAME}"
fi

echo "👋 Enter starting YAML path"
read -r YAML_FILE

if [[ -z "$YAML_FILE" ]]; then 
    echo "❌ Please enter a path to YAML file" 
    return 1
else 
    echo "✅ YAML is ${YAML_FILE}"
fi

if [[ ! -f "$YAML_FILE" ]]; then 
    echo "❌ YAML file does not exist" 
    exit 1
else 
    echo "✅ YAML file exists" 
fi

COMMAND="mamba env create -n ${ENV_NAME} -f ${YAML_FILE}" 

echo "👋 Executing command: ${COMMAND}"
echo "OK? [Y/n]:"

read -r OK

if [[ "$OK" != "Y" ]]; then 
    echo "❌ Exiting..." 
    return 1
else 
    echo "✅ Building" 
    $COMMAND
    echo "✅ Activating"
    mamba activate ${ENV_NAME}
fi

echo "👋 Copy setup script? [Y/n]:"
read -r OK

if [[ "$OK" != "Y" ]]; then 
    echo "❌ Exiting..." 
    exit 1
else 
    . ./add_setup_script.sh 
    echo "✅ Copied 'env_vars.sh' to ${CONDA_PREFIX}/etc/conda/activate.d/ " 
fi

echo "👋 Install kernel? [Y/N]:"
read -r OK

if [[ "$OK" != "Y" ]]; then 
    echo "❌ Exiting..." 
    exit 1
else 
    . ./install_kernel.sh
    echo "✅ Installed kernel" 
fi

echo "✅ Done" 