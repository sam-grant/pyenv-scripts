import sys
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
os.environ['ZFIT_DISABLE_TF_WARNINGS'] = '1'

import argparse
parser = argparse.ArgumentParser()
parser.add_argument('--root', action='store_true', help='Include ROOT import checks')
args = parser.parse_args()

def test_import(package, subpackage=None):
    try:
        if subpackage:
            exec(f"from {package} import {subpackage}")
            print(f"  ✅ from {package} import {subpackage}")
        else:
            mod = __import__(package)
            version = getattr(mod, '__version__', '')
            version_str = f" ({version})" if version else ""
            print(f"  ✅ {package}{version_str}")
    except ImportError as e:
        print(f"  ❌ {package}{' -> ' + subpackage if subpackage else ''}: {e}")
        return False
    return True

def test_version(package, expected):
    try:
        mod = __import__(package)
        actual = mod.__version__
        if actual == expected:
            print(f"  ✅ {package} version {actual}")
        else:
            print(f"  ⚠️  {package} version {actual} (expected {expected})")
    except (ImportError, AttributeError) as e:
        print(f"  ❌ {package}: {e}")

print(f"🐍 Python: {sys.version}\n")

# --- Core packages ---
print("📦 Core packages")
packages = [
    "matplotlib", "pandas", "scipy", "sklearn", "statsmodels",
    "numpy", "plotly", "tqdm", "pyarrow", "dask",
]
failures = sum(not test_import(p) for p in packages)
print()

# --- HEP packages ---
print("⚛️  HEP packages")
hep_packages = ["uproot", "awkward", "vector", "hist", "zfit", "hepstats"]
if args.root:
    hep_packages.insert(0, "ROOT")
failures += sum(not test_import(p) for p in hep_packages)
print()

# --- ML/GPU packages ---
print("🧠 ML packages")
ml_packages = ["torch", "tensorflow", "xgboost"]
failures += sum(not test_import(p) for p in ml_packages)
print()

# --- Jupyter/tools ---
print("🔧 Tools")
tool_packages = [
    "jupyterlab", "ipykernel", "dash", "conda_pack",
]
failures += sum(not test_import(p) for p in tool_packages)
print()

# --- Mu2e pyutils ---
print("🔬 Mu2e pyutils")
pyutils_modules = [
    ("pyutils", None),
    ("pyutils.pyread", "Reader"),
    ("pyutils.pyimport", "Importer"),
    ("pyutils.pyprocess", "Processor"),
    ("pyutils.pyselect", "Select"),
    ("pyutils.pyvector", "Vector"),
    ("pyutils.pyprint", "Print"),
    ("pyutils.pyplot", "Plot"),
    ("pyutils.pydisplay", "Display"),
    ("pyutils.pycut", "CutManager"),
]
for package, subpackage in pyutils_modules:
    if not test_import(package, subpackage):
        failures += 1
print()

# --- Specific submodules ---
print("🔗 Submodules")
submodules = [
    ("tensorflow", "keras"),
]
for package, subpackage in submodules:
    if not test_import(package, subpackage):
        failures += 1
print()

# --- CUDA ---
import warnings
print("🖥️  CUDA")
try:
    import torch
    with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        cuda_available = torch.cuda.is_available()
    if cuda_available:
        print(f"  ✅ PyTorch CUDA (v{torch.version.cuda}, {torch.cuda.get_device_name(0)})")
    else:
        print("  ❌ PyTorch CUDA not available (no GPU on this machine?)")
except ImportError:
    pass

try:
    import tensorflow as tf
    gpus = tf.config.list_physical_devices('GPU')
    if gpus:
        print(f"  ✅ TensorFlow CUDA ({len(gpus)} GPU(s))")
    else:
        print("  ❌ TensorFlow CUDA not available (no GPU on this machine?)")
except ImportError:
    pass

if torch.cuda.is_available():
    print("  ✅ XGBoost CUDA (GPU available via PyTorch CUDA)")
else:
    print("  ❌ XGBoost CUDA not available (no GPU on this machine?)")
print()

# --- Summary ---
if failures:
    print(f"⚠️  {failures} import(s) failed")
    sys.exit(1)
else:
    print("✅ All imports successful")