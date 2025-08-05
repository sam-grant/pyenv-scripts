#!/bin/bash
# Distribute current environment 
# Samuel Grant 2025 
# Source this script

# Parse command line arguments
AUTO_YES=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [-y|--yes] [-h|--help]"
            echo "  -y, --yes    Automatically answer 'Y' to all prompts"
            echo "  -h, --help   Show this help message"
            return 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            return 1
            ;;
    esac
done

# Function to prompt user or auto-continue
prompt_continue() {
    local message="$1"
    if [[ "$AUTO_YES" == true ]]; then
        echo "$message [Y/n]: Y (auto)"
        return 0
    else
        echo "$message [Y/n]:"
        read -r CONTINUE_STR
        if [[ "$CONTINUE_STR" != "Y" ]]; then
            echo "❌ Exiting..."
            return 1
        fi
        return 0
    fi
}

# 1. Setup
ENV_NAME=$CONDA_DEFAULT_ENV 
if [[ "$CONDA_DEFAULT_ENV" == "base" ]]; then
    echo "❌ Environment is 'base', please activate the environment that you would like to distribute" 
    return 1
else
    echo "✅ Environment is '${ENV_NAME}'" 
fi

ENV_DIR="/exp/mu2e/data/users/sgrant/EAF/env"
YAML_DIR="${ENV_DIR}/yml"

if ! prompt_continue "👋 Distribute '${ENV_NAME}'?"; then
    return 1
fi

# Activate
source ~/.bash_profile
mamba activate ${ENV_NAME}

# 2. Create YAML and timestamp
THIS_YAML="${ENV_DIR}/yml/${ENV_NAME}.yml"
if [[ -f "${THIS_YAML}" ]]; then 
    if ! prompt_continue "👋 ${THIS_YAML} already exists. Continue?"; then
        return 1
    else
        echo "✅ Removing ${THIS_YAML}..."
        rm ${THIS_YAML}
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

TIMESTAMP="${ENV_DIR}/yml/${ENV_NAME}.datetime"
if [[ -f "${TIMESTAMP}" ]]; then 
    if ! prompt_continue "👋 ${TIMESTAMP} already exists. Continue?"; then
        return 1
    else
        echo "✅ Removing ${TIMESTAMP}..."
        rm "${TIMESTAMP}" 
    fi
fi

date +"%Y-%m-%d_%H-%M-%S" > "${TIMESTAMP}"
echo "✅ Created timestamp '${TIMESTAMP}'"

# 3. Pack environment and copy it to /exp/data
if ! prompt_continue "👋 Pack '${ENV_NAME}' into '${ENV_DIR}/${ENV_NAME}'?"; then
    return 1
fi

if [[ -d ${ENV_DIR}/${ENV_NAME} ]]; then 
    if ! prompt_continue "👋 ${ENV_DIR}/${ENV_NAME} already exists. Continue?"; then
        return 1
    else
        echo "✅ Removing ${ENV_DIR}/${ENV_NAME}..."
        rm -rf "${ENV_DIR}/${ENV_NAME}"
    fi
fi

# Check if tar file already exists and remove it
TAR_FILE="${ENV_DIR}/tar/${ENV_NAME}.tar.gz"
if [[ -f "${TAR_FILE}" ]]; then 
    if ! prompt_continue "👋 ${TAR_FILE} already exists. Continue?"; then
        return 1
    else
        echo "✅ Removing old tar file ${TAR_FILE}..."
        rm "${TAR_FILE}"
    fi
fi

echo "✅ Packing '${ENV_NAME}' into '${ENV_DIR}/tar/${ENV_NAME}.tar.gz'..."
conda pack -o "${ENV_DIR}/tar/${ENV_NAME}.tar.gz"
chmod 777 "${ENV_DIR}/tar/${ENV_NAME}.tar.gz"

echo "✅ Extracting '${ENV_DIR}/tar/${ENV_NAME}.tar.gz' into '${ENV_DIR}/${ENV_NAME}'..."
mkdir ${ENV_DIR}/${ENV_NAME} 
tar -xzf "${ENV_DIR}/tar/${ENV_NAME}.tar.gz" -C "${ENV_DIR}/${ENV_NAME}"

echo "✅ Completed successfully!"
echo "✅ Environment is '${ENV_DIR}/${ENV_NAME}' with YAML file '${THIS_YAML}'"