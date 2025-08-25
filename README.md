# pyenv-scripts

Scripts for managing the distributed Mu2e Python environment, `pyenv`. 

`pyenv` change log is [here](CHANGELOG.md).

```
├── deploy-scripts # Scripts for building and distributing the environmentg 
│   ├── build.sh
│   ├── distribute.sh
│   ├── add_setup_script.sh
│   └── install_kernel.sh
├── internal-scripts # Scripts to be installed in the environment itself
│   └── setup_mu2e_python_env.sh
├── test-scripts # Scripts for testing the environment
│   ├── test_imports.ipynb
│   └── test_imports.py
└── yml # Environment YAML files
    ├── full # Full YAMLs from conda export 
    │   ├── ana_v1.0.0.yml
    │   ├──  ...
    └── minimal # Minimal YAMLs, without dependancies
    │   ├── ana_v1.0.0.yml
    │   ├──  ...

```

See the following sections for more details and usage.

---

## deploy-scripts

Scripts for building and distributing the environment. 

These must be run conda environment that contains `conda-pack` and `pip`, I always work on EAF for this. 

#### `build.sh`

Creates a new conda environment from a starting YAML file.

1. Prompts for environment name and YAML file path;
1. Validates inputs and creates the environment;
1. Automatically activates the new environment;
1. Copies our custom environment variable setup script to activation directory;
1. Installs an interactive Jupyter kernel. 

**Usage:** 

```
. build.sh -f starting_env -n new_env # -y (auto yes)
```

e.g.

```
. build.sh -f ana_v1.1.0 -n ana_v1.0.0 -y 

```

Once built, one can install new packages and make other changes before distributing. 

---

#### `distribute.sh` 

Packages and distributes the environment.

1. Exports current environment to YAML file;
1. Modifies YAML to use GitHub URL for `pytutils`;
1. Creates compressed tar archive of the entire environment using `conda-pack`;
1. Extracts environment to shared directory for distribution on `/cvmfs`;

**Usage:** 

```
. distribute.sh -e myenv
. distribute.sh -e myenv # -y # (auto yes)
. distribute.sh # if the current active environment is the one to distribute
```

e.g.


```
. distribute.sh -e ana_v1.0.0 -y

```

---

## internal-scripts

Scripts to be installed in the environment itself.

##### `setup-mu2e-python-env.sh`

Environment isolation script for the Mu2e Python environment, ensuring clean path management when used alongside the existing Mu2e stack (particularly `muse`). 

It is automatically copied to `$CONDA_PREFIX/etc/conda/activate.d/` by `build.sh` and sourced on environment activation. It re-sources automatically before Python commands (python, pip, jupyter, etc.) to maintain clean environment state.

Manual use:

```
setup_mu2e_python_env
```

---

## test-scripts

#### `test_imports.py`

Runs imports on packages. 

#### `test_imports.ipynb`

Runs `test_import.py` via interactive kernel. 

>**Note:** It is recommended to use `test_imports.ipynb` rather than `test_imports.py` directly, since this automatically tests the interactive element. 