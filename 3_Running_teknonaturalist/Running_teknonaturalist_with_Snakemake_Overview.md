# A quick guide to fungal detection with teknonaturalist for Snakemake - Overview
Also See: https://snakemake.readthedocs.io/en/stable/

### This is a brief overview of the steps to run Snakemake for the teknonaturalist pipeline, once setup has been completed. 
#### Note that all Snakemake setup, teknonaturalist environment creation, and database and assembly setup must be complete, and requisite files must be in the working directory. (see README and setup_resources)

Also note that Snakemake is likely to trigger an alarm for ITSx upon completion. This error message may be ignored. It will read like this: <br>
```
MissingOutputException in rule itsx in file $PATH/snakemake.fungi.pipeline/Snakefile.unequal.read, line 307:
Job 0 completed successfully, but some output files are missing. Missing files after 5 seconds. This might be due to filesystem latency. If that is the case, consider to increase the wait time with --latency-### wait:
data/final/ERR2026254.ITSx
Shutting down, this might take some time.
Exiting because a job execution failed. Look above for error message
```

### Snakemake must be installed, the teknonaturalist environment must be created, and the databases prior to running Snakemake. Directions and resources are provided in the README.file and setup_resources directory.  
Once all setup is complete...

1. Before running Snakemake, extract PE reads into teknonaturalist/data/orig.fastqs. Make sure they are gzipped (fastq.gz extension). A guide is provided in the Fastq.file.prep.txt file

2. Navigate to the teknonaturalist working directory.
```
cd $PATH/teknonaturalist
```

3. Activate conda or mamba environment (see teknonaturalist_Basic_Setup.txt and README for instructions on Conda/Mamba environments and Snakemake):
```
conda activate teknonaturalist
#or
mamba activate teknonaturalist
```

4. Ensure that the 1. environment.yaml , 2. Snakefile file (can be re-titled) 3. 'data' directory are in the working directory and 4. teknonaturalist/database and teknonaturalist/assembly directories are setup correctly (see README.md). This can be checked with the provided python script 'check_before_running_teknonaturalist.py' and cross-checked with the 'snakemake_directory_structure.png' file.
```
#If needed,
mv Snakefile $PATH/teknonaturalist
mv *.fastq $PATH/teknonaturalist
mv environment.yaml $PATH/teknonaturalist
```

5. Edit the parameters in the Snakefile header to execute teknonaturalist. Advanced parameter editing may be edited in the following command lines, per the instructions for the corresponding software. Note: editing directory locations or file name formats is not advised.

6. Snakemake may be executed on 2-3 input fastq files ('teknonaturalist/data/orig.fastqs') for each SRA accession (e.g., ERR2026266_1.fastq, ERR2026266_2.fastq, and, if using unequal PE reads, ERR2026266.fastq). Snakemake may be called easily from the command line.

7. Generally, the following command can be used to run Snakemake. Note that Snakemake checks the OUTPUT file and works backwards to find the first file in the sequence that is present to initiate (may be helpful for troubleshooting):
```
snakemake --cores {CORE NUMBER} --snakefile {Snakefile name} {Output file}
```

Dry runs are quite helpful to run to identify potential problems. To dry run, add '-np':
```
snakemake -np --cores {CORE NUMBER} --snakefile {Snakefile name} {Output file}
```

#### Example commands For teknonaturalist (easiest way) <br>

EXAMPLE: (single fastq files)
```
snakemake --cores 4 --snakefile Snakefile data/final/ERR2026266.ITSx
```
EXAMPLE: (multiple fastq files)
```
snakemake --cores 20 --snakefile Snakefile data/final/{ERR2026264,ERR2026266}.ITSx
```

8. Once fungal detection has finished, fungal classification may be executed using DNAbarcoder (Vu et al 2022). We have provided classification scripts that pool all samples in a dataset with a unique filename prefix (e.g., SRR92) and classify them as a batch ("Fungal.ITS.classifier") which may be run from the command line. The provided classification scripts format output data that is easily readable into R. Prior to using, verify 'teknonaturalist/dnabarcoder' directory exists with all necessary scripts from the Github (https://github.com/vuthuyduong/dnabarcoder). Prior to using, verify that teknonaturalist/dnabarcoder/ITS.refs directory with configured databases. 

9. R may be used to identify contigs that have flanking support at the class taxonomic rank. We have provided an [example using Betula data](https://github.com/nicholasbard/tekno-manuscript-analysis/blob/main/analyze.5.8S.R), which may be edited as needed.
