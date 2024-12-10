# Use miniforge base to access mamba
FROM condaforge/miniforge3

ENV MAMBA_ROOT_PREFIX=/home/mamba

# Set the working directory
WORKDIR /app

# Copy files from this directory into image
COPY . .

# Setup snakemake into base mamba environment.
RUN mamba install --yes --name base -c bioconda -c conda-forge \
      snakemake-minimal >=7.3 \
      snakemake \
      osfclient 

RUN mamba clean --all --yes

### 
# Automatic setup of test databases and assembly from teknonaturalist OSF repository: https://osf.io/8g6we/
###

# Download databases to run teknonaturalist
RUN osf -p j57fs clone .

# Download sample species (Betula nana) assembly to run teknonaturalist with sample file
RUN osf -p vnh3b clone .

# Download premade ITS and 5.8S sequences for use with DNAbarcoder
RUN osf -p 38uk2 clone .

# Fix directory structure.
RUN mv osfstorage/* .
RUN rm -r osfstorage
###


### 
# Resume teknonaturalist setup.
###

# Create teknonaturalist environment installing packages specified in environment.yaml
RUN mamba env create --name teknonaturalist --file environment.yaml

# Make all directories.
RUN mkdir data
RUN mkdir data/orig.fastqs
RUN mkdir data/finalcombined
RUN mkdir assembly
RUN mkdir assembly/Betula.nana.assembly
RUN mkdir database
RUN mkdir database/univec
RUN mkdir database/uchime_datasets
RUN mkdir database/genbank
RUN mkdir database/fungi
RUN mkdir database/PLANiTS

# Copy files into directory for run.
RUN mv *RR*fastq data/orig.fastqs/

# Get DNAbarcoder
RUN git clone https://github.com/vuthuyduong/dnabarcoder.git

# Setup directory for ITS sequences used by DNAbarcoder.
RUN mkdir dnabarcoder/ITS.refs

#Initiate bash
RUN mamba init bash

#Activate teknonaturalist environment.
RUN echo "mamba activate teknonaturalist" >> ~/.bashrc

# Ensure teknonaturalist environment when image is run.
SHELL ["mamba", "run", "-n", "teknonaturalist", "/bin/bash", "-c"]
