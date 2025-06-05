#!/bin/bash
# Distribute current environment 
# Samuel Grant 2025 
# Source this script

# 1. Setup
export ENV_NAME=$CONDA_DEFAULT_ENV 
if [[ "$CONDA_DEFAULT_ENV" == "base" ]]; then
    echo "❌ Environment is 'base', please activate the environment that you would like to distribute" 
    return 1
else
    echo "✅ Environment is '${ENV_NAME}'" 
fi

export ENV_DIR="/exp/mu2e/data/users/sgrant/EAF/env"
export YAML_DIR="${ENV_DIR}/yml"

echo "👋 Distribute '${ENV_NAME}'? [Y/n]:"
read -r CONTINUE_STR
if [[ "$CONTINUE_STR" != "Y" ]]; then
    echo "❌ Exiting..."
    return 1
fi

# Activate
source ~/.bash_profile
mamba activate ${ENV_NAME}

# 2. Create YAML and timestamp
export THIS_YAML="${ENV_DIR}/yml/${ENV_NAME}.yml"
if [[ -f "${THIS_YAML}" ]]; then 
    echo "👋 ${THIS_YAML} already exists. Continue? [Y/n]:"
    read -r CONTINUE_STR
    if [[ "$CONTINUE_STR" != "Y" ]]; then
        echo "❌ Exiting..."
        return 1
    fi
fi

echo "✅ Exporting to YAML..."
mamba env export > ${THIS_YAML}

# Remove prefix 
sed '$d' "${THIS_YAML}" > "tmp"
# Replace library name line with the GitHub URL
# sed -i 's/- pyutils==\([0-9\.]*\)/- "git+https:\/\/github.com\/Mu2e\/pyutils.git@v\1"/' "tmp"
sed -i 's/- pyutils==\([0-9\.]*\)/- "git+https:\/\/github.com\/Mu2e\/pyutils.git"/' "tmp" # just main branch (no version)
# Overwrite
mv "tmp" "${THIS_YAML}"
echo "✅ Written '${THIS_YAML}'"

export TIMESTAMP="${ENV_DIR}/yml/${ENV_NAME}.datetime"
if [[ -f "${TIMESTAMP}" ]]; then 
    rm "${TIMESTAMP}" 
fi
date +"%Y-%m-%d_%H-%M-%S" > "${TIMESTAMP}"
echo "✅ Created timestamp '${TIMESTAMP}'"

# 3. Pack environment and copy it to /exp/data
echo "👋 Pack '${ENV_NAME}' into '${ENV_DIR}/${ENV_NAME}'? [Y/n]:"
read -r CONTINUE_STR
if [[ "$CONTINUE_STR" != "Y" ]]; then
    echo "❌ Exiting..."
    return 1
fi

if [[ -d ${ENV_DIR}/${ENV_NAME} ]]; then 
    echo "❌ Error: '${ENV_DIR}/${ENV_NAME}' already exists!"
    return 1
fi   

echo "✅ Packing '${ENV_NAME}' into '${ENV_DIR}/tar/${ENV_NAME}.tar.gz'..."
conda pack -o "${ENV_DIR}/tar/${ENV_NAME}.tar.gz"
chmod 777 "${ENV_DIR}/tar/${ENV_NAME}.tar.gz"

echo "✅ Extracting '${ENV_DIR}/tar/${ENV_NAME}.tar.gz' into '${ENV_DIR}/${ENV_NAME}'..."
mkdir ${ENV_DIR}/${ENV_NAME} 
tar -xzf "${ENV_DIR}/tar/${ENV_NAME}.tar.gz" -C "${ENV_DIR}/${ENV_NAME}"

echo "✅ Completed successfully!"
echo "✅ Environment is '${ENV_DIR}/${ENV_NAME}' with YAML file '${THIS_YAML}'"