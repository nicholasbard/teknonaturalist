# ~ teknonaturalist Fungi detection pipeline. To be used as a bash shell script equivalent for Snakemake. 
# ~ This pipeline is to be used for paired end fastq.gz files with EQUAL read counts with 2 fastq files (SRR##_1.fastq and SRR##_2.fastq)
# ~ Paired end reads, GBS and WGS Illumina reads
# Nick Bard 2023

#!/bin/bash
#Use bash shell.

#$ -pe smp <CPU>
# Request CPUs.
# ~ Enter information in <>.

# If adapters unknown AdapterRemoval --file1 ....fastq --file2 ....fastq --basename ... --identify-adapters
#  --adapter1 SEQUENCE Adapter sequence expected to be found in mate 1 reads [default:  AGATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTG]. (pcr primer)

#  --adapter2 SEQUENCE Adapter sequence expected to be found in mate 2 reads [default:  AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT]. (pcr primer)

###enter information in <>.
SRRnumber="<SRRnumber>"
genus="<genus>"
congspec="<specific epithet of close congener or focal species used for BWA fastmap step, e.g., nana>"
focalspec="<specific epithet of focal species, e.g., ermanii>"
adapter1="<adapter1>"
adapter2="<adapter2>"
thr="CPU"

#These should autopopulate.
cong="${genus}.${congspec}"
focal="${genus}.${focalspec}"

exec > ./logfile.txt

### Note prior to running: IN SOME CASES, headers of paired end reads don't match up. A variation of this code can fix it:
# seqkit replace -p '(^SRR[0-9]+\.)[0-9]+ [0-9]+' -r '${1}{nr} {nr}' ./${SRRnumber}_2.fastq > new
# rm ./${SRRnumber}_2.fastq
# mv new ./${SRRnumber}_2.fastq

#############################################################################################################

# First, create and navigate to working directory, i.e., $PATH/teknonaturalist

# Remove adapters, trim/truncate reads with quality under 2 (default) and with Ns at 5' and 3'. Collapse PE reads with overlap set to 15. Default standard Illumina, Phred 33.
AdapterRemoval --file1 data/orig.fastqs/${SRRnumber}_1.fastq --file2 data/orig.fastqs/${SRRnumber}_2.fastq --threads ${thr} --collapse-conservatively --trimns --trimqualities --minalignmentlength 15 --basename data/trimmed1/Adap.rem.${SRRnumber} --adapter1 ${adapter1} --adapter2 ${adapter2}

# For all output files, filter reads with >2% error rate.
vsearch --fastx_filter data/trimmed1/Adap.rem.${SRRnumber}.pair1.truncated --log data/logs/vsearch.p1t.${SRRnumber}.log -fastq_maxee_rate 0.02 -fastqout data/trimmed2/q.Adap.rem.${SRRnumber}.pair1.truncated
vsearch --fastx_filter data/trimmed1/Adap.rem.${SRRnumber}.pair2.truncated --log data/logs/vsearch.p2t.${SRRnumber}.log -fastq_maxee_rate 0.02 -fastqout data/trimmed2/q.Adap.rem.${SRRnumber}.pair2.truncated
vsearch --fastx_filter data/trimmed1/Adap.rem.${SRRnumber}.collapsed --log data/logs/vsearch.coll.${SRRnumber}.log -fastq_maxee_rate 0.02 -fastqout data/trimmed2/q.Adap.rem.${SRRnumber}.collapsed
vsearch --fastx_filter data/trimmed1/Adap.rem.${SRRnumber}.collapsed.truncated --log data/logs/vsearch.colltrunc.${SRRnumber}.log -fastq_maxee_rate 0.02 -fastqout data/trimmed2/q.Adap.rem.${SRRnumber}.collapsed.truncated

# Filter out simple repeats (Poly A's, etc) of 50bp, depending on QC
cutadapt -a "A{50}" -a "C{50}" -a "G{50}" -a "T{50}" -o data/trimmed3/poly.filt_pair1.trunc.${SRRnumber}.fastq data/trimmed2/q.Adap.rem.${SRRnumber}.pair1.truncated -j --json data/logs/cutadapt.p1t.${SRRnumber}.log.cutadapt.json ${thr}
cutadapt -a "A{50}" -a "C{50}" -a "G{50}" -a "T{50}" -o data/trimmed3/poly.filt_pair2.trunc.${SRRnumber}.fastq data/trimmed2/q.Adap.rem.${SRRnumber}.pair2.truncated -j --json data/logs/cutadapt.p2t.${SRRnumber}.log.cutadapt.json ${thr}
cutadapt -a "A{50}" -a "C{50}" -a "G{50}" -a "T{50}" -o data/trimmed3/poly.filt_collapsed.${SRRnumber}.fastq data/trimmed2/q.Adap.rem.${SRRnumber}.collapsed -j --json data/logs/cutadapt.coll.${SRRnumber}.log.cutadapt.json ${thr}
cutadapt -a "A{50}" -a "C{50}" -a "G{50}" -a "T{50}" -o data/trimmed3/poly.filt_coll.trunc.${SRRnumber}.fastq data/trimmed2/q.Adap.rem.${SRRnumber}.collapsed.truncated -j --json data/logs/cutadapt.colltrunc.${SRRnumber}.log.cutadapt.json ${thr}

# Combine all contigs.
cat data/trimmed3/poly.filt_pair2.trunc.${SRRnumber}.fastq data/trimmed3/poly.filt_pair1.trunc.${SRRnumber}.fastq data/trimmed3/poly.filt_collapsed.${SRRnumber}.fastq data/trimmed3/poly.filt_coll.trunc.${SRRnumber}.fastq > data/QC/${SRRnumber}.QC.fastq

# Remove intermediate files.
rm data/trimmed3/poly.filt* data/trimmed2/q.Adap.rem.* data/trimmed1/Adap.rem*

# Convert to fasta. Rename so there aren't duplicate read names.
seqtk seq -a data/QC/${SRRnumber}.QC.fastq > data/QC/${SRRnumber}.QC.fasta

# Remove duplicate contigs.
# NOTE: In some cases, large QC.fasta files may overwhelm memory during vsearch step, causing pipeline to fail. In such cases, the QC files may be split for this step and CQC.fasta files may be recombined immediately thereafter.
vsearch --derep_fulllength data/QC/${SRRnumber}.QC.fasta --log data/logs/vsearch2.${SRRnumber}.log --output data/CQC/${SRRnumber}.CQC.fasta

# UNIvec file filtration step.
kraken2 data/CQC/${SRRnumber}.CQC.fasta -db database/univec/ -output data/krakenout/univecout.${SRRnumber} --report data/krakenout/univec.report -threads ${thr} --use-names --unclassified-out data/krakenout/uCQC.${SRRnumber}.fasta

# Very loosely map against indexed congener assembly with 100bp match to plant for tagging and removal.
bwa fastmap -l 100 assembly/${cong}.assembly/${cong}.bwa.index data/krakenout/uCQC.${SRRnumber}.fasta > data/bwa/${SRRnumber}.bwafastmap

# Find nonassembled reads by collapsing all lines, making read separators (//) line separators, and searching for matches.
tr -s '\n', ' ' < data/bwa/${SRRnumber}.bwafastmap | tr -s '//', '\n' | grep -v "EM" | awk '{print $2}' > data/bwa/${SRRnumber}.non.assembly.reads
seqtk subseq data/krakenout/uCQC.${SRRnumber}.fasta data/bwa/${SRRnumber}.non.assembly.reads > data/no.match/${SRRnumber}.no.match.fasta

# Search for all fungal reads. Rapidly purge data.
kraken2 data/no.match/${SRRnumber}.no.match.fasta -db database/fungi -output data/krakenout2/krakenoutput.${SRRnumber} --report data/krakenout2/${SRRnumber}.raw.kraken.report -threads ${thr} --use-names --report-minimizer-data --classified-out data/krakenout2/raw.kraken.classified.${SRRnumber}.fasta
# Fix Kraken2 printed taxids headers on classified fasta. 
sed 's/ kraken:taxid|*//' data/krakenout2/raw.kraken.classified.${SRRnumber}.fasta > data/krakenout2/kraken.classified.${SRRnumber}.fasta

# Filter genus matching reads
blastn -query data/krakenout2/kraken.${SRRnumber}.classified.fasta -db database/PLANiTS/${genus}.fasta -out data/blast/${SRRnumber}.${genus}.blast.txt -num_alignments 3 -num_descriptions 3 -num_threads ${thr} -word_size 25 -gapopen 2 -gapextend 1 -reward 1 -penalty -1 -evalue 1e-10
grep "No hits found" -B 5 data/blast/${SRRnumber}.${genus}.blast.txt | grep "Query" | cut -c 8- > data/blast/no.${genus}.${SRRnumber}.ITS
seqtk subseq data/krakenout2/kraken.${SRRnumber}.classified.fasta data/blast/no.${genus}.${SRRnumber}.ITS > data/blast/no.${genus}.${SRRnumber}.fasta

# Filter focal species genbank reads
blastn -query data/blast/no.${genus}.${SRRnumber}.fasta -db database/genbank/${focal}.Genbank.nucl.fasta -task megablast -out data/blast/${genus}.genbank.${SRRnumber}.ITS -num_alignments 3 -num_descriptions 3 -num_threads ${thr} -evalue 1e-30
grep "No hits found" -B 5 data/blast/${genus}.genbank.${SRRnumber}.ITS | grep "Query" | cut -c 8- > data/blast/no.${genus}.genbank.${SRRnumber}.ITS
seqtk subseq data/blast/no.${genus}.${SRRnumber}.fasta data/blast/no.${genus}.genbank.${SRRnumber}.ITS > data/blast/no.${genus}.genbank.${SRRnumber}.fasta

# Filter chimeras, rename and dereplicate for formatting.
vsearch --uchime_ref data/blast/no.${genus}.genbank.${SRRnumber}.fasta --db database/uchime_datasets/uchime_reference_dataset_ITS1_28.06.2017.fasta \
--nonchimeras data/nonchimera/nonchimera.filtered.reads.${SRRnumber}.fasta --log data/logs/vsearch3.${SRRnumber}.log --uchimeout data/nonchimera/ITS1.filtered.${SRRnumber}.txt

vsearch --uchime_ref ./data/nonchimera/nonchimera.filtered.reads.${SRRnumber}.fasta -log data/logs/vsearch4.${SRRnumber}.log --db database/uchime_datasets/uchime_reference_dataset_ITS2_28.06.2017.fasta \
--nonchimeras data/nonchimera/nonchimera.filtered.reads.2.${SRRnumber}.fasta --log data/logs/vsearch4.${SRRnumber}.log --uchimeout data/nonchimera/ITS2.filtered.${SRRnumber}.txt

seqtk seq -i data/nonchimera/nonchimera.filtered.reads.2.${SRRnumber}.fasta | seqtk rename > data/nonchimera/chimera.filter.${SRRnumber}.fasta
vsearch --derep_fulllength data/nonchimera/chimera.filter.${SRRnumber}.fasta --log data/logs/vsearch5.${SRRnumber}.log --output data/nonchimera/Final.chim.filter.${SRRnumber}.fasta

# Assemble with Megahit, minimum contig size 200. NOTE: log file is in data/meta/{srr} directory.
megahit -r data/nonchimera/Final.chim.filter.${SRRnumber}.fasta --presets meta-sensitive --keep-tmp-files -m 0.5 -o data/meta/${SRRnumber} -t ${thr}

# Combine scaffolds from all meta-assembly programs.
cat data/meta/${SRRnumber}/final.contigs.fa data/nonchimera/Final.chim.filter.${SRRnumber}.fasta > data/final/contigs.reads.${SRRnumber}.fasta

# Dereplicate any remaining scaffolds.
vsearch --derep_fulllength data/final/contigs.reads.${SRRnumber}.fasta --log data/logs/vsearch6.${SRRnumber}.log --output data/final/F.c.reads.${SRRnumber}.fasta

# Make unique identifiers for sequence names
awk '(/^>/ && s[$0]++){$0=$0"_"s[$0]}1;' data/final/F.c.reads.${SRRnumber}.fasta > data/final/F.c.e.reads.${SRRnumber}.fasta

# Run ITSx on all sequences to bin sequences into different subregions of ITS
ITSx -i data/final/F.c.e.reads.${SRRnumber}.fasta --cpu ${thr} --multi_thread ${thr} -t F --save_regions all -o data/final/${SRRnumber}.ITSx --partial 70

# Remove any unneeded files at this point.
