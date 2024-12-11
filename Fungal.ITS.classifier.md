# Step-by-step code for classifying fungi with DNAbarcoder (Vu et al 2022).
### Nick Bard 2023

#### Alternatively, manually edit Fungal.ITS.classifier.sh and run as a bash script

## This must be run in the teknonaturalist directory, which can be set as $PATH or navigated to if $PATH variable not set:
```
cd $PATH/teknonaturalist
```

Make sure that dnabarcoder directory with prepared database is in teknonaturalist/ (teknonaturalist/dnabarcoder/)
Remain in teknonaturalist/ directory to run these commands.

## General code for classifying fungi with DNAbarcoder , available at https://github.com/vuthuyduong/dnabarcoder.

## HEADER LINES INSTRUCTIONS
### Replace all ${text} in code, as follows.
### Replace ${SRR} with common prefix for accession number, (e.g., SRR92).
### Replace ${SAMPLE} with specific epithet (2nd word) of plant species name (e.g., ermanii).

# CODE:
## Combine all individual samples in a dataset and reformat so readable by DNAbarcoder.
```
grep "" data/final/${SRR}*.ITSx.ITS1.full_and_partial.fasta | awk 'NR % 2 == 0 {sub(/.*:/, "", $0)} 1' | sed "s/.*\(${SRR}\)/>\1/" | sed 's/\..*>/,/' > data/finalcombined/${SAMPLE}.ITS1.full.partial.all
grep "" data/final/${SRR}*.ITSx.ITS2.full_and_partial.fasta | awk 'NR % 2 == 0 {sub(/.*:/, "", $0)} 1' | sed "s/.*\(${SRR}\)/>\1/" | sed 's/\..*>/,/' > data/finalcombined/${SAMPLE}.ITS2.full.partial.all
grep "" data/final/${SRR}*.ITSx.5_8S.full_and_partial.fasta | awk 'NR % 2 == 0 {sub(/.*:/, "", $0)} 1' | sed "s/.*\(${SRR}\)/>\1/" | sed 's/\..*>/,/' > data/finalcombined/${SAMPLE}.5_8S.full.partial.all
```

## filter 5.8S to minimum length 100.

```
vsearch --fastx_filter data/finalcombined/${SAMPLE}.5_8S.full.partial.all --fastq_minlen 100 --fastaout data/finalcombined/${SAMPLE}.5_8S.100.full.partial.all
```

## search Genus ITS1/ITS2/5.8S sequences.
### USER: Replace {SAMPLE} with name or other identier, e.g., ermanii.

```
python3.12 dnabarcoder/dnabarcoder.py search -i data/finalcombined/${SAMPLE}.ITS1.full.partial.all -r dnabarcoder/ITS.refs/unite2024/unite2024ITS1.unique.phylum.fasta -ml 50 -p ../data/finalcombined/${SAMPLE}
python3.12 dnabarcoder/dnabarcoder.py search -i data/finalcombined/${SAMPLE}.ITS2.full.partial.all -r dnabarcoder/ITS.refs/unite2024/unite2024ITS2.unique.phylum.fasta -ml 50 -p ../data/finalcombined/${SAMPLE}
python3.12 dnabarcoder/dnabarcoder.py search -i data/finalcombined/${SAMPLE}.5_8S.100.full.partial.all -r dnabarcoder/ITS.refs/unite2024/5_8s.unique.class.fasta -ml 50 -p ../data/finalcombined/${SAMPLE}
```

## conduct local best match search with classify

```
python3.12 dnabarcoder/dnabarcoder.py classify -i data/finalcombined/${SAMPLE}.unite2024ITS1.unique.phylum_BLAST.bestmatch -c dnabarcoder/ITS.refs/unite2024/unite2024ITS1.unique.phylum.classification -cutoffs dnabarcoder/ITS.refs/unite2024/unite2024ITS1.unique.cutoffs.best.json -p ../data/finalcombined/${SAMPLE}.ITS1
python3.12 dnabarcoder/dnabarcoder.py classify -i data/finalcombined/${SAMPLE}.unite2024ITS2.unique.phylum_BLAST.bestmatch -c dnabarcoder/ITS.refs/unite2024/unite2024ITS2.unique.phylum.classification -cutoffs dnabarcoder/ITS.refs/unite2024/unite2024ITS2.unique.cutoffs.best.json -p ../data/finalcombined/${SAMPLE}.ITS2
python3.12 dnabarcoder/dnabarcoder.py classify -i data/finalcombined/${SAMPLE}.5_8s.unique.class_BLAST.bestmatch -c dnabarcoder/ITS.refs/unite2024/5_8s.unique.class.classification -cutoffs dnabarcoder/ITS.refs/unite2024/unite20245_8s.cutoffs.json -p ../data/finalcombined/${SAMPLE}.5_8S
```
## format for R

```
sed 's/\t/,/;s/\t//;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/.__//;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/|/,/;s/|/,/' data/finalcombined/${SAMPLE}.ITS1.classified | sed '1d' > data/finalcombined/${SAMPLE}.ITS1.labeled.csv
sed -i '1s/^/ID,read,dir,region,taxon,kingdom,phylum,class,order,family,genus,species,rank,cut-off,confidence,referenceID,blast.score,blast.sim,blast.coverage\n/' data/finalcombined/${SAMPLE}.ITS1.labeled.csv
sed 's/\t/,/;s/\t//;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/.__//;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/|/,/;s/|/,/' data/finalcombined/${SAMPLE}.ITS2.classified | sed '1d' > data/finalcombined/${SAMPLE}.ITS2.labeled.csv
sed -i '1s/^/ID,read,dir,region,taxon,kingdom,phylum,class,order,family,genus,species,rank,cut-off,confidence,referenceID,blast.score,blast.sim,blast.coverage\n/' data/finalcombined/${SAMPLE}.ITS2.labeled.csv
sed 's/\t/,/;s/\t//;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/\t/,/;s/.__//;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/;.__/,/;s/|/,/;s/|/,/' data/finalcombined/${SAMPLE}.5_8S.classified | sed '1d' > data/finalcombined/${SAMPLE}.5_8S.labeled.csv
sed -i '1s/^/ID,read,dir,region,taxon,kingdom,phylum,class,order,family,genus,species,rank,cut-off,confidence,referenceID,blast.score,blast.sim,blast.coverage\n/' data/finalcombined/${SAMPLE}.5_8S.labeled.csv
```

