#!/bin/bash
# Distribute current environment 
# Samuel Grant 2024 
# Source this script to pick up enviroment variables

# 1. Setup
export ENV_NAME=$CONDA_DEFAULT_ENV # "test_env.v1.0.1" # mu2e_env.v1.0.1" # 
export ENV_DIR="/exp/mu2e/data/users/sgrant/EAF/env"
export YMAL_DIR="${ENV_DIR}/yml"

echo "---> Distribute '${ENV_NAME}'? [y/n]"
read -r CONTINUE_STR
if [[ "$CONTINUE_STR" != "y" ]]; then
    echo "---> Exiting..."
    return 1
fi

# Activate
source ~/.bash_profile
mamba activate ${ENV_NAME}

# 2. Create YMAL and timestamp
export THIS_YMAL="${ENV_DIR}/yml/${ENV_NAME}.yml"

if [[ -f "${THIS_YMAL}" ]]; then 
    echo "${THIS_YMAL} already exists. Continue? [y/n]"
    read -r CONTINUE_STR
    if [[ "$CONTINUE_STR" != "y" ]]; then
        echo "---> Exiting..."
        return 1
    fi
fi

mamba env export > ${THIS_YMAL}

# Remove prefix 
sed '$d' "${THIS_YMAL}" > "tmp"

# Replace library name line with the GitHub URL
sed -i 's/- anapytools==\([0-9\.]*\)/- "git+https:\/\/github.com\/Mu2e\/anapytools.git@v\1"/' "tmp"

# Overwrite
mv "tmp" "${THIS_YMAL}"

echo "---> Written '${THIS_YMAL}'"

export TIMESTAMP="${ENV_DIR}/yml/${ENV_NAME}.datetime"
if [[ -f "${THIS_YMAL}" ]]; then 
    rm "${TIMESTAMP}" 
fi
date +"%Y-%m-%d_%H-%M-%S" > "${TIMESTAMP}"
echo "---> Created timestamp '${TIMESTAMP}'"

# 3. Pack environment and copy it to /exp/data

echo "---> Pack '${ENV_NAME}' into '${ENV_DIR}/${ENV_NAME}'..."
echo "Continue? [y/n]"

read -r CONTINUE_STR

if [[ "$CONTINUE_STR" == "y" ]]; then
    if [[ ! -d ${ENV_DIR}/${ENV_NAME} ]]; then 
        echo "---> Packing '${ENV_NAME}' into '${ENV_DIR}/tar/${ENV_NAME}.tar.gz'..."
        conda pack -o "${ENV_DIR}/tar/${ENV_NAME}.tar.gz"
        echo "Done."
        echo "---> Extracting '${ENV_DIR}/tar/${ENV_NAME}.tar.gz' into '${ENV_DIR}/${ENV_NAME}'..."
        mkdir ${ENV_DIR}/${ENV_NAME} 
        tar -xzf "${ENV_DIR}/tar/${ENV_NAME}.tar.gz" -C "${ENV_DIR}/${ENV_NAME}"
        echo "Done."
    else
        echo "Error: '${ENV_DIR}/${ENV_NAME}' already exists!"
        echo "---> Exiting..."
        return 1
    fi   
else
    echo "---> Exiting..."
    return 1
fi

echo "---> Completed successfully..."
echo "Environment is '${ENV_DIR}/${ENV_NAME}' with YMAL file '${THIS_YMAL}'..."