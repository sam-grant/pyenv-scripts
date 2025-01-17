#!/bin/bash
# Build mu2e_env 
# Samuel Grant 2024 

#############################################################
# 1. Setup variables 

ENV_NAME="" 
ENV_DIR="" 

# Challenge 1
echo "Is this a test run? [y/n]"
read -r TEST_STR

if [[ "${TEST_STR}" != "y" ]]; then
    # Challenge 2
    echo "Please type 'mu2e_env' to confirm."
    read -r CHALLENGE_STR
    if [[ "${CHALLENGE_STR}" != "mu2e_env" ]]; then
        echo "---> You entered '${CHALLENGE_STR}'. Exiting..." 
        exit 1
    else 
        ENV_NAME="mu2e_env"
        ENV_DIR="/exp/mu2e/data/users/sgrant/EAF/env"
    fi
elif [[ "${TEST_STR}" != "n" ]]; then
    echo "---> Running in test mode" 
    ENV_NAME="test_env"
    ENV_DIR="/exp/mu2e/data/users/sgrant/EAF/env/teststand"
else
    echo "---> Invalid input '${TEST_STR}'. Exiting..."
    exit 1
fi

#############################################################
# 2. Versioning

# Get most recent version
LAST_VER=$(ls ${ENV_DIR}/${ENV_NAME}.v* 2>/dev/null | sort -V | tail -n 1)

# Read last version
if [[ -z "$LAST_VER" ]]; then
    VER_STR="1.0.0"
    THIS_VER="${ENV_NAME}.v${VER_STR}"
    echo "---> No latest version found for ${ENV_NAME}..."
else
    # Extract the version number 
    LAST_VER=$(echo "$LAST_VER" | sed -E 's/.*\.v([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
    echo "---> Latest verion is '${ENV_NAME}.v${LAST_VER}'"
    IFS='.' read -r MAJOR MINOR PATCH <<< "$LAST_VER"
    
    echo "What type of update is this? [major/minor/patch]: "
    read -r UPDATE_TYPE
    echo "---> Versioning as '${UPDATE_TYPE}' update"
    
    # Increment the version based on user input
    case "$UPDATE_TYPE" in
        major)
            MAJOR=$((MAJOR + 1))
            MINOR=0
            patch=0
            ;;
        minor)
            MINOR=$((MINOR + 1))
            PATCH=0
            ;;
        patch)
            PATCH=$((PATCH + 1))
            ;;
        *)
            echo "---> Invalid update type! Exiting."
            exit 1
            ;;
    esac
    
    VER_STR="${MAJOR}.${MINOR}.${PATCH}"
    THIS_VER="${ENV_NAME}.v${VER_STR}"
    
fi

echo "---> New build will be '${THIS_VER}'." 

#############################################################
# 3. Build it
source ~/.bash_profile

REQ_FILE="${ENV_DIR}/req/${THIS_VER}.txt"

if [[ ! -f "${REQ_FILE}" ]]; then
    echo "'${REQ_FILE}' not found, exiting..."
    exit 1
fi

# Create environment
echo "---> Creating '${THIS_VER}' from '${REQ_FILE}'."
mamba create -q -y -n ${THIS_VER} --file "${REQ_FILE}"
# Activate 
echo "---> Activating '${THIS_VER}'."
mamba activate ${THIS_VER}
# Install tools
echo "---> Installing https://github.com/sam-grant/anapytools.git"
pip install -I git+https://github.com/sam-grant/anapytools.git
echo "Done."
