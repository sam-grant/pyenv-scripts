#!/bin/bash
# Build environment from YAML
# Samuel Grant 2025 
# source this script

# Parse command line arguments
AUTO_YES=false
ENV_NAME=""
YAML_ENV_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
        -n|--name)
            ENV_NAME="$2"
            shift 2
            ;;
        -f|--from)
            YAML_ENV_NAME="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [-y|--yes] [-n|--name ENV_NAME] [-f|--from YAML_ENV_NAME] [-h|--help]"
            echo "  -y, --yes        Automatically answer 'Y' to all prompts"
            echo "  -n, --name       Specify new environment name"
            echo "  -f, --from       Specify source YAML environment name"
            echo "  -h, --help       Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 -y -n myenv -f template_env"
            echo "  $0 -n myenv -f template_env"
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

# Function to get input or use provided value
get_input() {
    local prompt="$1"
    local current_value="$2"
    local var_name="$3"
    
    if [[ -n "$current_value" ]]; then
        echo "✅ Using $var_name: $current_value"
        echo "$current_value"
    else
        echo "$prompt"
        read -r input_value
        echo "$input_value"
    fi
}

# Get environment name
ENV_NAME=$(get_input "👋 Enter new environment name:" "$ENV_NAME" "environment name")
if [[ -z "$ENV_NAME" ]]; then 
    echo "❌ Please enter new environment name" 
    return 1
else 
    echo "✅ New environment name is ${ENV_NAME}"
fi

# Get YAML environment name
YAML_ENV_NAME=$(get_input "👋 Enter starting environment name (to build from YAML):" "$YAML_ENV_NAME" "YAML environment name")
YAML_FILE="/exp/mu2e/data/users/sgrant/EAF/env/yml/${YAML_ENV_NAME}.yml"
echo "$YAML_FILE"

if [[ -z "$YAML_ENV_NAME" ]]; then 
    echo "❌ Please enter a starting environment name" 
    return 1
else 
    echo "✅ YAML is ${YAML_FILE}"
fi

if [[ ! -f "$YAML_FILE" ]]; then 
    echo "❌ YAML file does not exist" 
    return 1
else 
    echo "✅ YAML file exists" 
fi

# Execute mamba command
COMMAND="mamba env create -n ${ENV_NAME} -f ${YAML_FILE}" 
echo "👋 Executing command: ${COMMAND}"

if ! prompt_continue "OK?"; then
    return 1
else 
    echo "✅ Building" 
    $COMMAND
    echo "✅ Activating"
    mamba activate ${ENV_NAME}
fi

# Copy setup script
if ! prompt_continue "👋 Copy setup script?"; then
    return 1
else 
    . ./add_setup_script.sh 
fi

# Install kernel
if ! prompt_continue "👋 Install kernel?"; then
    return 1
else 
    . ./install_kernel.sh
    echo "✅ Installed kernel" 
fi

echo "✅ Done"