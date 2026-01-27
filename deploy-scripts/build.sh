#!/bin/bash
# Set umask to allow group and world read
umask 022

#
# Build environment from base YAML
# Samuel Grant 2025
# USAGE: . build.sh -f template_env -n myenv # -y (auto yes)
#

# Parse command line arguments
AUTO_YES=false
ENV_NAME=""
YAML_ENV_NAME=""

show_help() {
    cat << EOF
Usage: . $0 [-y|--yes] [-n|--name ENV_NAME] [-f|--from YAML_ENV_NAME] [-h|--help]

  -y, --yes        Automatically answer 'Y' to all prompts
  -n, --name       Specify new environment name
  -f, --from       Specify source YAML environment name
  -h, --help       Show this help message

Examples:
  . $0 -n myenv -f template_env

Note: This script must be sourced, not executed directly.
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
        -n|--name)
            if [[ -z "${2:-}" ]]; then
                echo "❌ Error: --name requires a value" >&2
                return 1
            fi
            ENV_NAME="$2"
            shift 2
            ;;
        -f|--from)
            if [[ -z "${2:-}" ]]; then
                echo "❌ Error: --from requires a value" >&2
                return 1
            fi
            YAML_ENV_NAME="$2"
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

# Function to get input or use provided value
get_input() {
    local prompt="$1"
    local current_value="$2"
    local var_name="$3"
    local input_value
    
    if [[ -n "$current_value" ]]; then
        echo "✅ Using $var_name: $current_value" >&2  # Send to stderr so it doesn't interfere with return value
        echo "$current_value"  # This is the actual return value
        return 0
    fi
    
    while true; do
        read -r -p "$prompt " input_value
        if [[ -n "$input_value" ]]; then
            echo "$input_value"  # This is the actual return value
            return 0
        else
            echo "❌ Please enter a value" >&2  # Send to stderr
        fi
    done
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if mamba is available
if ! command_exists mamba; then
    echo "❌ Error: mamba isn't installed or not in PATH" >&2
    echo "Please install mamba/conda first" >&2
    return 1
fi

# Get environment name
echo "⭐️ Environment setup"
ENV_NAME=$(get_input "👋 Enter new environment name:" "$ENV_NAME" "environment name")
if [[ -z "$ENV_NAME" ]]; then 
    echo "❌ Please enter new environment name" >&2
    return 1
fi
echo "✅ New environment name: ${ENV_NAME}"

# Get YAML environment name  
YAML_ENV_NAME=$(get_input "👋 Enter starting environment name (to build from YAML):" "$YAML_ENV_NAME" "YAML environment name")
if [[ -z "$YAML_ENV_NAME" ]]; then 
    echo "❌ Please enter a starting environment name" >&2
    return 1
fi

YAML_FILE="../yml/minimal/${YAML_ENV_NAME}.yml"
echo "✅ YAML file path: ${YAML_FILE}"

# Check if YAML file exists
if [[ ! -f "$YAML_FILE" ]]; then 
    echo "❌ YAML file doesn't exist: $YAML_FILE" >&2
    echo "Available YAML files:" >&2
    ls -la "../yml/minimal/"*.yml 2>/dev/null || echo "No YAML files found in directory" >&2
    return 1
fi
echo "✅ YAML file exists"

# Check if environment already exists
if mamba env list | grep -q "^${ENV_NAME} "; then
    echo "⚠️  Environment '$ENV_NAME' already exists"
    if ! prompt_continue "Do you want to remove it and recreate?"; then
        return 1
    fi
    echo "🗑️  Removing existing environment..."
    mamba env remove -n "$ENV_NAME" -y
fi

# Execute mamba command
echo "⭐️ Building environment"
COMMAND="mamba env create -n ${ENV_NAME} -f ${YAML_FILE}"
echo "👋 Executing command: ${COMMAND}"

if ! prompt_continue "OK?"; then
    return 1
fi

echo "✅ Building environment (this may take a while)..."
if ! $COMMAND; then
    echo "❌ Failed to create environment" >&2
    return 1
fi
echo "✅ Environment created successfully"

# Set proper permissions for shared filesystem
echo "🔐 Setting read permissions for all users..."
chmod -R a+rX "${CONDA_PREFIX}"

# Activate the environment (this persists in the current shell since we're sourced)
echo "✅ Activating environment: ${ENV_NAME}"
if ! conda activate "${ENV_NAME}"; then
    echo "❌ Failed to activate environment" >&2
    return 1
fi

# Copy setup script
echo "⭐️ Additional setup"
if prompt_continue "👋 Copy setup script?"; then
    SCRIPT="../internal-scripts/setup-mu2e-python-env.sh"
    DESTINATION="${CONDA_PREFIX}/etc/conda/activate.d/"
    
    # Check if source script exists
    if [[ ! -f "$SCRIPT" ]]; then
        echo "❌ Setup script not found: $SCRIPT" >&2
        return 1
    fi
    
    # Check if destination directory exists, create if needed
    if [[ ! -d "$DESTINATION" ]]; then
        echo "📁 Creating destination directory: $DESTINATION"
        mkdir -p "$DESTINATION"
    fi
    
    # Copy the script
    if cp "$SCRIPT" "$DESTINATION"; then
        echo "✅ Copied setup script to conda activate.d"
        # Ensure the copied script is readable by all
        chmod a+r "${DESTINATION}/$(basename $SCRIPT)"
    else
        echo "❌ Failed to copy setup script" >&2
        return 1
    fi
fi

# Install kernel
if prompt_continue "👋 Install kernel?"; then
    echo "🔧 Installing kernel..."
    
    # Remove any existing kernel first
    jupyter kernelspec remove "$CONDA_DEFAULT_ENV" 2>/dev/null || true
    
    # Install new kernel
    if ! python -m ipykernel install --name "$CONDA_DEFAULT_ENV" --prefix="$CONDA_PREFIX" --display-name "mu2e_env"; then
        echo "❌ Kernel installation failed" >&2
        return 1
    fi
    
    # Configure kernel
    MU2E_KERNEL="$CONDA_PREFIX/share/jupyter/kernels/$CONDA_DEFAULT_ENV/kernel.json"
    PYTHON3_KERNEL="$CONDA_PREFIX/share/jupyter/kernels/python3/kernel.json"
    
    # Replace hardcoded interpreter path
    sed -i "s|\"$CONDA_PREFIX/bin/python\"|\"python\"|" "$MU2E_KERNEL"
    
    # Setup python3 symlink
    [[ -f "$PYTHON3_KERNEL" ]] && rm "$PYTHON3_KERNEL"
    ln -s "$MU2E_KERNEL" "$PYTHON3_KERNEL"
    
    echo "✅ Installed and configured kernel: $MU2E_KERNEL"
    cat "$MU2E_KERNEL"
fi

echo ""
echo "✅ Done! Environment '$ENV_NAME' is ready and active."
echo ""
echo "To activate this environment in future sessions, run:"
echo "  mamba activate $ENV_NAME"
echo ""
echo "To deactivate, run:"
echo "  mamba deactivate"
