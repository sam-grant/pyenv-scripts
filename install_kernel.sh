# #!/bin/bash
# python -m ipykernel install --name "$CONDA_DEFAULT_ENV" --prefix="$CONDA_PREFIX" --display-name "mu2e_env"

#!/bin/bash

# Remove any existing kernel first
jupyter kernelspec remove "$CONDA_DEFAULT_ENV" 2>/dev/null || true

# Install new kernel explicitly in the environment's jupyter directory
python -m ipykernel install \
    --name "$CONDA_DEFAULT_ENV" \
    --prefix="$CONDA_PREFIX" \
    --display-name "mu2e_env" \

# Replace the hardcoded interpreter with default (set in env_vars.sh) 
export MU2E_KERNEL="$CONDA_PREFIX/share/jupyter/kernels/$CONDA_DEFAULT_ENV/kernel.json"
sed -i "s|\"$CONDA_PREFIX/bin/python\"|\"python\"|" "$MU2E_KERNEL"
echo "✅ Mu2e kernel: ${MU2E_KERNEL}"
cat "$MU2E_KERNEL" 

# Remove the original python3 kernel.json if it exists
PYTHON3_KERNEL="$CONDA_PREFIX/share/jupyter/kernels/python3/kernel.json"
if [ -f "$PYTHON3_KERNEL" ]; then
    rm "$PYTHON3_KERNEL" 
fi

# Create symlink from python3 kernel.json to mu2e kernel.json
ln -s "$MU2E_KERNEL" "$PYTHON3_KERNEL"