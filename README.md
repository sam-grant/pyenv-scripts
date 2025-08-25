# pyenv-scripts

Shell scripts for managing the distributed Mu2e Python environment. 

### Core scripts

`build.sh` - Creates a new condanvironment from a YAML configuration file

* Prompts for environment name and YAML file path
* Validates inputs and creates the environment using mamba env create
* Automatically activates the new environment
* Optionally copies environment variables script, `env_vars.sh`, to environment activation directory
* Optionally installs Jupyter kernel for the environment
* Must be sourced to properly activate the environment: `source build.sh`

`distribute.sh` - Packages and distributes the currently active conda environment

* Exports current environment to YAML file, with timestamp
* Modifies YAML to use GitHub URL for `pytutils` 
* Creates compressed tar archive of the entire environment using conda pack
* Extracts environment to shared directory for distribution on `/cvfms`
* Must be sourced to access current environment: `source distribute.sh`

### Helper scripts

`install_kernel.sh` - Installs an interactive kernel file in the currently active environment, which can be used post-distribution. 

### Test scripts

`test_imports.py` - Runs imports on packages 

`test_imports.ipynb` - Runs `test_import.py` 