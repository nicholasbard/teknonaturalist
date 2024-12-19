## ~ Preparation of congener assembly and the PLANiTS and genbank databases (the "taxon-specific" databases) for the teknonaturalist fungi detection pipeline

## This file may be run as a bash script to prepare databases and an assembly specific to the focal plant taxon of the study by modifying the 'Variables' section below. 
## It is intended to run in the teknonaturalist/ directory.

##################
## Dependencies ##
##################
# seqtk, bwa, and ncbi-genome-download. Available if teknonaturalist environment is activated, or may be manually downloaded if necessary.

#########################
### FIRST-TIME USERS: ###
#########################
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

##############################################
####### Variables (to be edited) ########
##############################################
# ~#~#~#~# All steps must be completed prior to applying pipeline to each new plant species, or you may use pre-made assembly directories and unzip (for Betula nana and Betula pendula).(Contents inside "" must be replaced.):
#  #~#~#~#~#

### Replace <text> below. e.g., genus="Betula" .

genus="<enter here>"
cong="<enter full species name of congener species here, separated by dot, (e.g., Betula.nana)>"
congnodot="<enter full species name of congener species here, separated by space, (e.g., Betula nana)>"
focal="<enter full species name of focal species here, separated by dot, (e.g., Betula.ermanii)>"
focalnodot="<enter full species name of focal species here, separated by space, (e.g., Betula ermanii)>"


##########~~~~~~~~ I. Setup directions, to be used for all focal species with the same genus ~~~~~~~#########

##### Important! Ensure the current directory is teknonaturalist/
## The following command will ensure that this can be run from the 2_Setup_assembly_and_databases directory. Comment out if necessary.
mv ../

#~~~~~~~~ Build PLANits databases for the genus, index, and prepare reference files ~~~~~~~#

#### Get genus-specific data PLANiTS

#  For initial setup (make directory teknonaturalist/database/PLANiTS if needed):

# This information is available at https://github.com/apallavicini with: 
# git clone https://github.com/apallavicini/PLANiTS.git
# Unzip.
# unzip teknonaturalist/database/PLANiTS/PLANiTS_<DD-MM-YYYY>.zip



# Subset database to only ITS regions. Note: do not edit {print $1} terms.

grep "${genus}" database/PLANiTS/ITS_taxonomy | awk -F ' ' '{print $1}' > database/PLANiTS/${genus}.ITS
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
esearch -db nuccore -query '"${focalnodot}"[Organism] OR ${focalnodot}[All Fields] AND "${focalnodot}"[porgn] AND ddbj_embl_genbank[filter] AND is_nuccore[filter]' | efetch -format fasta > database/genbank/${focal}.Genbank.nucl.fasta

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
bwa index -p assembly/${cong}.assembly/${cong}.bwa.index assembly/${cong}.assembly/genbank/plant/${ac}/*.fna


