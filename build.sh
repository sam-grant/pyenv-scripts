#!/bin/bash
# Build environment from YAML
# Samuel Grant 2025 
# source this script

echo "👋 Enter new environment name:"
read -r ENV_NAME

if [[ -z "$ENV_NAME" ]]; then 
    echo "❌ Please enter new environment name" 
    return 1
else 
    echo "✅ New environment name is ${ENV_NAME}"
fi

echo "👋 Enter starting environment name (to build from YAML)"
read -r YAML_ENV_NAME
YAML_FILE="/exp/mu2e/data/users/sgrant/EAF/env/yml/${YAML_ENV_NAME}.yml"

echo $YAML_FILE
if [[ -z "$YAML_FILE" ]]; then 
    echo "❌ Please enter a starting environment name" 
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