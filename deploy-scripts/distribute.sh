#!/bin/bash

#
# Distribute a Python environment 
# Samuel Grant 2025
#
# Apologies for the emojis...
#
# USAGE: 
# . distribute.sh -e myenv
# or 
# . distribute.sh -e myenv -y # (auto yes)
# or
# . distribute.sh # if the current active environment is the one to distribute


# Parse command line arguments
AUTO_YES=false
PROVIDED_ENV_NAME=""

show_help() {
    cat << EOF
Usage: source $0 [-y|--yes] [-e|--env ENV_NAME] [-h|--help]
       . $0 [-y|--yes] [-e|--env ENV_NAME] [-h|--help]

  -y, --yes        Automatically answer 'Y' to all prompts
  -e, --env        Specify environment name to distribute
  -h, --help       Show this help message

This script will:
1. Export the specified conda environment to YAML
2. Pack the environment using conda-pack
3. Extract it to a shared directory

Examples:
  source $0 -e myenv       # Distribute 'myenv' environment
  . $0 -y -e myenv         # Auto-yes mode
  source $0                # Interactive mode (will prompt for env)

Note: This script must be sourced, not executed directly.
EOF
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
        -e|--env)
            if [[ -z "${2:-}" ]]; then
                echo "❌ Error: --env requires a value" >&2
                return 1
            fi
            PROVIDED_ENV_NAME="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            return 0
            ;;
        *)
            echo "❌ Unknown option: $1" >&2
            echo "Use -h or --help for usage information" >&2
            return 1
            ;;
    esac
done

# Function to prompt user or auto-continue
prompt_continue() {
    local message="$1"
    local response
    
    if [[ "$AUTO_YES" == true ]]; then
        echo "$message [Y/n]: Y (auto)"
        return 0
    fi
    
    while true; do
        read -r -p "$message [Y/n]: " response
        case "$response" in
            [Yy]|[Yy][Ee][Ss]|"")  # Accept Y, y, yes, Yes, or empty (default to yes)
                return 0
                ;;
            [Nn]|[Nn][Oo])
                echo "❌ Exiting..."
                return 1
                ;;
            *)
                echo "Please answer Y or n"
                ;;
        esac
    done
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if mamba/conda is available
if ! command_exists mamba && ! command_exists conda; then
    echo "❌ Error: Neither mamba nor conda is installed or not in PATH" >&2
    return 1
fi

# 1. Setup and validation
echo "⭐️ Environment distribution setup"

# Use provided environment name or detect current one
if [[ -n "$PROVIDED_ENV_NAME" ]]; then
    ENV_NAME="$PROVIDED_ENV_NAME"
    echo "✅ Using specified environment: ${ENV_NAME}"
    
    # Check if environment exists
    if ! conda env list | grep -q "^${ENV_NAME} "; then
        echo "❌ Environment '${ENV_NAME}' doesn't exist" >&2
        echo "Available environments:" >&2
        conda env list | grep -v "^#" | grep -v "^$" >&2
        return 1
    fi
else
    # No environment specified via command line, check current environment
    ENV_NAME=${CONDA_DEFAULT_ENV:-}
    if [[ -z "$ENV_NAME" ]]; then
        echo "⚠️  No conda environment is currently active and none specified"
        
        # Show available environments
        echo "Available environments:"
        conda env list | grep -v "^#" | grep -v "^$" | while read -r line; do
            env_name=$(echo "$line" | awk '{print $1}')
            if [[ "$env_name" != "base" ]]; then
                echo "  - $env_name"
            fi
        done
        
        # Prompt for environment name
        while true; do
            read -r -p "👋 Enter environment name to distribute: " ENV_NAME
            if [[ -n "$ENV_NAME" && "$ENV_NAME" != "base" ]]; then
                # Check if environment exists
                if conda env list | grep -q "^${ENV_NAME} "; then
                    echo "✅ Will distribute environment: ${ENV_NAME}"
                    break
                else
                    echo "❌ Environment '${ENV_NAME}' doesn't exist"
                fi
            else
                echo "❌ Please enter a valid environment name (not 'base')"
            fi
        done
    elif [[ "$ENV_NAME" == "base" ]]; then
        echo "❌ Currently in 'base' environment. Please specify an environment with -e/--env or activate a different environment first" >&2
        echo "Available environments:" >&2
        conda env list | grep -v "^#" | grep -v "^$" | grep -v "^base " >&2
        return 1
    else
        echo "✅ Using currently active environment: ${ENV_NAME}" 
    fi
fi

# Final validation
if [[ "$ENV_NAME" == "base" ]]; then
    echo "❌ Cannot distribute 'base' environment" >&2
    return 1
fi

PYENV_DIR="/exp/mu2e/data/users/sgrant/pyenv"
ENV_DIR="${PYENV_DIR}/env"
YAML_DIR="${PYENV_DIR}/yml/full"
# YAML_ALT_DIR="../yml/full"
TAR_DIR="${PYENV_DIR}/tar"

# Create directories if they don't exist
for dir in "$ENV_DIR" "$YAML_DIR" "$TAR_DIR"; do
    if [[ ! -d "$dir" ]]; then
        echo "📁 Creating directory: $dir"
        mkdir -p "$dir"
    fi
done

if ! prompt_continue "👋 Distribute '${ENV_NAME}'?"; then
    return 1
fi

# Initialize conda/mamba for this shell session
echo "🔧 Initialising conda..."
eval "$(conda shell.bash hook)" 2>/dev/null || eval "$(mamba shell.bash hook)" 2>/dev/null || {
    echo "❌ Failed to initialize conda/mamba" >&2
    return 1
}

# Activate the environment (this persists in the current shell since we're sourced)
echo "🔧 Activating environment: ${ENV_NAME}"
if ! conda activate "${ENV_NAME}"; then
    echo "❌ Failed to activate environment: ${ENV_NAME}" >&2
    return 1
fi

# Check if conda-pack is available in the activated environment
if ! command_exists conda-pack; then
    echo "❌ Error: conda-pack isn't installed in environment '${ENV_NAME}'" >&2
    echo "Please install it first with: conda install conda-pack" >&2
    return 1
fi
echo "✅ conda-pack is available"

# 2. Create YAML and timestamp
echo "⭐️ Exporting environment"
THIS_YAML="${YAML_DIR}/${ENV_NAME}.yml"
# THIS_ALT_YAML="${YAML_ALT_DIR}/${ENV_NAME}.yml"

if [[ -f "${THIS_YAML}" ]]; then 
    if ! prompt_continue "👋 ${THIS_YAML} already exists. Overwrite?"; then
        return 1
    fi
    echo "🗑️  Removing existing ${THIS_YAML}..."
    rm -f "${THIS_YAML}"
fi

# if [[ -f "${THIS_ALT_YAML}" ]]; then 
#     if ! prompt_continue "👋 Alternative ${THIS_ALT_YAML} already exists. Overwrite?"; then
#         return 1
#     fi
#     echo "🗑️  Removing existing ${THIS_ALT_YAML}..."
#     rm -f "${THIS_ALT_YAML}"
# fi

echo "📄 Exporting to YAML: ${THIS_YAML}" #  and ${THIS_ALT_YAML}"
if ! mamba env export > "${THIS_YAML}"; then
    echo "❌ Failed to export environment to YAML" >&2
    return 1
fi

# Remove prefix line (last line)
if ! sed '$d' "${THIS_YAML}" > "${THIS_YAML}.tmp"; then
    echo "❌ Failed to process YAML file" >&2
    return 1
fi

# Replace pyutils library line with GitHub URL
sed -i 's/- pyutils==\([0-9\.]*\)/- "git+https:\/\/github.com\/Mu2e\/pyutils.git"/' "${THIS_YAML}.tmp"

# Overwrite original file
if ! mv "${THIS_YAML}.tmp" "${THIS_YAML}"; then
    echo "❌ Failed to update YAML file" >&2
    return 1
fi

# Copy to alternative
# cp ${THIS_YAML} ${THIS_ALT_YAML}

echo "✅ Written YAML:"
echo "${THIS_YAML}"
# echo "${THIS_ALT_YAML}"

# 3. Pack environment
echo "⭐️ Packing environment"
if ! prompt_continue "👋 Pack '${ENV_NAME}' into '${ENV_DIR}/${ENV_NAME}'?"; then
    return 1
fi

# Remove existing packed directory
PACKED_DIR="${ENV_DIR}/${ENV_NAME}"
if [[ -d "$PACKED_DIR" ]]; then 
    if ! prompt_continue "👋 ${PACKED_DIR} already exists. Remove and recreate?"; then
        return 1
    fi
    echo "🗑️  Removing existing ${PACKED_DIR}..."
    rm -rf "${PACKED_DIR}"
fi

# Remove existing tar file
TAR_FILE="${TAR_DIR}/${ENV_NAME}.tar.gz"
if [[ -f "${TAR_FILE}" ]]; then 
    if ! prompt_continue "👋 ${TAR_FILE} already exists. Overwrite?"; then
        return 1
    fi
    echo "🗑️  Removing existing tar file ${TAR_FILE}..."
    rm -f "${TAR_FILE}"
fi

echo "📦 Packing '${ENV_NAME}' into '${TAR_FILE}'..."
if ! conda pack -o "${TAR_FILE}"; then
    echo "❌ Failed to pack environment" >&2
    return 1
fi

# Set permissions
chmod 644 "${TAR_FILE}"
echo "✅ Created tar file: ${TAR_FILE}"

echo "📂 Extracting '${TAR_FILE}' into '${PACKED_DIR}'..."
if ! mkdir -p "${PACKED_DIR}"; then
    echo "❌ Failed to create directory: ${PACKED_DIR}" >&2
    return 1
fi

if ! tar -xzf "${TAR_FILE}" -C "${PACKED_DIR}"; then
    echo "❌ Failed to extract environment" >&2
    return 1
fi

echo ""
echo "✅ Completed successfully!"
echo "📁 Environment directory: ${PACKED_DIR}"
echo "📄 YAML file: ${THIS_YAML}"
echo "📦 Tar file: ${TAR_FILE}"
# echo "🕐 Timestamp: ${TIMESTAMP}"
echo ""
echo "To use this environment on another system:"
echo "  1. Copy the YAML file and run: mamba env create -f ${ENV_NAME}.yml"
echo "  2. Or extract the tar file and activate directly"
echo ""
echo "✅ Environment '${ENV_NAME}' remains active in this shell"