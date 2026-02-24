import sys
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

def test_import(package, subpackage=None):
    try:
        if subpackage:
            exec(f"from {package} import {subpackage}")
            print(f"  ✅ from {package} import {subpackage}")
        else:
            __import__(package)
            print(f"  ✅ {package}")
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
hep_packages = [
    "uproot", "awkward", "vector", "hist", "zfit", "hepstats",
]
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
    "jupyterlab", "notebook", "ipykernel", "urllib3", "dash", "conda_pack",
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

# --- Version checks ---
print("🏷️  Version checks")
test_version("urllib3", "1.26.16")
print()

# --- CUDA ---
print("🖥️  CUDA")
try:
    import torch
    if torch.cuda.is_available():
        print(f"  ✅ PyTorch CUDA (v{torch.version.cuda}, {torch.cuda.get_device_name(0)})")
    else:
        print("  ❌ PyTorch CUDA not available")
except ImportError:
    pass

try:
    import tensorflow as tf
    gpus = tf.config.list_physical_devices('GPU')
    if gpus:
        print(f"  ✅ TensorFlow CUDA ({len(gpus)} GPU(s))")
    else:
        print("  ❌ TensorFlow CUDA not available")
except ImportError:
    pass

try:
    import xgboost as xgb
    import numpy as np
    dtrain = xgb.DMatrix(np.array([[1, 2], [3, 4]]), label=[0, 1])
    xgb.train({"device": "cuda", "max_depth": 1}, dtrain, num_boost_round=1)
    print("  ✅ XGBoost CUDA")
except Exception:
    print("  ❌ XGBoost CUDA not available")
print()

# --- Summary ---
if failures:
    print(f"⚠️  {failures} import(s) failed")
    sys.exit(1)
else:
    print("✅ All imports successful")