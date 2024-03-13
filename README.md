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

To run __teknonaturalist__, open the setup and execution files, edit the header lines as needed, and save and run the scripts. Files contain annotations with important information to guide the user. We suggest that line-by-line command running of shell script and txt files may be particularly useful, particularly for new users and for troubleshooting. <br>
<br>

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

__[Prep Taxon Specific Assembly and Databases](/setup_resources/Prep_taxon_specific_assembly_and_databases.txt) and [bash script](/Prep_taxon_specific_assembly_and_databases.sh)__ (must be run for _each new plant taxon assesed_ with __teknonaturalist__; the PlanITS database only needs to be setup once for each taxon.) <br>
This file is recommended for first-time users to be run line-by-line, but is also available as a [bash script]. <br><br>

__[Extract Teknonaturalist Databases](extract_teknonaturalist_databases.py)__ <br>
A python script to extract all databases and assemblies provided at https://osf.io/8g6we/ <br><br>
			
__[Extract ITS.refs Database for DNAbarcoder](extract_ITS.refs_database_for_dnabarcoder.py)__ <br>
A python script to extract ITS reference database for DNAbarcoder (available at https://osf.io/8g6we/)<br><br>

This image shows the basic directory structure in order to run teknonaturalist for fungal detection. Note that teknonaturalist/dnabarcoder must be present for fungal classification. <br>
![Snakemake directory structure](/setup_resources/snakemake_directory_structure.png)<br>

Executing teknonaturalist: Preparing for fungal ITS detection
============================================================

Almost ready! Before running __teknonaturalist__, make sure that the teknonaturalist Snakemake environment is activated:<br><br>
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

snakemake --cores {CORE NUMBER} --snakefile {Snakefile name} {Output file}<br><br>

Dry runs are quite helpful to run to identify potential problems. To dry run, add '-np':<br><br>
snakemake -np --cores {CORE NUMBER} --snakefile {Snakefile name} {Output file}<br><br>

__Example commands For teknonaturalist (easiest way)__ <br>

Using equal PE read fastq files:<br>
snakemake --cores {CORE NUMBER} --snakefile Snakefile_equal_reads data/final/{SRRnumber}.ITSx<br><br>
Using unequal PE read fastq files:<br>
snakemake --cores {CORE NUMBER} --snakefile Snakefile_unequal_reads data/final/{SRRnumber}.ITSx<br><br>
EXAMPLE (single fastq files):<br>
snakemake --cores 4 --snakefile Snakefile_equal_reads data/final/ERR2026266.ITSx<br><br>
EXAMPLE (multiple fastq files):<br>
snakemake --cores 20 --snakefile Snakefile_equal_reads data/final/{ERR2026264,ERR2026266}.ITSx <br><br>

__(if using command line)__ <br>
We also provide bash scripts to run the pipeline.<br><br>
See __[teknonaturalist Fungal ITS Detection Equal Reads](/teknonaturalist.Fungal.ITS.detection.equal.reads.sh)__ and __[teknonaturalist Fungal ITS Detection Unequal Reads](/teknonaturalist.Fungal.ITS.detection.unequal.reads.sh)__ <br>
The teknonaturalist execution bash script [non-Snakemake] script for PE fastq.gz files with equal read count sand unequal read counts, respectively.

Executing DNAbarcoder: fungal taxonomic classification
============================================================

Following fungal ITS detection of a dataset (one to many samples), DNAbarcoder (Vu et al., 2022) may be employed for taxonomic classification.

__[Fungal ITS Classifier bash Script](/Fungal.ITS.classifier.sh)__ (and __[Fungal ITS Classifier text file](/Fungal.ITS.classifier.txt)__ <br>
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

__[R Genus Heatmap](/R_scripts.create.Betula.genus.heatmap.w.supp.files.R)__ <br>
A script used for creating the supplemental files and figure used in the Betula example paper.

Empty __assembly, database, data/orig.fastqs, and data/finalcombined__ directories as placeholders. <br>
If database and assembly .tar.gz files are installed into teknonaturalist directory and extracted 
using the "extract" scripts, the directories will assemble with the proper subdirectories. 

__[Betula data](https://osf.io/8g6we/)__ from example paper. <br> 
Produced following fungal detection and classification in plant genomes available at https://osf.io/8g6we/.

Technical References
============================================================

Abarenkov K, Nilsson RH, Larsson K-H, Taylor AFS, May TW, Frøslev TG, Pawlowska J, Lindahl B, Põldmaa K, Truong C, Vu D, Hosoya T, Niskanen T, Piirmann T, Ivanov F, Zirk A, Peterson M, Cheeke TE, Ishigami Y, Jansson AT, Jeppesen TS, Kristiansson E, Mikryukov V, Miller JT, Oono R, Ossandon FJ, Paupério J, Saar I, Schigel D, Suija A, Tedersoo L, Kõljalg U. 2023. The UNITE database for molecular identification and taxonomic communication of fungi and other eukaryotes: sequences, taxa and classifications reconsidered. Nucleic Acids Research, https://doi.org/10.1093/nar/gkad1039

Andrews, S. (2010). FastQC: a quality-control tool for high-throughput sequence data. [Computer software]. http://www.bioinformatics.babraham.ac.uk/projects/fastqc/ 

Bengtsson-Palme, J., Ryberg, M., Hartmann, M., Branco, S., Wang, Z., Godhe, A., De Wit, P., Sánchez-García, M., Ebersberger, I., de Sousa, F., Amend, A., Jumpponen, A., Unterseher, M., Kristiansson, E., Abarenkov, K., Bertrand, Y. J. K., Sanli, K., Eriksson, K. M., Vik, U., … Nilsson, R. H. (2013). Improved software detection and extraction of ITS1 and ITS2 from ribosomal ITS sequences of fungi and other eukaryotes for analysis of environmental sequencing data. Methods in Ecology and Evolution, 4(10), 914–919. https://doi.org/10.1111/2041-210X.12073

Banchi, E., Ametrano, C. G., Greco, S., Stanković, D., Muggia, L., & Pallavicini, A. (2020). PLANiTS: A curated sequence reference dataset for plant ITS DNA metabarcoding. Database, 2020, baz155. https://doi.org/10.1093/database/baz155 

Benson DA, Cavanaugh M, Clark K, Karsch-Mizrachi I, Lipman DJ, Ostell J, Sayers EW. GenBank. Nucleic Acids Res. 2013 Jan;41(Database issue):D36-42. doi: 10.1093/nar/gks1195. Epub 2012 Nov 27. PMID: 23193287; PMCID: PMC3531190.

Clausen, P. T. L. C., Aarestrup, F. M., & Lund, O. (2018). Rapid and precise alignment of raw reads against redundant databases with KMA. BMC Bioinformatics, 19(1), 307. https://doi.org/10.1186/s12859-018-2336-6

Heeger, F., Wurzbacher, C., Bourne, E. C., Mazzoni, C. J., & Monaghan, M. T. (2019). Combining the 5.8S and ITS2 to improve classification of fungi. Methods in Ecology and Evolution, 10(10), 1702–1711. https://doi.org/10.1111/2041-210X.13266

Li, D., Liu, C. M., Luo, R., Sadakane, K., & Lam, T. W. (2015). MEGAHIT: An ultra-fast single-node solution for large and complex metagenomics assembly via succinct de Bruijn graph. Bioinformatics, 31(10), 1674–1676. https://doi.org/10.1093/bioinformatics/btv033

Li, H., & Durbin, R. (2009). Fast and accurate short read alignment with Burrows-Wheeler transform. Bioinformatics, 25(14), 1754–1760. https://doi.org/10.1093/bioinformatics/btp324

Li, Heng. (2018). seqtk: Toolkit for processing sequences in FASTA/Q formats (1.3 r106) [Computer software]. https://github.com/lh3/seqtk

Lu, J., Rincon, N., Wood, D. E., Breitwieser, F. P., Pockrandt, C., Langmead, B., Salzberg, S. L., & Steinegger, M. (2022). Metagenome analysis using the Kraken software suite. Nature Protocols, 17(12), 2815–2839. https://doi.org/10.1038/s41596-022-00738-y

Martin, M. (2011). Cutadapt removes adapter sequences from high-throughput sequencing reads. EMBnet.Journal, 17, 10–12.

Mölder, F., Jablonski, K. P., Letcher, B., Hall, M. B., Tomkins-Tinch, C. H., Sochat, V., Forster, J., Lee, S., Twardziok, S. O., Kanitz, A., & others. (2021). Sustainable data analysis with Snakemake. F1000Research, 10.

NCBI. (1988). National Center of Biotechnology Information. National Library of Medicine (US), National Center for Biotechnology Information. https://www.ncbi.nlm.nih.gov/

Nilsson, R. H., Larsson, K.-H., Taylor, A. F. S., Bengtsson-Palme, J., Jeppesen, T. S., Schigel, D., Kennedy, P., Picard, K., Glöckner, F. O., Tedersoo, L., Saar, I., Kõljalg, U., & Abarenkov, K. (2019). The UNITE database for molecular identification of fungi: Handling dark taxa and parallel taxonomic classifications. Nucleic Acids Research, 47(D1), D259–D264. https://doi.org/10.1093/nar/gky1022

Rognes, T., Flouri, T., Nichols, B., Quince, C., & Mahé, F. (2016). VSEARCH: A versatile open source tool for metagenomics. PeerJ, 2016(10), 1–22. https://doi.org/10.7717/peerj.2584

Schubert, M., Lindgreen, S., & Orlando, L. (2016). AdapterRemoval v2: Rapid adapter trimming, identification, and read merging. BMC Research Notes, 9(1), 1–7. https://doi.org/10.1186/s13104-016-1900-2

Shen, W., Le, S., Li, Y., & Hu, F. (2016). SeqKit: A cross-platform and ultrafast toolkit for FASTA/Q file manipulation. PLOS ONE, 11(10), e0163962. https://doi.org/10.1371/journal.pone.0163962

Vu, D., Nilsson, R. H., & Verkley, G. J. M. (2022). Dnabarcoder: An open‐source software package for analysing and predicting DNA sequence similarity cutoffs for fungal sequence identification. Molecular Ecology Resources, 22(7), 2793–2809. https://doi.org/10.1111/1755-0998.13651

Wood, D. E., Lu, J., & Langmead, B. (2019). Improved metagenomic analysis with Kraken 2. Genome Biology, 20(1), 257. https://doi.org/10.1186/s13059-019-1891-0

Wood, D. E., & Salzberg, S. L. (2014). Kraken: Ultrafast metagenomic sequence classification using exact alignments. Genome Biology, 15(3), R46. https://doi.org/10.1186/gb-2014-15-3-r46

Dedicated to Colin Richard Ferguson Ward 
