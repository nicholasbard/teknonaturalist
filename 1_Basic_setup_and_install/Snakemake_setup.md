# Snakemake installation and setup instructions

### These instructions include quick sets of instructions for setting up Conda, Mamba, and Snakemake. <br>
Please refer to their respective help pages if more extensive setup or troubleshooting is needed. <br>
[Conda](https://conda.io/projects/conda/en/latest/user-guide/index.html) <br>
[Mamba](https://mamba.readthedocs.io/en/latest/index.html) <br>
[Snakemake](https://snakemake.readthedocs.io/en/stable/)<br>

NOTE 1: Mac devices equipped with ARM may require additional steps/troubleshooting, a few potential steps are included [here](/Custom.setup/Troubleshooting_mamba_conda_MACS.txt) <br><br>
NOTE 2: If using mamba/conda with a task manager on a cluster, cache files during computational tasks may need to be diverted to a directory with file-writing permissions. 
Before running the pipeline:
```
mamba deactivate
export XDG_CACHE_HOME=/<your directory>
```

Then activate mamba/conda environment before submitting the batch.

## Snakemake installation and setup instructions 
teknonaturalist may be run using provided Snakemake and bash scripts. The program requires several programs that can be installed <br><br>
__A.__ using Mamba (from mini forge) and Snakemake (recommended) <br>
__B.__ using Conda/Mamba and Snakemake (not recommended) <br>
__C.__ manually (may be used if Snakemake malfunctions) <br><br>

NOTE: Swapping the command 'conda' with 'mamba' (or vice versa) may be helpful in some cases. Ideally 'mamba' can be used for everything. <br>

### Option 1. Docker - see README.md. 
#### This will cover Snakemake installation and teknonaturalist environment creation and activation.<br><br>
	
### Option 2. Snakemake installation via Mamba installation
#### A. Install Mamba using Miniforge, as noted here: 
https://mamba.readthedocs.io/en/latest/installation/mamba-installation.html <br>
Miniforge is available here:
https://github.com/conda-forge/miniforge <br>

#### B. Install Snakemake, as noted here:
https://snakemake.readthedocs.io/en/stable/getting_started/installation.html
using these commands (if 'mamba' doesn't work, try using 'conda')
```
mamba activate base
#Note: The first time activating mamba, you may need to call it from the condabin directory. (e.g., <PATH>/miniforge3/condabin/mamba activate).
mamba create -c conda-forge -c bioconda -n snakemake snakemake
```

### Option 3. Snakemake installation via Mamba installation via Conda (not recommended)

#### A. Install Conda, as noted here: 
https://conda.io/projects/conda/en/latest/user-guide/index.html

#### B. Once Conda is installed, install Mamba using Conda:
```
conda install -n base -c conda-forge mamba
```

#### C. Install Snakemake, as noted here:
https://snakemake.readthedocs.io/en/stable/getting_started/installation.html
using these commands (if 'mamba' doesn't work, try using 'conda')
```
mamba activate base
mamba create -c conda-forge -c bioconda -n snakemake snakemake
```

