# teknonaturalist setup
#### This file provides instructions and commands for setting up teknonaturalist fungal detection pipeline, using Snakemake or bash. 

## Create/activate teknonaturalist environment with Snakemake ## 
#### Only run after successful [Snakemake](/1_Basic_setup_and_install/Snakemake_setup.md) setup. 

1. Navigate to provided 'teknonaturalist' directory. This is the working directory where virtually all commands will be run. The remaining setup and pipeline execution will be within this directory. There must be an environment.yaml file (provided) to activate the 'teknonaturalist' Snakemake environment. At least one Snakefile must also be present in order to run Snakemake.
```
cd $PATH/teknonaturalist
```

2. Verify that the provided environment.yaml and Snakefile files to the working directory ($PATH/teknonaturalist/). The environment.yaml file is used to create the mamba environment. The Snakefile is the fungal identification pipeline. 

3. Create the 'teknonaturalist' Snakemake environment. This will install the programs needed to set up and run the fungal detection pipeline in Snakemake. 
```
mamba env create --name teknonaturalist --file environment.yaml
```

Note: if environment creation does not work, try first running:
```
mamba activate base
```

4. Activate teknonaturalist Snakemake environment 
NOTE: conda may be substituted for mamba.
```
mamba activate teknonaturalist
```

Now that the teknonaturalist Snakemake environment is activated, all programs necessary are activated for database and assembly preparation (if desired), as well as fungal ITS detection with teknonaturalist! Note that teknonaturalist environment MUST BE ACTIVATED to run programs installed in this environment.


## Installing basic databases and assemblies for teknonaturalist and DNAbarcoder setup 

### Download basic databases. 
You will customize these later for your host plant species. 

Download databases to run teknonaturalist
```
osf -p j57fs clone .
```

Download sample species (Betula nana) assembly to run teknonaturalist with sample file
```
osf -p vnh3b clone .
```

Download premade ITS and 5.8S sequences for use with DNAbarcoder; move all to correct location.
```
osf -p 38uk2 clone .
mv osfstorage/* .
rm -r osfstorage
```

#### Create necessary directories
```
mkdir data
mkdir data/orig.fastqs
mkdir data/finalcombined
mkdir assembly
mkdir assembly/Betula.nana.assembly
mkdir database
mkdir database/univec
mkdir database/uchime_datasets
mkdir database/genbank
mkdir database/fungi
mkdir database/PLANiTS
```

#### Setup DNAbarcoder
```
git clone https://github.com/vuthuyduong/dnabarcoder.git
mkdir dnabarcoder/ITS.refs
```

#### Unpack database and assembly files using python scripts and remove clutter. 
This will produce the necessary file structure to run teknonaturalist.
```
python ./extract_teknonaturalist_databases.py
python ./extract_ITS.refs_database_for_dnabarcoder.py
rm *.tar.gz
```

# Alternative - tekonaturalist setup without Snakemake (Not recommended)

## Manual installation (may be used if Snakemake malfunctions) <br>
1. Create the following directories should be created for intermediate files.

```
cd $PATH/teknonaturalist
mkdir data
mkdir data/trimmed1
mkdir data/trimmed2
mkdir data/trimmed3
mkdir data/QC
mkdir data/CQC
mkdir data/bwa
mkdir data/no.match
mkdir data/krakenout
mkdir data/krakenout2
mkdir data/blast
mkdir data/nonchimera
mkdir data/meta
```

2. Install all programs using the instructions provided in [MANUAL_package_install_for_bash_script.txt](/1_Basic_setup_and_install/MANUAL_package_install_for_bash_script.txt). <br>
It is necessary that the directory setup stays the same (see snakemake_directory_structure.png) <br><br>

### Next steps: <br>
Before teknonaturalist may be run, the assembly and database files need to be installed in the teknonaturalist/ directory. <br>
Please see the [Prep_taxon_specific_assembly_and_databases.sh](/2_Setup_assembly_and_databases/Prep_taxon_specific_assembly_and_databases.sh) or [README](/README.md) for next steps. <br><br>
Advanced: Details for basic database setup may be found in [Manual_prep_of_non_taxon_specific_databases.txt](/Custom.setup/Manual_prep_of_non_taxon_specific_databases.txt)




