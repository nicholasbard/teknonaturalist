teknonaturalist.README -- Assesses fungal bycatch in plant genomes
============================================================

###~~~### teknonaturalist is a pipeline for detection of fungal ITS sequences in plant genome files prepared using Next-Generation Sequencing with paired end reads.
## teknonaturalist is intended for use with Snakemake (Mölder et al., 2021), but may also be run using provided bash scripts. The program is suitable for Linux and Unix (Mac) machines equipped with Python.
## We provide an overview of setup and execution, in addition to instructions and resources for integrating teknonaturalist with DNAbarcoder (Vu et al., 2022) for fungal classification following fungal ITS detection.
## Additional resources include example R scripts for identifying classified genome sequences
## Data from the Betula example study, in addition to the databases and assembly files used, may be found at http://osf.io/8g6we/ and implemented by the user.

Source code available at:
https://github.com/nicholasbard/teknonaturalist

Version: 1.1.0
teknonaturalist -- Assesses fungal bycatch in plant genomes
Copyright (C) 2023 Nicholas Bard et al.
Contact: Nicholas Bard, nicholas.bard[at]botany.ubc.ca
Programmer: Nicholas Bard

============================================================

PROVIDED MATERIALS:
I. teknonaturalist setup files
	1. README.md (this file)
	2. teknonaturalist.setup.txt 
		(This file contains key information for installing required software, including Mamba/Conda and Snakemake, and activation of the teknonaturalist conda/mamba environment. It also includes information for running teknonaturalist without Snakemake.)
	3. Manual_prep_of_non_taxon_specific_databases.txt 
		(May be re-used for different plant taxa. Refer to this file if using customized databases different from those provided at https://osf.io/8g6we/ )
	4. Prep_taxon_specific_assembly_and_databases.txt 
		(Must be run for each new plant taxon assesed with teknonaturalist. This file is recommended for first-time users to be run line-by-line, but is also available as a bash script [.sh] in main directory)
	5. DNAbarcoder.setup.txt
		(This provides instructions for setting up DNAbarcoder for fungal classification, which should be a subdirectory within the main teknonaturalist directory [teknonaturalist/dnabarcoder/])
	6. Extras
		a. Fastq.file.prep.txt - instructions for obtaining ans formatting input fastq.gz files
		b. package_install_for_bash_script.txt - a list of programs and commands needed to manually install if not using Snakemake.
		c. extract_teknonaturalist_databases.py - a python script to extract all databases and assemblies provided at https://osf.io/8g6we/ 
		d. extract_teknonaturalist_databases.py - a python script to extract ITS reference databases for DNAbarcoder (available at same OSF page)
		e. check_before_running_teknonaturalist.py - a python script to be used before executing teknonaturalist that verifies input files, and that assembly and database directories are in their proper locations and not empty.
		f. empty assembly, database, data/orig.fastqs, and data/finalcombined directories as placeholders. If database and assembly .tar.gz files are installed into teknonaturalist directory and extracted using the "extract" scripts, the directories will assemble with the proper subdirectories.
		g. snakemake_firectory_structure.png - an image showing the minimal directory structure for running teknonaturalist. 
II. teknonaturalist execution files
	1. Running_teknonaturalist_with_Snakemake_Overview.txt
	 	(if using Snakemake)
	2. Fungal detection execution files
		a. environment.yaml (This is required for setting up the teknonaturalist Conda/Mamba environment, along with required programs used)
		b. Snakefile_equal_reads (The Snakemake execution file for PE fastq files with equal read counts)
		c. Snakefile_unequal_reads (The Snakemake execution file for PE fastq files with unequal read counts)
		d. teknonaturalist.Fungal.ITS.detection.equal.reads.sh (The teknonaturalist execution bash script[non-Snakemake]script for PE fastq.gz files with equal read counts)
		e. teknonaturalist.Fungal.ITS.detection.unequal.reads.sh (same as above; but unequal read counts)
	3. Fungal.ITS.classifier.sh (Fungal classification script that pools using DNAbarcoder [also available as .txt])
III. R scripts
	1. analyze.5.8S.R - a script for assessing which fungal classified sequences have flanking support to class taxonomic rank by flanking ITS or 5.8S sequences.
	2. create.Betula.genus.heatmap.w.supp.files.R - a script used for creating the supplemental files and figure used in the Betula example paper.
IV. Example database and assembly files for reference/use (available at https://osf.io/8g6we/). These are divided into "non-taxon-specific", which may be used for any plant taxon; and "taxon-specific", which are useful for an example with the Betula species used in the example paper. 
	1. General:
		a. fungi.tar.gz
		b. uchime_datasets.tar.gz
		c. univec.tar.gz
	2. Betula:
		a. genbank.tar.gz
		b. PLANiITS.tar.gz
		c. assembly.tar.gz
	3. ITS.refs.tar.gz - Example fungal ITS reference for use with DNAbarcoder 
V. Betula data from example paper, following fungal detection and classification in plant genomes available at https://osf.io/8g6we/).

IMPORTANT: Most files will require user edits for specific file names. Each file contains annotations with important information. 

============================================================

Setup teknonaturalist:
We suggest that line-by-line command running of shell script and txt files may be particularly useful, particularly for new users and for troubleshooting. 
The setup is geared toward Snakemake, however we provide manual program installation instructions (package_install_for_bash_script.txt).
See teknonaturalist_setup.txt.
============================================================

Setup DNAbarcoder:
DNAbarcoder must be installed in the teknonaturalist directory (teknonaturalist/dnabarcoder/) prior to using classification scripts 
See DNAbarcoder.setup.txt.
============================================================

Setup assemblies and databases
We suggest that line-by-line command running of shell script and txt files may be particularly useful, particularly for new users and for troubleshooting. 
See Manual_prep_of_non_taxon_specific_databases.txt and Prep_taxon_specific_assembly_and_databases.txt

The setup is geared toward Snakemake, however we provide manual program installation instructions (See package_install_for_bash_script.txt).
============================================================

Running teknonaturalist for fungal ITS detection: 
The intended way to run teknonaturalist is using Snakemake.
See Snakefile_equal_reads and Snakefile_unequal_reads for Snakefiles, in addition to environment.yaml.

We also provide bash scripts to run the pipeline.
See teknonaturalist.Fungal.ITS.detection.equal.reads.sh teknonaturalist.Fungal.ITS.detection.unequal.reads.sh 
============================================================

Running DNAbarcoder for fungal taxonomic classification:
We provide bash scripts to classify fungal taxa following fungal ITS detection using DNAbarcoder (Vu et al., 2022).
Fungal.ITS.classifier.sh (and .txt)
============================================================

R script for determining flanking sequence support for classified fungal sequences :
See analyze.5.8S.R
============================================================

### Technical References
Abarenkov K, Nilsson RH, Larsson K-H, Taylor AFS, May TW, Frøslev TG, Pawlowska J, Lindahl B, Põldmaa K, Truong C, Vu D, Hosoya T, Niskanen T, Piirmann T, Ivanov F, Zirk A, Peterson M, Cheeke TE, Ishigami Y, Jansson AT, Jeppesen TS, Kristiansson E, Mikryukov V, Miller JT, Oono R, Ossandon FJ, Paupério J, Saar I, Schigel D, Suija A, Tedersoo L, Kõljalg U. 2023. The UNITE database for molecular identification and taxonomic communication of fungi and other eukaryotes: sequences, taxa and classifications reconsidered. Nucleic Acids Research, https://doi.org/10.1093/nar/gkad1039

Bengtsson-Palme, J., Ryberg, M., Hartmann, M., Branco, S., Wang, Z., Godhe, A., De Wit, P., Sánchez-García, M., Ebersberger, I., de Sousa, F., Amend, A., Jumpponen, A., Unterseher, M., Kristiansson, E., Abarenkov, K., Bertrand, Y. J. K., Sanli, K., Eriksson, K. M., Vik, U., … Nilsson, R. H. (2013). Improved software detection and extraction of ITS1 and ITS2 from ribosomal ITS sequences of fungi and other eukaryotes for analysis of environmental sequencing data. Methods in Ecology and Evolution, 4(10), 914–919. https://doi.org/10.1111/2041-210X.12073

Benson DA, Cavanaugh M, Clark K, Karsch-Mizrachi I, Lipman DJ, Ostell J, Sayers EW. GenBank. Nucleic Acids Res. 2013 Jan;41(Database issue):D36-42. doi: 10.1093/nar/gks1195. Epub 2012 Nov 27. PMID: 23193287; PMCID: PMC3531190.

Mölder, F., Jablonski, K. P., Letcher, B., Hall, M. B., Tomkins-Tinch, C. H., Sochat, V., Forster, J., Lee, S., Twardziok, S. O., Kanitz, A., & others. (2021). Sustainable data analysis with Snakemake. F1000Research, 10.

Vu, D., Nilsson, R. H., & Verkley, G. J. M. (2022). Dnabarcoder: An open‐source software package for analysing and predicting DNA sequence similarity cutoffs for fungal sequence identification. Molecular Ecology Resources, 22(7), 2793–2809. https://doi.org/10.1111/1755-0998.13651