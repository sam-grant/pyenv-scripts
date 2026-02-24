# Changelog

All notable changes to the Mu2e Python environments will be documented in this file.

## ana

### 2.6.0 (current)

Changes from `2.5.0`:

* CUDA (GPU) support for ML libraries
* `pyutils-1.8.0`
* `dask`
* Switched to `pip install` for HEP-specific libraries
* Updates to `setup-mu2e-env.sh` for CUDA:

```
export TF_CPP_MIN_LOG_LEVEL=3
LD_LIBRARY_PATH=$(echo "$LD_LIBRARY_PATH" | tr ':' '\n' | grep -v "$CONDA_PREFIX" | tr '\n' ':' | sed 's/:$//')
export LD_LIBRARY_PATH="$CONDA_PREFIX/lib:$LD_LIBRARY_PATH"  
```

Also included test script for CUDA compatibility: 

```
(rootana_v2.5.0) [sgrant@jupyter-sgrant test-scripts]$ python test_cuda.py 
🐍 Python: 3.12.12 | packaged by conda-forge | (main, Jan 26 2026, 23:51:32) [GCC 14.3.0]

🔥 PyTorch: 2.5.1
  ✅ CUDA: working (v12.4, NVIDIA A100 80GB PCIe MIG 1g.10gb, 1 device(s))

🧠 TensorFlow: 2.20.0
  ✅ CUDA: working (1 GPU(s))

🚀 XGBoost: 2.1.4
  ✅ CUDA: working
```

**Packages (YAML)**

```
name: ana_v2.6.0
channels:
  - pytorch
  - nvidia
  - conda-forge
dependencies:
  - pip
  - matplotlib
  - pandas
  - scipy
  - scikit-learn
  - pytorch::pytorch
  - pytorch::torchvision
  - pytorch::torchaudio
  - pytorch::pytorch-cuda=12.4
  - tensorflow-gpu
  - py-xgboost-gpu
  - cuda-compat
  - dask
  - jupyterlab
  - notebook
  - statsmodels
  - urllib3=1.26.16
  - ipykernel
  - conda-pack
  - htop
  - tmux
  - plotly
  - tqdm
  - pyarrow
  - pip:
    - uproot
    - awkward
    - vector
    - hist
    - zfit
    - hepstats
    - fsspec-xrootd
    - dash
    - "git+https://github.com/Mu2e/pyutils.git"
```

### 2.5.0 

Added `pyutils-1.7.0`.

**Packages YAML:**

```
name: ana_v2.4.0
channels:
  - conda-forge
dependencies:
  - pip
  - matplotlib
  - pandas
  - uproot
  - scipy
  - scikit-learn
  - pytorch
  - tensorflow
  - jupyterlab
  - notebook
  - statsmodels
  - awkward
  - urllib3=1.26.16
  - ipykernel
  - conda-pack
  - fsspec-xrootd
  - htop
  - vector
  - plotly
  - dash
  - tqdm
  - hist
  - tmux
  - pyarrow
  - zfit
  - hepstats
  - xgboost
  - pip:
    - "git+https://github.com/Mu2e/pyutils.git"
```


### 2.4.0 

* Installed XGBoost (gradient boosted decision tree library)

**Packages YAML:**
```
# Contains environment variable script etc/conda/activate.d/setup_mu2e_python_env.sh, and
# interactive kernel (with internal symlinks) share/jupyter/kernels
name: ana_v2.4.0
channels:
  - conda-forge
dependencies:
  - pip
  - matplotlib
  - pandas
  - uproot
  - scipy
  - scikit-learn
  - pytorch
  - tensorflow
  - jupyterlab
  - notebook
  - statsmodels
  - awkward
  - urllib3=1.26.16
  - ipykernel
  - conda-pack
  - fsspec-xrootd
  - htop
  - vector
  - plotly
  - dash
  - tqdm
  - hist
  - tmux
  - pyarrow
  - zfit
  - hepstats
  - xgboost
  - pip:
    - "git+https://github.com/Mu2e/pyutils.git"
```

### 2.3.0
* Installed zfit
* Installed hepstats

### 2.2.0
* Installed pyutils v1.4.0
* Installed pyarrow for nested array persistence (parquet files)

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

### 2.5.0 (current)

Additions from `2.4.0`:

* CUDA (GPU) support for ML libraries
* `pyutils-1.8.0`
* `dask`
* Switched to `pip install` for HEP-specific libraries
* Updates to `setup-mu2e-env.sh` for CUDA


**Packages (YAML)**

```
name: rootana_v2.5.0
channels:
  - pytorch
  - nvidia
  - conda-forge
dependencies:
  - pip
  - root
  - matplotlib
  - pandas
  - scipy
  - scikit-learn
  - pytorch::pytorch
  - pytorch::torchvision
  - pytorch::torchaudio
  - pytorch::pytorch-cuda=12.4
  - tensorflow-gpu
  - py-xgboost-gpu
  - cuda-compat
  - dask
  - jupyterlab
  - notebook
  - statsmodels
  - urllib3=1.26.16
  - ipykernel
  - conda-pack
  - htop
  - tmux
  - plotly
  - tqdm
  - pyarrow
  - pip:
    - uproot
    - awkward
    - vector
    - hist
    - zfit
    - hepstats
    - fsspec-xrootd
    - dash
    - "git+https://github.com/Mu2e/pyutils.git"
```

### 2.4.0 

Identical to `2.3.0`, but with `pyutils-1.6.0`.

**Packages (YAML)**

```
name: rootana_v2.4.0
channels:
  - conda-forge
dependencies:
  - pip
  - matplotlib
  - pandas
  - uproot
  - scipy
  - scikit-learn
  - pytorch
  - tensorflow
  - jupyterlab
  - notebook
  - statsmodels
  - awkward
  - urllib3=1.26.16
  - ipykernel
  - conda-pack
  - fsspec-xrootd
  - htop
  - vector
  - plotly
  - dash
  - tqdm
  - hist
  - tmux
  - pyarrow
  - root
  - zfit
  - hepstats
  - xgboost
  - pip:
    - "git+https://github.com/Mu2e/pyutils.git"
```

### 2.3.0 

* `pyutils_v1.5.0`
* `zfit` and `hepstats`

**Packages (YAML)**

```
# Contains nvironment variable script etc/conda/activate.d/setup_mu2e_python_env.sh, and
# interactive kernel (with internal symlinks) share/jupyter/kernels
name: rootana_v2.3.0
channels:
  - conda-forge
dependencies:
  - pip
  - matplotlib
  - pandas
  - uproot
  - scipy
  - scikit-learn
  - pytorch
  - tensorflow
  - jupyterlab
  - notebook
  - statsmodels
  - awkward
  - urllib3=1.26.16
  - ipykernel
  - conda-pack
  - fsspec-xrootd
  - htop
  - vector
  - plotly
  - dash
  - tqdm
  - hist
  - tmux
  - pyarrow
  - root=6.34.1
  - zfit
  - hepstats
  - pip:
    - "git+https://github.com/Mu2e/pyutils.git"
```

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

## trkqual

Specialised environment for `trkqual` development. Uses TensorFlow 2.15 + Python 3.11 + ROOT 6.32: a known working combo for thge existing trkqual workflow. ROOT's TMVA `PyKeras` method uses `import tensorflow.keras as keras`, which broke in TF ≥ 2.16 when Keras was split into a standalone package. There is a ROOT PR (#15790) that adds Keras 3 support -- it was merged into ROOT master on Jan 14, 2026, but hasn't shipped in a release yet (ROOT 6.32 doesn't have it).

### 1.2.0

* CUDA (GPU) support for ML libraries
* `pyutils-1.8.0`
* Switched to `pip install` for HEP-specific libraries
* `dask`
* Updates to `setup-mu2e-env.sh` for CUDA

**>Note:** Need to pin TF-2.15 in the `pip` section as well, otherwise it gets bumped. 

**Packages (YAML)**

```
name: trkqual_v1.2.0
channels:
  - pytorch
  - nvidia
  - conda-forge
dependencies:
  - python=3.11
  - root=6.32.0
  - pip
  - matplotlib
  - pandas
  - scipy
  - scikit-learn
  - pytorch::pytorch
  - pytorch::torchvision
  - pytorch::torchaudio
  - pytorch::pytorch-cuda=12.4
  - tensorflow-gpu=2.15
  - py-xgboost-gpu
  - cuda-compat
  - dask
  - onnx
  - tf2onnx
  - jupyterlab
  - notebook
  - statsmodels
  - urllib3=1.26.16
  - ipykernel
  - conda-pack
  - htop
  - tmux
  - plotly
  - tqdm
  - pyarrow
  - pip:
    - tensorflow==2.15.*
    - uproot
    - awkward
    - vector
    - hist
    - zfit
    - hepstats
    - fsspec-xrootd
    - dash
    - "git+https://github.com/Mu2e/pyutils.git"

```

### 1.1.0

Update to `pyutils-1.6.0` and addition of `XGBoost`. 

**Packages (YAML)**

```
name: trkqual_v1.1.0
channels:
  - conda-forge
dependencies:
  - python=3.11
  - root=6.32.0
  - tensorflow=2.15
  - onnx
  - tf2onnx
  - pip
  - matplotlib
  - pandas
  - uproot
  - scipy
  - scikit-learn
  - pytorch
  - tensorflow
  - jupyterlab
  - notebook
  - statsmodels
  - awkward
  - urllib3=1.26.16
  - ipykernel
  - conda-pack
  - htop
  - vector
  - plotly
  - dash
  - tqdm
  - pyarrow
  - zfit
  - hepstats
  - xgboost
  - pip:
    - "git+https://github.com/Mu2e/pyutils.git"
```

### 1.0.0 

**Packages (YAML)**

```
# Contains environment variable script etc/conda/activate.d/env_vars.sh, and
# interactive kernel (with internal symlinks) share/jupyter/kernels
# Specialised environment for trkqual dev
name: trkqual_v1.0.0
channels:
  - conda-forge
dependencies:
  - python=3.11
  - root=6.32.0
  - tensorflow=2.15
  - onnx
  - tf2onnx
  - pip
  - matplotlib
  - pandas
  - uproot
  - scipy
  - scikit-learn
  - pytorch
  - tensorflow
  - jupyterlab
  - notebook
  - statsmodels
  - awkward
  - urllib3=1.26.16
  - ipykernel
  - conda-pack
  - htop
  - vector
  - plotly
  - dash
  - tqdm
  - pyarrow
  - zfit
  - hepstats
  - pip:
    - "git+https://github.com/Mu2e/pyutils.git"
```

