teknonaturalist: A Snakemake pipeline for assessing fungal diversity from plant genome bycatch
============================================================
![teknonaturalist](/images/teknonaturalist.png)	 
<br>
Description
====
__teknonaturalist__ is a pipeline for detection of fungal ITS sequences in non-targeted short-read raw plant genome sequence files (PE reads only). 
__teknonaturalist__ is intended for use with [Snakemake](https://snakemake.readthedocs.io/en/stable/) (Mölder et al., 2021). We provide a [Dockerfile](/Docker/Dockerfile) (https://docs.docker.com) for setup. bash scripts are also provided for command line execution. <br><br>The program is suitable for Linux and Unix (Mac) machines equipped with Python. Here, we provide an overview of the steps and resources for setup and execution of __teknonaturalist__ for fungal ITS detection and tools to integrate detections with [DNAbarcoder](https://github.com/vuthuyduong/dnabarcoder) (Vu et al., 2022) for fungal taxonomic classification. <br><br> Additional resources include [example R scripts](https://github.com/nicholasbard/tekno-manuscript-analysis) for identifying classified genome sequences. <br><br>
[Data from the Betula example study](http://osf.io/8g6we/), in addition to the [databases and assembly files used](http://osf.io/8g6we/) are also available.<br> 

Source code available at:<br>
https://github.com/nicholasbard/teknonaturalist<br>
<br>
Version: 1.1.0<br>
teknonaturalist: A Snakemake pipeline for assessing fungal diversity from plant genome bycatch<br>
Copyright (C) 2023 Nicholas Bard et al.<br>
Contact: Nicholas Bard, nicholas.bard[at]botany[dot]ubc[dot]ca<br>
Programmer: Nicholas Bard<br>
Use of all databases used teknonaturalist requires proper citation according to their respective licensing (see References).
<br>

Dependencies:
============================================================
__sra-tools__ available at [SRA Tools Github](https://github.com/ncbi/sra-tools) OR [SRA Tools Conda](https://anaconda.org/bioconda/sra-tools) <br>

__Docker__ (Recommended) <br>
[Docker Engine](https://docs.docker.com) or [Docker Desktop](https://www.docker.com/products/docker-desktop/) will work. <br>
_We provide a Dockerfile that sets up and activates the teknonaturalist Snakemake environment_ <br>

## Required input files:
The __teknonaturalist__ pipeline requires paired end fastq files to run.
<br>

### Quick fastq retrieval: <br>
See also [Fastq.file.prep.txt](/0_Fastq_file_Setup/Fastq.file.prep.txt) <br>
Paired-end fastq files may be retrieved using [SRA Tools](https://github.com/ncbi/sra-tools)<br><br>
Navigate to teknonaturalist directory

```
cd $PATH/teknonaturalist
```

Obtain SRA files from NCBI SRA.
```
prefetch SRR<###>.sra
```

Create fastq files from NCBI SRA. Note that $PATH to local SRA file repository may be different among users.
```
fasterq-dump --split-files $PATH/SRR<###>.sra -O .
# OR, for files with different read counts
fasterq-dump --split-3 $PATH/SRR<###>.sra -O .
```

Ia. Quick basic setup and test: Docker
============================================================
We provide a quick setup option using [Docker](/Docker) <br> 

## Run demo with test data (_Betula ermanii_)
### 1. Build Docker image
Navigate to teknonaturalist/Docker directory
```
cd $PATH/teknonaturalist/Docker
```
Build Docker image. 
```
docker build -t teknonaturalist .
```
The image can now be run and tested on demo data provided. 

### 2. Run test Docker image
#### Option 1: Recommended - Bind Mount to save volume locally.
Use 'bind mount' to save the basic __teknonaturalist__ and [DNAbarcoder](https://github.com/vuthuyduong/dnabarcoder) setup, including databases and assembly. This will save databases locally in persistent volume ('teknonaturalist') that will not be removed if the Docker container is deleted. <br>
Basically, this means that database files will not need to be re-downloaded if a new Docker image is built, and are saved as tar.gz files. <br>
```
# Note: The volume name may be customized by modifying code to <custom>:/app.
docker run -v teknonaturalist:/app -it teknonaturalist
```
#### Option 2: Will not save databases (takes a few minutes for every build).
```
# Note: The volume name may be customized by modifying code to <custom>:/app.
docker run -v -it teknonaturalist
```

Unpack database and assembly files using python scripts and remove clutter.
```
python ./extract_teknonaturalist_databases.py
python ./extract_ITS.refs_database_for_dnabarcoder.py
rm *.tar.gz
```

Test teknonaturalist (fungal identification) with fake data.
```
snakemake --cores 1 --snakefile demoSnakefile data/final/F.c.e.reads.SRRdemo.fasta
```

Test DNAbarcoder (fungal classification) with fake data.
```
python3.12 dnabarcoder/dnabarcoder.py search -i data/final/F.c.reads.SRRdemo.fasta -r dnabarcoder/ITS.refs/unite2024/unite2024ITS1.unique.phylum.fasta -ml 50 -p ../data/finalcombined/SRRdemo
python3.12 dnabarcoder/dnabarcoder.py classify -i data/finalcombined/SRRdemo.unite2024ITS1.unique.phylum_BLAST.bestmatch -c dnabarcoder/ITS.refs/unite2024/unite2024ITS1.unique.phylum.classification -cutoffs dnabarcoder/ITS.refs/unite2024/unite2024ITS1.unique.cutoffs.best.json -p ../data/finalcombined/SRRdemo.ITS1
```

Check that it completed:
```
head data/finalcombined/SRRdemo.ITS.classified
```

If that all looks good, proceed to customizing.

#### Alternatively, you may use the directory setup during testing, but operate locally and outside of a container (will require setup of all packages).
```
mkdir $PATH/<projectname>
docker build -o $PATH/projectname .
cd $PATH/projectname/teknonaturalist
python ./extract_teknonaturalist_databases.py
python ./extract_ITS.refs_database_for_dnabarcoder.py
rm *.tar.gz
```

# Ib. Alternative - Basic setup without Docker <br>
### Complete these steps: 
#### 1a. [Set up Snakemake](/1_Basic_setup_and_install/Snakemake_setup.md) OR
#### 1b. [Manual package install with mamba/conda](/1_Basic_setup_and_install/MANUAL_package_install_for_bash_script.txt)
#### 2. [Set up teknonaturalist using Snakemake](/1_Basic_setup_and_install/teknonaturalist_setup.md)  <br>

#### Nest, download basic databases. <br>
You will customize these later for your host plant species. 

```
# Download databases to run teknonaturalist
osf -p j57fs clone .

# Download sample species (Betula nana) assembly to run teknonaturalist with sample file
osf -p vnh3b clone .

# Download premade ITS and 5.8S sequences for use with DNAbarcoder; move all to correct location.
osf -p 38uk2 clone .
mv osfstorage/* .
rm -r osfstorage
```

#### Create necessary directories
```
# Make all directories.
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

#### Unpack database and assembly files using python scripts and remove clutter. <br>
This will produce the necessary file structure to run teknonaturalist.
```
python ./extract_teknonaturalist_databases.py
python ./extract_ITS.refs_database_for_dnabarcoder.py
rm *.tar.gz
```

# II. Setting up pipeline database and assembly for your host species <br>
At this point your directory structure should look like this. However, you will need to customize it for your host plant species. <br>
![Snakemake directory structure](/images/snakemake_directory_structure.png)<br>

### For Docker:
We will continue to work on the Docker container you created. If you exited the container, you may restart and reconnect:
  <br>
If resuming from outside container:
```
# Determine container ID from all containers 
docker ps -a
# Restart and reattach to container.
docker start <docker_container_identifier>
docker attach <docker_container_identifier>
```
# Now everybody! <br> <br>
## Building databases for your host plant taxon of interest.<br>
#### The following code may be alternatively edited into [Prep_taxon_specific_assembly_and_databases.sh](/2_Setup_assembly_and_databases/Prep_taxon_specific_assembly_and_databases.sh) and run as a bash script.

### a. PLANiTS dataset for the host genus.
Replace <GENUS> with name of host genus.<br>
```
grep "<GENUS>" database/PLANiTS/ITS_taxonomy | awk -F ' ' '{print $1}' > database/PLANiTS/<GENUS>.ITS
seqtk subseq database/PLANiTS/ITS.fasta database/PLANiTS/<GENUS>.ITS > database/PLANiTS/<GENUS>.ITS.fasta
grep "<GENUS>" database/PLANiTS/ITS1_taxonomy | awk -F ' ' '{print $1}' > database/PLANiTS/<GENUS>.ITS1
seqtk subseq database/PLANiTS/ITS1.fasta database/PLANiTS/<GENUS>.ITS1 > database/PLANiTS/<GENUS>.ITS1.fasta
grep "<GENUS>" database/PLANiTS/ITS2_taxonomy | awk -F ' ' '{print $1}' > database/PLANiTS/<GENUS>.ITS2
seqtk subseq database/PLANiTS/ITS2.fasta database/PLANiTS/<GENUS>.ITS2 > database/PLANiTS/<GENUS>.ITS2.fasta
cat database/PLANiTS/<GENUS>.ITS.fasta database/PLANiTS<GENUS>.ITS1.fasta database/PLANiTS/<GENUS>.ITS2.fasta > database/PLANiTS/<GENUS>.fasta
```
Make genus specific ITS database.<br>
```
makeblastdb -in database/PLANiTS/<GENUS>.fasta -dbtype nucl
```

### b. Get Genbank fasta data for focal species.
Replace <FOCAL_NO_DOT> with FULL species name, e.g. Delphinium menziesii
Replace <FOCAL_WITH_DOT> with FULL species name, separated by . , e.g., Delphinium.menziesii
```
esearch -db nuccore -query '"<FOCAL_NO_DOT>"[Organism] OR $<FOCAL_NO_DOT>[All Fields] AND "<FOCAL_NO_DOT>"[porgn] AND ddbj_embl_genbank[filter] AND is_nuccore[filter]' | efetch -format fasta > database/genbank/<FOCAL_WITH_DOT>.Genbank.nucl.fasta
```
Make Blast database for your targe host plant species.
```
makeblastdb -in database/genbank/<FOCAL_WITH_DOT>.Genbank.nucl.fasta -dbtype nucl
```

### c. Get reference assembly (fasta) of focal species or closely related congener (or closest relative with available assembly!) and index.
Note: The fasta file may also be downloaded from NCBI manually if ncbi-genome-download fails.<br><br>
Replace <CONGENER_NO_DOT> with FULL species name, e.g. Adonis annua <br>
Replace <CONGENER_WITH_DOT> with FULL species name, separated by . , e.g., Adonis.annua <br>
```
ncbi-genome-download -s genbank --genera "<CONGENER_NO_DOT>" plant -o assembly/<CONGENER_WITH_DOT>.assembly -F fasta
```

For the following lines, the name of the assembly directory will be assigned to the "ac" variable (e.g., ac = "GCA_000327005.1"), and the assembly is unzipped. The full name of the ac variable may be used instead for the lines below. 
```
#Note: this will pick the first one. You can replace ${ac} with the genome name if you prefer. 
ac=$(ls assembly/<CONGENER_WITH_DOT>.assembly/genbank/plant | head -1)
gunzip assembly/<CONGENER_WITH_DOT>.assembly/genbank/plant/${ac}/*.gz
```

Index reference assembly with bwa.
```
bwa index -p assembly/<CONGENER_WITH_DOT>.assembly/<CONGENER_WITH_DOT>.bwa.index <CONGENER_WITH_DOT>.assembly/genbank/plant/${ac}/*.fna
```
# IIIa. Running the pipeline with Snakemake <br>

### If using Docker, import your files into the container. <br>

If you haven't yet, exit container and determine container ID by listing recently run containers. <br>
Note: container IDs are a series of random numbers and letters. 
```
exit
docker ps -l
# all containers:
docker ps -a
```
Now, import fastqs to main directory in container. Restart container and re-attach to it.
```
docker cp $PATH/<SRRnumber>*.fastq <docker_container_identifier>:/teknonaturalist/data/orig.fastqs
docker start <docker_container_identifier>
docker attach <docker_container_identifier>
```

### If not using Docker:
Ensure [Snakefile](/Snakefile) (or equivalent) and [environment.yaml](/environment.yaml) are in teknonaturalist directory.<br>
Make sure fastq files are in teknonaturalist/data/orig.fastqs directory
```
mv <PATH>/<to>/*.fastq $PATH/teknonaturalist/data/orig.fastqs
```

Check files/directories have been set up by running [check_before_running_teknonaturalist.py](/check_before_running_teknonaturalist.py) <br>
```
python3.12 check_before_running_teknonaturalist.py
```

### To run teknonaturalist with Snakemake, edit the 'Customizable Section' in [Snakefile](/Snakefile) with a text editing tool and save files.
Files contain annotations with important information to guide the user. <br>
At minimum, text within <> must be edited (with the <> deleted as well). <br>
Note: Multiple SRR files may be added in, separated by ",".

# IIIb. Running the pipeline with bash <br>
Also see [Running_teknonaturalist_with_bash_.txt](/3_Running_teknonaturalist/Running_teknonaturalist_with_bash.txt)

Make sure fastq files are in teknonaturalist/data/orig.fastqs directory
```
mv <PATH>/<to>/*.fastq $PATH/teknonaturalist/data/orig.fastqs
```

Check files/directories have been set up by running [check_before_running_teknonaturalist.py](/check_before_running_teknonaturalist.py)
```
python3.12 check_before_running_teknonaturalist.py
```

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
