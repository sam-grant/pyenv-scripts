import sys

def test_import(package, subpackage=None):
    try:
        if subpackage:
            exec(f"from {package} import {subpackage}")
            print(f"from {package} import {subpackage} imported successfully")
        else:
            __import__(package)
            print(f"✅ {package} imported successfully")
    except ImportError as e:
        print(f"❌ Failed to import {package}{' -> ' + subpackage if subpackage else ''}: {e}")
        sys.exit(1)

# List of basic packages to test
packages = [
    ("matplotlib", None),
    ("pandas", None),
    ("uproot", None),
    ("scipy", None),
    ("sklearn", None),  
    ("torch", None), 
    ("tensorflow", None),
    ("jupyterlab", None),
    ("notebook", None),
    ("statsmodels", None),
    ("awkward", None),
    ("urllib3", None),
    ("ipykernel", None), 
    ("vector", None),
    ("plotly", None),
    ("dash", None),
    ("tqdm", None),
    ("hist", None),
    ("pyarrow", None),
    ("pyutils", None)
]

# List of specific modules
specific_modules = [
    # ("tensorflow.keras", "keras"), ## rootana ONLY!
    ("pyutils.pyread", "Reader"),
    ("pyutils.pyimport", "Importer"),
    ("pyutils.pyprocess", "Processor"),
    ("pyutils.pyselect", "Select"),
    ("pyutils.pyvector", "Vector"),
    ("pyutils.pyprint", "Print"),
    ("pyutils.pyplot", "Plot"),
    ("pyutils.pydisplay", "Display")
]

# Test each package
for package, subpackage in packages:
    test_import(package, subpackage)

# Test specific version for urllib3
try:
    import urllib3
    if urllib3.__version__ != "1.26.16":
        print(f"urllib3 version is {urllib3.__version__}, expected 1.26.16")
    else:
        print("urllib3 version is correct")
except ImportError as e:
    print(f"Failed to import urllib3: {e}")
    sys.exit(1)

# Test specific modules
for package, subpackage in specific_modules:
    test_import(package, subpackage)
