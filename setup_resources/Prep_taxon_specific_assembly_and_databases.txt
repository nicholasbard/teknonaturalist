## ~ Preparation of congener assembly and the PLANiTS and genbank databases (the "taxon-specific" databases) for the teknonaturalist fungi detection pipeline:
## This file provides a bash script to prepare databases and an assembly specific to the focal plant taxon of the study. 
## Fill out the variable editing section below to run all at once.
## This script should be run in the teknonaturalist/ directory.

### FIRST-TIME USERS:
### It is advised to go through these steps line by line the first time, rather than as a full bash script.
## To do this, simply run through the script, line-by-line, and replace ${text} with (e.g. ${congnodot}) with the variable of interest (e.g., Betula nana).
## Examples of these for the Betula genus and species assessed in the example paper are provided as tar.gz files provided at https://osf.io/8g6we/ and can be extracted using 'extract_teknonaturalist_databases.py'. 
## We advise first-time users to extract these example databases and assemblies when getting started with Snakemake and teknonaturalist. 
## To manually prepare plant "non-taxon-specific" databases, use the directions provided in Manual_prep_of_non_taxon_specific_databases.txt.
# Note: The fasta file of the congener used for the assembly may also be downloaded from the NCBI website manually if ncbi-genome-download fails.

#### Notes on the assembly and databases produced.
## The assembly prepared should be the evolutionarily closest congener with an available full reference assembly (the focal species, or a closely related species).
## The PLANits database is genus specific (e.g., Betula), and includes all available ITS sequences in the genus.
## The genbank database is species-specific (e.g., Betula ermanii) and includes all available sequences found in NCBI Genbank (https://www.ncbi.nlm.nih.gov/genbank/) (Benson et al. 2012).

#!/bin/bash
#Use bash shell.

#~#~#~#~# Setup of assembly and databases requires installation of seqtk, bwa, and ncbi-genome-downloads programs #~#~#~#~#

## Option 1 (recommended): Activate 'teknonaturalist' to use tools for database and assembly creation:
# conda activate teknonaturalist
#OR
# mamba activate teknonaturalist

## Option 2: Install programs outside of 'teknonaturalist' environment (i.e., do not activate for installation). See: https://github.com/lh3/seqtk

## Conda/Mamba installation (conda may be replaced with mamba for the next 3 lines):
# conda install -c bioconda seqtk
# conda install -c bioconda bwa
# conda install -c bioconda ncbi-genome-download

######### USER Variable editing section (Contents inside "" must be replaced.):
#~#~#~#~# All steps must be completed prior to applying pipeline to each new plant species, or you may use pre-made assembly directories and unzip (for Betula nana and Betula pendula).  #~#~#~#~#

### Replace <text> below. e.g., genus="Betula" .

genus="<enter here>"
cong="<enter full species name of congener species here, separated by dot, (e.g., Betula.nana)>"
congnodot="<enter full species name of congener species here, separated by space, (e.g., Betula nana)>"
focal="<enter full species name of focal species here, separated by dot, (e.g., Betula.ermanii)>"
focalnodot="<enter full species name of focal species here, separated by space, (e.g., Betula ermanii)>"


##########~~~~~~~~ I. Setup directions, to be used for all focal species with the same genus ~~~~~~~#########
#~~~~~~~~ Build PLANits databases for the genus, index, and prepare reference files ~~~~~~~#

#### Get genus-specific data PLANiTS

#  For initial setup (make directory teknonaturalist/database/PLANiTS if needed):

# This nformation is available at https://github.com/apallavicini with: 
# git clone https://github.com/apallavicini/PLANiTS.git
# Unzip.
# unzip teknonaturalist/database/PLANiTS/PLANiTS_<DD-MM-YYYY>.zip

# Subset database to only ITS regions. Note: do not edit {print $1} terms.

## Important! Ensure the current directory is teknonaturalist/

grep "${genus}" database/PLANiTS/ITS_taxonomy | awk -F ' ' '{print $1}' > ${genus}.ITS
seqtk subseq database/PLANiTS/ITS.fasta database/PLANiTS/${genus}.ITS > database/PLANiTS/${genus}.ITS.fasta
grep "${genus}" database/PLANiTS/ITS1_taxonomy | awk -F ' ' '{print $1}' > database/PLANiTS/${genus}.ITS1
seqtk subseq database/PLANiTS/ITS1.fasta database/PLANiTS/${genus}.ITS1 > database/PLANiTS/${genus}.ITS1.fasta
grep "${genus}" database/PLANiTS/ITS2_taxonomy | awk -F ' ' '{print $1}' > database/PLANiTS/${genus}.ITS2
seqtk subseq database/PLANiTS/ITS2.fasta database/PLANiTS/${genus}.ITS2 > database/PLANiTS/${genus}.ITS2.fasta
cat database/PLANiTS/${genus}.ITS.fasta database/PLANiTS/${genus}.ITS1.fasta database/PLANiTS/${genus}.ITS2.fasta > database/PLANiTS/${genus}.fasta

# Make genus specific ITS database
makeblastdb -in database/PLANiTS/${genus}.fasta -dbtype nucl


##########~~~~~~~~ II. Setup directions, to be used for EVERY focal species ~~~~~~~#########
#~~~~~~~~ Build Genbank databases for the focal study species, index, and prepare reference files ~~~~~~~#

# a.
# Get genbank fasta data for focal species:

# With command line:
esearch -db nuccore -query "${focalnodot}"[Organism] OR ${focalnodot}[All Fields] AND "${focalnodot}"[porgn] AND ddbj_embl_genbank[filter] AND is_nuccore[filter] | efetch -format fasta > database/genbank/${focal}.Genbank.nucl.fasta

# or ON WEBSITE: 
# Search species at Genbank page, download all Genbank "nucleotide" entries on NCBI website, retitle as ${focal}.Genbank.nucl.fasta
# (example Betula ermanii search terms to paste into "Search details field: ("Betula ermanii"[Organism] OR Betula ermanii[All Fields] AND "Betula ermanii"[porgn] AND ddbj_embl_genbank[filter] AND is_nuccore[filter]) 


makeblastdb -in database/genbank/${focal}.Genbank.nucl.fasta -dbtype nucl

# b.
# Get reference assembly (fasta) of focal species or closely related congener. Index.
# Note: The fasta file may also be downloaded from NCBI manually if ncbi-genome-download fails.
ncbi-genome-download -s genbank --genera "${congnodot}" plant -o assembly/${cong}.assembly -F fasta

## For the following lines, the name of the assembly directory will be assigned to the "ac" variable (e.g., ac = "GCA_000327005.1"), and the assembly is unzipped. The full name of the ac variable may be used instead for the lines below. 
ac=$(ls assembly/${cong}.assembly/genbank/plant | head -1)
gunzip assembly/${cong}.assembly/genbank/plant/${ac}/*.gz

# Index reference assembly with bwa.
bwa index -p assembly/${cong}.assembly/${cong}.bwa.index ${cong}.assembly/genbank/plant/${ac}/*.fna


