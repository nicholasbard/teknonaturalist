# General code for classifying fungi with DNAbarcoder (Vu et al 2022).
# Nick Bard 2023

###### To be used if running this as bash script (not line by line).
#!/bin/bash
# Use bash shell.

### This must be run in the teknonaturalist directory, which can be set as $PATH or navigated to if $PATH variable not set:
# cd $PATH/teknonaturalist
# Make sure that dnabarcoder directory with prepared database is in teknonaturalist/ (teknonaturalist/dnabarcoder/)
# Remain in teknonaturalist/ directory to run this script.

### HEADER LINES INSTRUCTIONS.
### Remove <> in HEADER lines and replace text within quotes. For instance, SRR="ermanii"
SRR="<common prefix for accession number, e.g., SRR92>"
SAMPLE="<specific epithet, e.g., ermanii>"

### CODE:
# Combine all individual samples in a dataset and reformat so readable by DNAbarcoder.
grep "" data/final/${SRR}*.ITSx.ITS1.full_and_partial.fasta | awk 'NR % 2 == 0 {sub(/.*:/, "", $0)} 1' | sed "s/.*\(${SRR}\)/>\1/" | sed 's/\..*>/,/' > data/finalcombined/${SAMPLE}.ITS1.full.partial.all
grep "" data/final/${SRR}*.ITSx.ITS2.full_and_partial.fasta | awk 'NR % 2 == 0 {sub(/.*:/, "", $0)} 1' | sed "s/.*\(${SRR}\)/>\1/" | sed 's/\..*>/,/' > data/finalcombined/${SAMPLE}.ITS2.full.partial.all
grep "" data/final/${SRR}*.ITSx.5_8S.full_and_partial.fasta | awk 'NR % 2 == 0 {sub(/.*:/, "", $0)} 1' | sed "s/.*\(${SRR}\)/>\1/" | sed 's/\..*>/,/' > data/finalcombined/${SAMPLE}.5_8S.full.partial.all

# filter 5.8S to minimum length 100.
vsearch --fastx_filter data/finalcombined/${SAMPLE}.5_8S.full.partial.all --fastq_minlen 100 --fastaout data/finalcombined/${SAMPLE}.5_8S.100.full.partial.all

# search Genus ITS1/ITS2/5.8S sequences.
###### USER: Replace {SAMPLE} with name or other identier, e.g., ermanii.
python3.9 dnabarcoder/dnabarcoder.py search -i data/finalcombined/${SAMPLE}.ITS1.full.partial.all -r dnabarcoder/ITS.refs/ITS1.f.ref -ml 50 -p ../data/finalcombined/${SAMPLE}
python3.9 dnabarcoder/dnabarcoder.py search -i data/finalcombined/${SAMPLE}.ITS2.full.partial.all -r dnabarcoder/ITS.refs/ITS2.f.ref -ml 50 -p ../data/finalcombined/${SAMPLE}
python3.9 dnabarcoder/dnabarcoder.py search -i data/finalcombined/${SAMPLE}.5_8S.100.full.partial.all -r dnabarcoder/ITS.refs/5.8S.f.ref -ml 50 -p ../data/finalcombined/${SAMPLE}

# conduct local best match search with classify
python3.9 dnabarcoder/dnabarcoder.py classify -i data/finalcombined/${SAMPLE}.ITS1.f_BLAST.bestmatch -r dnabarcoder/ITS.refs/ITS1.f.ref -cutoffs dnabarcoder/ITS.refs/ITS1/best.ITS1.merge.best.json -p ../data/finalcombined/${SAMPLE}.ITS1
python3.9 dnabarcoder/dnabarcoder.py classify -i data/finalcombined/${SAMPLE}.ITS2.f_BLAST.bestmatch -r dnabarcoder/ITS.refs/ITS2.f.ref -cutoffs dnabarcoder/ITS.refs/ITS2/best.ITS2.merge.best.json -p ../data/finalcombined/${SAMPLE}.ITS2
python3.9 dnabarcoder/dnabarcoder.py classify -i data/finalcombined/${SAMPLE}.5.8S.f_BLAST.bestmatch -r dnabarcoder/ITS.refs/5.8S.f.ref -cutoffs dnabarcoder/ITS.refs/5.8S/best.5.8S.23.5.11.best.json -p ../data/finalcombined/${SAMPLE}.5_8S

# format for R
sed 's/\t/,/;s/\t//;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/.__//;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/|/,/;s/|/,/' data/finalcombined/${SAMPLE}.ITS1.classified | sed '1d' > data/finalcombined/${SAMPLE}.ITS1.labeled.csv
sed -i '1s/^/ID,read,dir,region,taxon,kingdom,phylum,class,order,family,genus,species,rank,cut-off,confidence,referenceID,blast.score,blast.sim,blast.coverage\n/' data/finalcombined/${SAMPLE}.ITS1.labeled.csv
sed 's/\t/,/;s/\t//;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/.__//;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/|/,/;s/|/,/' data/finalcombined/${SAMPLE}.ITS2.classified | sed '1d' > data/finalcombined/${SAMPLE}.ITS2.labeled.csv
sed -i '1s/^/ID,read,dir,region,taxon,kingdom,phylum,class,order,family,genus,species,rank,cut-off,confidence,referenceID,blast.score,blast.sim,blast.coverage\n/' data/finalcombined/${SAMPLE}.ITS2.labeled.csv
sed 's/\t/,/;s/\t//;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/.__//;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/|/,/;s/|/,/' data/finalcombined/${SAMPLE}.5_8S.classified | sed '1d' > data/finalcombined/${SAMPLE}.5_8S.labeled.csv
sed -i '1s/^/ID,read,dir,region,taxon,kingdom,phylum,class,order,family,genus,species,rank,cut-off,confidence,referenceID,blast.score,blast.sim,blast.coverage\n/' data/finalcombined/${SAMPLE}.5_8S.labeled.csv
