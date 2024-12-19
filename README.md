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

# Set up and run teknonaturalist (and DNAbarcoder) <br>
#### We recommend that users go through the README first in order to successfully set up and execute teknonaturalist and DNAbarcoder using mock _Betula ermanii_ data. This 1) quickly orients the user and 2) sets up much of what is needed to run the pipeline on different genomic data (further required setup is described here, subsequently).
The order of the numbered directories is largely synchronous with this README. These directories contain more detailed information. The scripts and instructions in these directories may also be executed as an alternative and/or complementary approach to provide users with flexible options for the __teknonaturalist__ pipeline (i.e., without Docker, only via bash, etc). <br><br>
_We provide a one size fits all approach for database construction, however users may wish to modify the databases used (e.g., update the sources when new versions are released) and may consult the following for details on how we set them up, available here:_
[Prep_taxon_specific_assembly_and_databases.sh](/2_Setup_assembly_and_databases/Prep_taxon_specific_assembly_and_databases.sh), [DNAbarcoder.prep.txt](/Custom.setup/DNAbarcoder.prep.txt), and [Manual_prep_of_non_taxon_specific_databases.txt](/Custom.setup/Manual_prep_of_non_taxon_specific_databases.txt) <br>

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
```
docker run -it teknonaturalist
```

Unpack database and assembly files using python scripts and remove clutter.
```
python ./extract_teknonaturalist_databases.py
python ./extract_ITS.refs_database_for_dnabarcoder.py
rm *.tar.gz
```

Test teknonaturalist (fungal identification) with fake data.
```
snakemake --cores 1 --snakefile demoSnakefile data/final/SRRdemo.ITSx
#Alternatively, to direct all stderr and stdout to log file:
snakemake --cores 1 --snakefile demoSnakefile data/final/SRRdemo.ITSx > data/logs/demoSnakefile.log 2>&1
```

__Note__ that Snakemake is likely to trigger an alarm for ITSx upon completion. This error message may be ignored. It will read something like this: <br>
```
Waiting at most 5 seconds for missing files.
MissingOutputException in rule itsx in file /teknonaturalist/demoSnakefile, line 412:
Job 0 completed successfully, but some output files are missing. Missing files after 5 seconds. This might be due to filesystem latency. If that is the case, consider to increase the wait time with --latency-wait:
data/final/SRRdemo.ITSx (missing locally, parent dir contents: contigs.reads.SRRdemo.fasta, SRRdemo.ITSx.5_8S.full_and_partial.fasta, SRRdemo.ITSx_no_detections.fasta, F.c.e.reads.SRRdemo.fasta, SRRdemo.ITSx.graph, SRRdemo.ITSx.summary.txt, SRRdemo.ITSx.LSU.fasta, SRRdemo.ITSx.ITS2.full_and_partial.fasta, SRRdemo.ITSx.5_8S.fasta, SRRdemo.ITSx.positions.txt, SRRdemo.ITSx.full.fasta, SRRdemo.ITSx.SSU.full_and_partial.fasta, SRRdemo.ITSx.ITS1.fasta, SRRdemo.ITSx.ITS2.fasta, SRRdemo.ITSx_no_detections.txt, SRRdemo.ITSx.problematic.txt, SRRdemo.ITSx.SSU.fasta, SRRdemo.ITSx.ITS1.full_and_partial.fasta, F.c.reads.SRRdemo.fasta, SRRdemo.ITSx.LSU.full_and_partial.fasta, SRRdemo.ITSx.full_and_partial.fasta)
Shutting down, this might take some time.
Exiting because a job execution failed. Look above for error message
```
Test DNAbarcoder (fungal classification) with fake data.
```
python3.12 dnabarcoder/dnabarcoder.py search -i data/final/SRRdemo.ITSx.ITS2.full_and_partial.fasta -r dnabarcoder/ITS.refs/unite2024/unite2024ITS2.unique.phylum.fasta -ml 50 -p ../data/finalcombined/SRRdemo
python3.12 dnabarcoder/dnabarcoder.py classify -i data/finalcombined/SRRdemo.unite2024ITS2.unique.phylum_BLAST.bestmatch -c dnabarcoder/ITS.refs/unite2024/unite2024ITS2.unique.phylum.classification -cutoffs dnabarcoder/ITS.refs/unite2024/unite2024ITS2.unique.cutoffs.best.json -p ../data/finalcombined/SRRdemo.ITS2
```

Check that it completed:
```
head data/finalcombined/SRRdemo.ITS2.classified
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
## Complete these steps: 
#### 1a. [Set up Snakemake](/1_Basic_setup_and_install/Snakemake_setup.md) OR 1b. [Manual package install with mamba/conda](/1_Basic_setup_and_install/MANUAL_package_install_for_bash_script.txt)
#### 2. [Set up teknonaturalist using Snakemake](/1_Basic_setup_and_install/teknonaturalist_setup.md)  <br>

# Required input files:
#### The __teknonaturalist__ pipeline requires paired end fastq files to run.<br>
### Quick fastq retrieval: <br>
See also [Fastq.file.prep.txt](/0_Fastq_file_Setup/Fastq.file.prep.txt) <br>
Paired-end fastq files may be retrieved using [SRA Tools](https://github.com/ncbi/sra-tools)<br><br>
NOTE: At present, prefetch of SRA files and fasterq-dump must be performed outside of Docker container (due to incompatibilities with SRA-tools).
Once outside the container, navigate to teknonaturalist directory

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
```

OR, for files with different read counts
```
fasterq-dump --split-3 $PATH/SRR<###>.sra -O .
```
<br>

# II. Setting up pipeline database and assembly for your host species <br>
At this point your directory structure should look like this. However, you will need to customize it for your host plant species. <br>
![Snakemake directory structure](/images/snakemake_directory_structure.png)<br>

## For Docker users:
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

## For everybody: <br> Building databases for your host plant taxon of interest.<br>
#### The following process may be run as a bash script after editing: [Prep_taxon_specific_assembly_and_databases.sh](/2_Setup_assembly_and_databases/Prep_taxon_specific_assembly_and_databases.sh).

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
esearch -db nuccore -query '"<FOCAL_NO_DOT>"[Organism] OR <FOCAL_NO_DOT>[All Fields] AND "<FOCAL_NO_DOT>"[porgn] AND ddbj_embl_genbank[filter] AND is_nuccore[filter]' | efetch -format fasta > database/genbank/<FOCAL_WITH_DOT>.Genbank.nucl.fasta
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
bwa index -p assembly/<CONGENER_WITH_DOT>.assembly/<CONGENER_WITH_DOT>.bwa.index assembly/<CONGENER_WITH_DOT>.assembly/genbank/plant/${ac}/*.fna
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
Note: Multiple SRR files may be added in, separated by ",".<br><br>

Now you are ready to run teknonaturalist on your data with Snakemake!<br>
First try a dry run (use -np tag). This evaluates the process from the end to the beginning without actually running anything (starting with output files, then working up to inputs).
```
snakemake -np --cores {CORE NUMBER} --snakefile {Snakefile name} {Output file}
```

If no errors were detected, run Snakemake!
```
snakemake --cores {CORE NUMBER} --snakefile {Snakefile name} {Output file}
```

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

Edit the appropriate bash script with your variables in "customizable variables" section <br>
_Equal reads:_ [teknonaturalist.Fungal.ITS.detection.equal.reads.sh](/teknonaturalist.Fungal.ITS.detection.equal.reads.sh) <br>
_Unequal reads:_ [teknonaturalist.Fungal.ITS.detection.unequal.reads.sh](/teknonaturalist.Fungal.ITS.detection.unequal.reads.sh) <br><br>

Finally, run the appropriate bash script for fungal detection.<br><br>

# IV. Fungal classification using DNAbarcoder
Once one or more specimens have been run, they can be grouped and classified with [DNAbarcoder](/https://github.com/vuthuyduong/dnabarcoder) using custom fungal ITS databases. <br> 
Alternatively, the [Fungal.ITS.classifier.sh](/Fungal.ITS.classifier.sh) file may be edited with a script editor and run directly in the Docker container or mamba/conda environment.<br><br>

For details on fungal ITS database construction, or to make modified databases, see [DNAbarcoder.prep.txt](/Custom.setup). 
<br><br>
Final note: We recommend that scientific discretion be used for fungal classifications made. Low confidence observations may be informative in certain contexts, though we advise that these be treated cautiously. You may consider imposing a confidence threshold (e.g., >0.70), and even secondary classification techniques (e.g., BLAST) may be conducted and used for comparison.
### That's it!
<br><br>

#### A note on logs output: 
Log files for most steps are stored in the data/logs output, with the exception of megahit (data/meta/{srr}). For the remaining programs without logfile parameters, the stdout and stderr may be piped into a logfile by appending ' > data/logs/{srr}.log 2>&1 ' to the end of the Snakemake execution command, as follows:
```
snakemake --cores [CORES] --snakefile [SNAKEFILE] data/final/[SRR].ITS > data/logs/[SRR].log 2>&1
```
<br><br>

# A recap for experienced, repeat users:
__1.__ Paired end fastq files must be used - [Fastq.file.prep.txt](\0_Fastq_file_setup/Fastq.file.prep.txt)<br><br>
__2.__ Only the assembly and taxon-specific databases must be changed if you apply teknonaturalist to another host plant, assuming you keep the basic database setup intact. - [Prep_taxon_specific_assembly_and_databases.sh](\Setup_assembly_and_databases/Prep_taxon_specific_assembly_and_databases.sh) 
NOTE: The taxon-specific assemblies and databases, including the Betula examples, may be removed by the user to save space as long as directory structure is left intact.<br><br>
__3.__ Fungal detection may be run on input files (teknonaturalist/data/orig.fastqs/*.fastq) by editing Snakefiles and running Snakemake [Snakefile](/Snakefile) - or editing shell script files and running bash - [teknonaturalist.Fungal.ITS.detection.unequal.reads.sh](/teknonaturalist.Fungal.ITS.detection.unequal.reads.sh) OR [teknonaturalist.Fungal.ITS.detection.equal.reads.sh](/teknonaturalist.Fungal.ITS.detection.equal.reads.sh) <br><br>
__4.__ Fungal classification may be run on multiple files with DNAbarcoder - [Steps_for_Fungal.ITS.classifier.md](/4_Running_DNAbarcoder/Steps_for_Fungal.ITS.classifier.md) or by editing the shell script file and running bash - [Fungal.ITS.classifier.sh](/Fungal.ITS.classifier.sh)



# File Guide 
### Docker 
__[Dockerfile](/Docker/Dockerfile)__ <br>
This file creates an image that fully sets up the teknonaturalist directory and file structure, installs all programs, and successfully runs through a demo of teknonaturalist and DNAbarcoder using mini input files ([SRRdemo_1.fastq](/Docker/SRRdemo_1.fastq) and [SRRdemo_2.fastq](/Docker/SRRdemo_2.fastq)) and a [demoSnakefile](/Docker/demoSnakefile). <br><br>
### One time setup files: Installation of Snakemake, teknonaturalist, DNAbarcoder (must be run once before initial use)
__[Snakemake Setup](/1_Basic_setup_and_install/teknonaturalist_setup.md)__ 
<br> This file contains key information for installing required software, including Mamba/Conda and Snakemake.<br>
__[teknonaturalist Setup](/1_Basic_setup_and_install/teknonaturalist_setup.md)__ 
<br> This file contains key information for creating and activation of the __teknonaturalist__ environment. It also includes information for running teknonaturalist without Snakemake.<br>
__[Extract Teknonaturalist Databases](/extract_teknonaturalist_databases.py)__ <br>
A python script to extract all databases and assemblies provided at https://osf.io/8g6we/ <br>
__[environment.yaml](/environment.yaml)__ <br>
This file is required for setting up the teknonaturalist environment along with required programs used. It does not need to be run, simply present in the teknonaturalist/ directory during environment activation. <br>
__[MANUAL_package_install_for_bash_script.txt](/1_Basic_setup_and_install/MANUAL_package_install_for_bash_script.txt)__ 
<br> This file provides an alternative method for setting up the packages need to run teknonaturalist.<br>
__[Extract ITS.refs Database for DNAbarcoder](extract_ITS.refs_database_for_dnabarcoder.py)__ <br>
A python script to extract ITS reference database for DNAbarcoder (available at https://osf.io/8g6we/) <br><br>
### Setup files for running a new plant taxon 
__[Prep Taxon Specific Assembly and Databases](/2_Setup_assembly_and_databases/Prep_taxon_specific_assembly_and_databases.sh)__ (must be run for each new plant taxon assesed with __teknonaturalist__; the PlanITS database only needs to be setup once for each genus.) </details> <br><br>
### Executing teknonaturalist 
__[Fastq.gz file prep](/0_Fastq_file_setup/Fastq.file.prep.txt)__ <br>
Instructions for obtaining and formatting input fastq.gz files are provided here. <br>
__[Check Before Running teknonaturalist](check_before_running_teknonaturalist.py)__ <br>
 A python script to be used prior to executing __teknonaturalist__ that checks for input files, non-empty assembly and database directories, and an activated teknonaturalist environment.<br>
__[Running_teknonaturalist_with_Snakemake_Overview](/3_Running_teknonaturalist/Running_teknonaturalist_with_Snakemake_Overview.txt)__ <br>
This file provides a brief guide and directions to run the fungal ITS detection process with __teknonaturalist__ using Snakemake. <br>
__[Snakefile](/Snakefile)__ <br>
This file will may be edited to execute the fungal ITS detection process using Snakemake.<br>
__[Running_teknonaturalist_with_bash.txt](/3_Running_teknonaturalist/Running_teknonaturalist_with_bash.txt)__ <br>
This file provides a brief set of directions to run the fungal ITS detection process with __teknonaturalist__ using bash scripts. <br>
__[teknonaturalist.Fungal.ITS.detection.unequal.reads.sh](/teknonaturalist.Fungal.ITS.detection.unequal.reads.sh)__ and __[teknonaturalist.Fungal.ITS.detection.equal.reads.sh](/teknonaturalist.Fungal.ITS.detection.equal.reads.sh)__ <br>
These files  may be edited to execute the fungal ITS detection process using bash. <br><br>
### Executing DNAbarcoder: fungal taxonomic classification
__[Fungal ITS Classifier bash Script](/Fungal.ITS.classifier.sh)__ and __[Steps_for_Fungal ITS Classifier.md](/4_Running_DNAbarcoder/Steps_for_Fungal_ITS_Classifier.md)__ <br>
A file to pool sequences from different outputs and classify fungal taxa in a dataset of plant genomes after the fungal ITS detection process. <br><br>
### Advanced: Database modification 
__[Manual Prep of non-Taxon Specific Databases](/Custom.setup/Manual_prep_of_non_taxon_specific_databases.txt)__ <br>
This file explains how the databases were built. The file may be modified to create customized databases different from those provided at https://osf.io/8g6we/ <br>
__[DNAbarcoder Setup](/setup_resources/DNAbarcoder.setup.txt)__ <br>
This file explains how fungal ITS databases for fungal classification with DNAbarcoder were built. The file may be modified to create customized databases. DNAbarcoder must be installed in the __teknonaturalist__ directory (teknonaturalist/dnabarcoder/) prior to using classification scripts. <br><br>

## Additional information not in repository 

[Analyze Flanking 5.8S and ITS Sequences]([/R_scripts/analyze.5.8S.R](https://github.com/nicholasbard/tekno-manuscript-analysis/blob/main/analyze.5.8S.R)) <br>
An example R script (from the teknonaturalist paper) to identify classified fungal sequences with flanking sequence support at class taxonomic rank. <br>

[Example database and assembly files for reference/use](https://osf.io/8g6we/) is divided into "non-taxon-specific", which may be used for any plant taxon; and "taxon-specific", which provides an example for directory structure. 
		
  		1. General:
			a. fungi.tar.gz 
			b. uchime_datasets.tar.gz
			c. univec.tar.gz
  		2. Betula:
			a. genbank.tar.gz (needed for each plant species)
			b. PLANiITS.tar.gz (needed for each plant genus)
			c. assembly.tar.gz (assembly of the same plant species , or a closely related congener)
   		3. ITS.refs.tar.gz - Example fungal ITS reference for use with DNAbarcoder

#### R scripts for creating supplemental files and figures for our teknonaturalist paper may be found at our [tekno-manuscript-analysis github repo](https://github.com/nicholasbard/tekno-manuscript-analysis)

#### [raw data](https://osf.io/8g6we/) from our paper is also available.
Produced following fungal detection and classification in plant genomes available at https://osf.io/8g6we/. <br>

Dedicated to [Colin Richard Ferguson Ward](https://killdby.bandcamp.com)
