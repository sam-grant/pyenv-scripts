# Changelog

All notable changes to the Mu2e Python environments will be documented in this file.

## ana

### 2.2.0 (current)
* Installed pyutils v1.4.0
* Installed pyarrow for nested array persistence (parquet files)

**Packages:**
```
pip
matplotlib
pandas
uproot
scipy
scikit-learn
pytorch
tensorflow
jupyterlab
notebook
statsmodels
awkward
urllib3=1.26.16
ipykernel
conda-pack
fsspec-xrootd
htop
vector
plotly
dash
tqdm
hist
tmux
pyarrow
pyutils # v01_04_00
```

### 2.1.0
* Includes pyutils v1.2.0 with patches from PR-14, PR-15, and PR-18
* Added tmux as Jupyter-friendly alternative to screen
* Fixed environment variable contamination when using alongside standard Mu2e scripts - no longer matters when you run `pyenv ana` in relation to scripts like `muse setup`
* Renamed internal script from `env_vars.sh` to `setup_mu2e_python_env.sh`

### 2.0.0
Replaced `anapytools` with standalone `pyutils`. See https://github.com/Mu2e/pyutils for documentation.

### 1.3.0
* Added `tqdm` and `hist` packages (required by latest pyutils)

### 1.2.0
* Added `plotly` and `dash` packages (requested for DQM development)
* Included built-in `mu2e_env` kernel that becomes available automatically after environment activation
* Works on both EAF and VMs - users no longer need to install local kernels for interactive use
* Kernel installed at `1.2.0/share/jupyter/kernels/mu2e_env.v1.2.0` and described by `kernel.json`

When installing a kernel into a prefix without a default python kernel, `ipykernel` automatically creates one at `1.2.0/share/jupyter/kernels/python3`. This creates complications, but the default kernel is required by `conda-pack`. As a workaround, the auto-created kernel was replaced with a symlink: `python3/kernel.json` → `mu2e_env.v1.2.0/kernel.json`

Added environment variable to `env_vars.sh`:
```bash
export JUPYTER_PATH="$CONDA_PREFIX/share/jupyter/kernels:$JUPYTER_PATH" # Path to kernel
```

### 1.1.1
Patched conflict with default Python interpreter when using environment alongside `muse`. 

The patch explicitly points to the environment's Python in `PATH` and packages in `PYTHONPATH`. These variables were added to `env_vars.sh`:
```bash
export PATH="$CONDA_PREFIX/bin:$PATH" # Interpreter
export PYTHONPATH="$CONDA_PREFIX/lib/python3.12/site-packages:$PYTHONPATH" # Packages
```

### 1.1.0
* Added `vector` package (needed by mu2epyutils)
* Fixed "Qt platform plugin" and "Fontconfig" errors when running matplotlib GUI

The patch introduced script `1.1.0/etc/conda/activate.d/env_vars.sh` which sets environment variables upon activation:
```bash
export QT_QPA_PLATFORM_PLUGIN_PATH="$CONDA_PREFIX/lib/qt6/plugins/platforms" # Matplotlib GUI plugin
export FONTCONFIG_FILE="$CONDA_PREFIX/etc/fonts/fonts.conf" # Matplotlib fonts
```

### 1.0.0
First official version containing packages that mirror predecessor pyana, plus `anapytools`.

## rootana

### 2.2.0
Identical to ana 2.2.0, but contains ROOT version 6.34.10.

### 2.1.0
Identical to ana 2.1.0, but contains ROOT version 6.34.04.

### 2.0.0
Special version diverging from standard ana environment, requested for trkqual training.

Built on ana 2.0.0 with these changes:
* Python: 3.12 → 3.11
* ROOT: 6.32.02 → 6.32.00
* tensorflow: 2.16 → 2.15
* Added `onnx` and `tf2onnx`

Some packages were downgraded for Python 3.11 compatibility. These downgrades were needed because ROOT is incompatible with TensorFlow 2.16 due to a known issue.

### 1.2.0
Identical to ana 1.2.0, but contains ROOT version 6.32.02.