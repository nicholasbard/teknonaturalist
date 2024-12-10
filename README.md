teknonaturalist: A Snakemake pipeline for assessing fungal diversity from plant genome bycatch
============================================================

__teknonaturalist__ is a pipeline for detection of fungal ITS sequences in non-targeted short-read raw plant genome sequence files (PE reads only). 
__teknonaturalist__ is intended for use with Snakemake (Mölder et al., 2021), though bash scripts are also provided for command line execution. <br><br>The program is suitable for Linux and Unix (Mac) machines equipped with Python. Here, we provide an overview of the steps and resources for setup and execution of __teknonaturalist__ for fungal ITS detection and tools to integrate detections with DNAbarcoder (Vu et al., 2022) for fungal taxonomic classification. <br><br>Additional resources include example R scripts for identifying classified genome sequences. <br><br>
Data from the Betula example study, in addition to the databases and assembly files used, may be found at http://osf.io/8g6we/ and implemented by the user.

Source code available at:<br>
https://github.com/nicholasbard/teknonaturalist<br>
<br>
Version: 1.1.0<br>
teknonaturalist: A Snakemake pipeline for assessing fungal diversity from plant genome bycatch<br>
Copyright (C) 2023 Nicholas Bard et al.<br>
Contact: Nicholas Bard, nicholas.bard[at]botany[dot]ubc[dot]ca<br>
Programmer: Nicholas Bard<br>

Overview of the process
====
![teknonaturalist](/setup_resources/teknonaturalist.png)	 
<br>

To run __teknonaturalist__, open the setup and execution files, edit the header lines as needed, and save and run the scripts. Files contain annotations with important information to guide the user. We suggest that line-by-line command running of shell script and txt files may be useful, particularly for new users and for troubleshooting. <br>
<br>

Required input files:
============================================================
The __teknonaturalist__ pipeline requires paired end fastq files to run.


Quick setup: Docker
============================================================
We provide a quick setup option using __Docker__ (https://www.docker.com).<br> 
Instructions for __Docker Engine__ installation: https://docs.docker.com<br>
Instructions for __Docker Desktop__ installation: https://www.docker.com/products/docker-desktop/<br>



Setup: Installation of Snakemake and teknonaturalist (must be run once before initial use)
============================================================

__[teknonaturalist Setup](/setup_resources/teknonaturalist_setup.txt)__ 
<br> This file contains key information for installing required software, including Mamba/Conda and Snakemake, and activation of the __teknonaturalist__ environment. It also includes information for running teknonaturalist without Snakemake.<br><br>
__[environment.yaml](/environment.yaml)__ <br>
This file is required for setting up the teknonaturalist environment along with required programs used. It does not need to be run, simply present in the teknonaturalist/ directory during environment activation. <br><br>
__[Package Install for bash Script Option](/setup_resources/package_install_for_bash_script.txt)__ <br>
This file provides an alternative to Snakemake program installation with manual program installation instructions.

Setup: DNAbarcoder (must be run once before initial use)
============================================================

__[DNAbarcoder Setup](/setup_resources/DNAbarcoder.setup.txt)__ <br>
This provides instructions for setting up DNAbarcoder for fungal classification. DNAbarcoder must be installed in the __teknonaturalist__ directory (teknonaturalist/dnabarcoder/) prior to using classification scripts.<br> 

Setup: Assembly and Databases (see individual files) 
============================================================

__[Manual Prep of non-Taxon Specific Databases](/setup_resources/Manual_prep_of_non_taxon_specific_databases.txt)__ (must be run once before initial use)<br>
This file may be re-used for different plant taxa. Refer to this file if using customized databases different from those provided at https://osf.io/8g6we/ <br><br>

__[Prep Taxon Specific Assembly and Databases](/setup_resources/Prep_taxon_specific_assembly_and_databases.txt)__ (must be run for _each new plant taxon assesed_ with __teknonaturalist__; the PlanITS database only needs to be setup once for each genus.) <br>
This file is recommended for first-time users to be run line-by-line, but is also available as a [bash script](/Prep_taxon_specific_assembly_and_databases.sh). <br><br>

__[Extract Teknonaturalist Databases](extract_teknonaturalist_databases.py)__ <br>
A python script to extract all databases and assemblies provided at https://osf.io/8g6we/ <br><br>
			
__[Extract ITS.refs Database for DNAbarcoder](extract_ITS.refs_database_for_dnabarcoder.py)__ <br>
A python script to extract ITS reference database for DNAbarcoder (available at https://osf.io/8g6we/)<br><br>

This image shows the basic directory structure in order to run teknonaturalist for fungal detection. Note that teknonaturalist/dnabarcoder must be present for fungal classification. <br>
![Snakemake directory structure](/setup_resources/snakemake_directory_structure.png)<br>

Executing teknonaturalist: Preparing for fungal ITS detection
============================================================

Almost ready! Before running __teknonaturalist__ with Snakemake, make sure that the __teknonaturalist__ environment is activated:<br><br>
mamba activate teknonaturalist 
<br><br>OR<br><br>
conda activate teknonaturalist
<br><br>

__[Fastq.gz file prep](/setup_resources/Fastq.file.prep.txt)__ <br>
Instructions for obtaining and formatting input fastq.gz files are provided here. <br><br>
__[Check Before Running teknonaturalist](check_before_running_teknonaturalist.py)__ <br>
 A python script to be used prior to executing __teknonaturalist__ that checks for input files, non-empty assembly and database directories, and an activated teknonaturalist environment.<br><br>
Now you are ready to run __teknonaturalist__!

Executing teknonaturalist: fungal ITS detection (to be run on 1+ conspecific genome files)
============================================================

__(if using Snakemake)__<br>
The intended way to run __teknonaturalist__ is using Snakemake. A Snakefile and an environment.yaml file are required for Snakemake. An overview of the process is found here: <br><br>
__[Running_teknonaturalist_with_Snakemake_Overview](/setup_resources/Running_teknonaturalist_with_Snakemake_Overview.txt)__ <br>
This file provides a brief guide to fungal ITS detection with __teknonaturalist__. <br><br>

__[Snakefile for Equal PE read fastqs](/Snakefile_equal_reads)__ and __[Snakefile for Unequal PE read fastqs](/Snakefile_unequal_reads)__ <br>
Each is a Snakemake execution files (Snakefile) for PE fastq files with equal read counts and unequal read counts, respectively.<br><br>

_Example commands to run Snakemake_:

snakemake --cores {CORE NUMBER} --snakefile {Snakefile name} {Output file}
<br><br>
Dry runs are quite helpful to run to identify potential problems. To dry run, add '-np':<br><br>
snakemake -np --cores {CORE NUMBER} --snakefile {Snakefile name} {Output file}
<br><br>
__Example commands For teknonaturalist (easiest way)__ <br>

Using equal PE read fastq files:<br>
snakemake --cores {CORE NUMBER} --snakefile Snakefile_equal_reads data/final/{SRRnumber}.ITSx
<br><br>Using unequal PE read fastq files:<br>
snakemake --cores {CORE NUMBER} --snakefile Snakefile_unequal_reads data/final/{SRRnumber}.ITSx
<br><br>EXAMPLE (single fastq files):<br>
snakemake --cores 4 --snakefile Snakefile_equal_reads data/final/ERR2026266.ITSx
<br><br>EXAMPLE (multiple fastq files):<br>
snakemake --cores 20 --snakefile Snakefile_equal_reads data/final/{ERR2026264,ERR2026266}.ITSx 
<br><br>
__(if using command line)__ <br>
We also provide bash scripts to run the pipeline. Note that no __teknonnaturalist__ environment does not need to be activated if all required packages are installed.<br><br>
See __[teknonaturalist Fungal ITS Detection Equal Reads](/teknonaturalist.Fungal.ITS.detection.equal.reads.sh)__ and __[teknonaturalist Fungal ITS Detection Unequal Reads](/teknonaturalist.Fungal.ITS.detection.unequal.reads.sh)__ <br>
The teknonaturalist execution bash script [non-Snakemake] script for PE fastq.gz files with equal read count sand unequal read counts, respectively.

NOTE: If using mamba/conda with a task manager on a cluster, cache files during computational tasks may need to be diverted to a directory with file-writing permissions. 
Before running the pipeline:
mamba deactivate
export XDG_CACHE_HOME=/<your directory> 
Then activate mamba/conda environment before submitting the batch.

Executing DNAbarcoder: fungal taxonomic classification
============================================================

Following fungal ITS detection of a dataset (one to many samples), DNAbarcoder (Vu et al., 2022) may be employed for taxonomic classification.

__[Fungal ITS Classifier bash Script](/Fungal.ITS.classifier.sh)__ and __[Fungal ITS Classifier text file](/Fungal.ITS.classifier.txt)__ <br>
A file to pool and classify fungal taxa in a dataset of plant genomes after fungal ITS detection.<br>

Assessing classification support with flanking sequences 
============================================================

[Analyze Flanking 5.8S and ITS Sequences](/R_scripts/analyze.5.8S.R) <br>
An example R script (from Betula study) to identify classified fungal sequences with flanking sequence support at class taxonomic rank. <br>

[Example database and assembly files for reference/use](https://osf.io/8g6we/) 
============================================================
These are divided into "non-taxon-specific", which may be used for any plant taxon; and "taxon-specific", 
which are useful for an example with the Betula species used in the example paper. Available at https://osf.io/8g6we/
		
  		1. General:
			a. fungi.tar.gz 
			b. uchime_datasets.tar.gz
			c. univec.tar.gz
		
  		2. Betula:
			a. genbank.tar.gz (needed for each plant species)
			b. PLANiITS.tar.gz (needed for each plant genus)
			c. assembly.tar.gz (assembly of the same plant species , or a closely related congener)
   
   		3. ITS.refs.tar.gz - Example fungal ITS reference for use with DNAbarcoder

Additional materials 
============================================================

__[R Genus Heatmap](/R_scripts/create.genus.heatmap.w.supp.files.R)__ <br>
A script used for creating the supplemental files and figure used in the Betula example paper.

Empty __assembly, database, data/orig.fastqs, and data/finalcombined__ directories as placeholders. <br>
If database and assembly .tar.gz files are installed into teknonaturalist directory and extracted 
using the "extract" scripts, the directories will assemble with the proper subdirectories. 

__[Betula data](https://osf.io/8g6we/)__ from example paper. <br> 
Produced following fungal detection and classification in plant genomes available at https://osf.io/8g6we/.


Dedicated to Colin Richard Ferguson Ward 
