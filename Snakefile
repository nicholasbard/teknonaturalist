import os
ruleorder:  adapterremoval_pe_unequal > adapterremoval_pe_equal
ruleorder:  vsearch_unequal > vsearch_equal
ruleorder: cutadapt_unequal > cutadapt_equal
ruleorder: cat_unequal > cat_equal

############################
### CUSTOMIZABLE SECTION ###
############################

#Note, for all: keep the [],'', and "". remove <>.
ADAP_OUTPUTS = [".pair1.truncated",".pair2.truncated",".collapsed",".collapsed.truncated", ".singleton.truncated", ".sb.truncated"]
SRRS = ["<ENTER SRR NUMBER(s) HERE>"]
CONGS = 'assembly/<ENTER CONSPECIFIC OR CONGENER FOR ASSEMBLY HERE, E.G., Betula.nana>.assembly/<ENTER CONSPECIFIC OR CONGENER AGAIN HERE>.bwa.index'
FOCALS = 'database/genbank/<ENTER FOCAL SPECIES HERE, E.G., Betula.ermanii>.Genbank.nucl.fasta'

#Note: Replace the uchime fasta files if providing your own
UCHIME1S = 'database/uchime_datasets/uchime_reference_dataset_ITS1_28.06.2017.fasta'
UCHIME2S = 'database/uchime_datasets/uchime_reference_dataset_ITS2_28.06.2017.fasta'

GENS = 'database/PLANiTS/<ENTER FOCAL GENERA HERE>.fasta'
THREADS = <HOW MANY THREADS/CPUs?>
#Note: The THREADMEGAS value can be the same as the THREADS value in many cases. If Megahit malfunctions due to apparent issues with multithreading on some systems (e.g., Mac). If so, set this number to 1.
THREADMEGAS = <SAME AS THREADS VALUE, OR 1>

MEMS = <HOW MUCH MEMORY FOR MEGAHIT? may be written with integer for bytes (e.g., 3400000) or as fraction of total machine memory (e.g., 0.1)>
ADAP1S = 'AGATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTG'
ADAP2S = 'AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT'
#Note: Common adapters are included here, but these parameters may be changed.

###################################
### END OF CUSTOMIZABLE SECTION ###
###################################


# Advanced parameters must be edited directly in the corresponding rule of the Snakefile, if desired. Consult the material for the corresponding program for information.

rule all:
    input:
        expand("data/trimmed1/{srr}{ext}", srr = SRRS, ext = ADAP_OUTPUTS)

##### Remove adapters, trim/truncate reads with quality under 2 (default) and with Ns at 5' and 3'. Collapse PE reads with overlap set to 15. Default standard Illumina, Phred 33.
rule adapterremoval_pe_unequal:
    input:
        sample1="data/orig.fastqs/{srr}_1.fastq",
        sample2="data/orig.fastqs/{srr}_2.fastq",
        sample3="data/orig.fastqs/{srr}.fastq"
    params:
        prefix="data/trimmed1/{srr}",
        thread=THREADS,
        adap1=ADAP1S,
        adap2=ADAP2S,
    output:
        R1a="data/trimmed1/{srr}.pair1.truncated",
        R2a="data/trimmed1/{srr}.pair2.truncated",
        colla="data/trimmed1/{srr}.collapsed",
        colltra="data/trimmed1/{srr}.collapsed.truncated",
        singa="data/trimmed1/{srr}.singleton.truncated",
        R3a="data/trimmed1/{srr}.sb.truncated"
    shell:
        "AdapterRemoval --file1 {input.sample1} --file2 {input.sample2} --threads {params.thread} --collapse-conservatively --trimns --trimqualities --minalignmentlength 15 --basename {params.prefix} --adapter1 {params.adap1} --adapter2 {params.adap2} ;\
        AdapterRemoval --file1 {input.sample3} --threads {params.thread} --collapse-conservatively --trimns --trimqualities --basename {params.prefix}.sb --adapter1 {params.adap1} --adapter2 {params.adap2}"


rule adapterremoval_pe_equal:
    input:
        sample1="data/orig.fastqs/{srr}_1.fastq",
        sample2="data/orig.fastqs/{srr}_2.fastq"
    params:
        prefix="data/trimmed1/{srr}",
        thread=THREADS,
        adap1=ADAP1S,
        adap2=ADAP2S,
    output:
        R1a="data/trimmed1/{srr}.pair1.truncated",
        R2a="data/trimmed1/{srr}.pair2.truncated",
        colla="data/trimmed1/{srr}.collapsed",
        colltra="data/trimmed1/{srr}.collapsed.truncated"
    shell:
        "AdapterRemoval --file1 {input.sample1} --file2 {input.sample2} --threads {params.thread} --collapse-conservatively --trimns --trimqualities --minalignmentlength 15 --basename {params.prefix} --adapter1 {params.adap1} --adapter2 {params.adap2}"


rule branch:
    input:
        lambda wildcards: count_files(wildcards)
    run:
        if input[0] == 3:
            snakemake.shell("snakemake adapterremoval_pe_unequal")
        elif input[0] == 2:
            snakemake.shell("snakemake adapterremoval_pe_equal")


##### For all output files, filter reads with >2% error rate.
rule vsearch_unequal:
    input:
        R1b="data/trimmed1/{srr}.pair1.truncated",
        R2b="data/trimmed1/{srr}.pair2.truncated",
        collb="data/trimmed1/{srr}.collapsed",
        colltrb="data/trimmed1/{srr}.collapsed.truncated",
        strunb="data/trimmed1/{srr}.sb.truncated"
    output:
        R1c="data/trimmed2/{srr}.pair1.truncated.q.fastq",
        R2c="data/trimmed2/{srr}.pair2.truncated.q.fastq",
        collc="data/trimmed2/{srr}.collapsed.q.fastq",
        colltrc="data/trimmed2/{srr}.collapsed.truncated.q.fastq",
        strunc="data/trimmed2/{srr}.sb.truncated.q.fastq"
    shell:
        "vsearch --fastx_filter {input.R1b} -fastq_maxee_rate 0.02 -fastqout {output.R1c} ;\
        vsearch --fastx_filter {input.R2b} -fastq_maxee_rate 0.02 -fastqout {output.R2c} ;\
        vsearch --fastx_filter {input.collb} -fastq_maxee_rate 0.02 -fastqout {output.collc} ;\
        vsearch --fastx_filter {input.colltrb} -fastq_maxee_rate 0.02 -fastqout {output.colltrc} ;\
        vsearch --fastx_filter {input.strunb} -fastq_maxee_rate 0.02 -fastqout {output.strunc} "

rule vsearch_equal:
    input:
        R1b="data/trimmed1/{srr}.pair1.truncated",
        R2b="data/trimmed1/{srr}.pair2.truncated",
        collb="data/trimmed1/{srr}.collapsed",
        colltrb="data/trimmed1/{srr}.collapsed.truncated"
    output:
        R1c="data/trimmed2/{srr}.pair1.truncated.q.fastq",
        R2c="data/trimmed2/{srr}.pair2.truncated.q.fastq",
        collc="data/trimmed2/{srr}.collapsed.q.fastq",
        colltrc="data/trimmed2/{srr}.collapsed.truncated.q.fastq"
    shell:
        "vsearch --fastx_filter {input.R1b} -fastq_maxee_rate 0.02 -fastqout {output.R1c} ;\
        vsearch --fastx_filter {input.R2b} -fastq_maxee_rate 0.02 -fastqout {output.R2c} ;\
        vsearch --fastx_filter {input.collb} -fastq_maxee_rate 0.02 -fastqout {output.collc} ;\
        vsearch --fastx_filter {input.colltrb} -fastq_maxee_rate 0.02 -fastqout {output.colltrc}"

##### Filter out simple repeats (Poly A's, etc) of 50bp, depending on QC
rule cutadapt_unequal:
    input:
        R1c="data/trimmed2/{srr}.pair1.truncated.q.fastq",
        R2c="data/trimmed2/{srr}.pair2.truncated.q.fastq",
        collc="data/trimmed2/{srr}.collapsed.q.fastq",
        colltrc="data/trimmed2/{srr}.collapsed.truncated.q.fastq",
        strunc="data/trimmed2/{srr}.sb.truncated.q.fastq"
    output:
        R1d="data/trimmed3/{srr}.pair1.truncated.q.p.fastq",
        R2d="data/trimmed3/{srr}.pair2.truncated.q.p.fastq",
        colld="data/trimmed3/{srr}.collapsed.q.p.fastq",
        colltrd="data/trimmed3/{srr}.collapsed.truncated.q.p.fastq",
        strund="data/trimmed3/{srr}.sb.truncated.q.p.fastq"
    params:
        thread=THREADS
    shell:
        "cutadapt -a 'A{{50}}' -a 'G{{50}}' -a 'T{{50}}' -a 'C{{50}}' -o {output.R1d} {input.R1c} -j {params} ;\
        cutadapt -a 'A{{50}}' -a 'G{{50}}' -a 'T{{50}}' -a 'C{{50}}' -o {output.R2d} {input.R2c} -j {params} ;\
        cutadapt -a 'A{{50}}' -a 'G{{50}}' -a 'T{{50}}' -a 'C{{50}}' -o {output.colld} {input.collc} -j {params} ;\
        cutadapt -a 'A{{50}}' -a 'G{{50}}' -a 'T{{50}}' -a 'C{{50}}' -o {output.colltrd} {input.colltrc} -j {params} ;\
        cutadapt -a 'A{{50}}' -a 'G{{50}}' -a 'T{{50}}' -a 'C{{50}}' -o {output.strund} {input.strunc} -j {params}"

rule cutadapt_equal:
    input:
        R1c="data/trimmed2/{srr}.pair1.truncated.q.fastq",
        R2c="data/trimmed2/{srr}.pair2.truncated.q.fastq",
        collc="data/trimmed2/{srr}.collapsed.q.fastq",
        colltrc="data/trimmed2/{srr}.collapsed.truncated.q.fastq"
    output:
        R1d="data/trimmed3/{srr}.pair1.truncated.q.p.fastq",
        R2d="data/trimmed3/{srr}.pair2.truncated.q.p.fastq",
        colld="data/trimmed3/{srr}.collapsed.q.p.fastq",
        colltrd="data/trimmed3/{srr}.collapsed.truncated.q.p.fastq"
    params:
        thread=THREADS
    shell:
        "cutadapt -a 'A{{50}}' -a 'G{{50}}' -a 'T{{50}}' -a 'C{{50}}' -o {output.R1d} {input.R1c} -j {params} ;\
        cutadapt -a 'A{{50}}' -a 'G{{50}}' -a 'T{{50}}' -a 'C{{50}}' -o {output.R2d} {input.R2c} -j {params} ;\
        cutadapt -a 'A{{50}}' -a 'G{{50}}' -a 'T{{50}}' -a 'C{{50}}' -o {output.colld} {input.collc} -j {params} ;\
        cutadapt -a 'A{{50}}' -a 'G{{50}}' -a 'T{{50}}' -a 'C{{50}}' -o {output.colltrd} {input.colltrc} -j {params}"

##### Combine all contigs.
rule cat_unequal:
    input:
        R1e="data/trimmed3/{srr}.pair1.truncated.q.p.fastq",
        R2e="data/trimmed3/{srr}.pair2.truncated.q.p.fastq",
        colle="data/trimmed3/{srr}.collapsed.q.p.fastq",
        colltre="data/trimmed3/{srr}.collapsed.truncated.q.p.fastq",
        strune="data/trimmed3/{srr}.sb.truncated.q.p.fastq"
    output:
        "data/QC/{srr}.QC.fastq"
    shell:
        "cat {input.R1e} {input.R2e} {input.colle} {input.colltre} {input.strune} > {output}"

##### Combine all contigs.
rule cat_equal:
    input:
        R1e="data/trimmed3/{srr}.pair1.truncated.q.p.fastq",
        R2e="data/trimmed3/{srr}.pair2.truncated.q.p.fastq",
        colle="data/trimmed3/{srr}.collapsed.q.p.fastq",
        colltre="data/trimmed3/{srr}.collapsed.truncated.q.p.fastq"
    output:
        "data/QC/{srr}.QC.fastq"
    shell:
        "cat {input.R1e} {input.R2e} {input.colle} {input.colltre} > {output}"

##### Convert to fasta. Rename so there aren't duplicate read names.
rule fastq_to_fasta:
    input:
        "data/QC/{srr}.QC.fastq"
    output:
        "data/QC/{srr}.QC.fasta"
    shell:
        "seqtk seq -a {input} > {output}"

##### Remove duplicate contigs.
rule vsearch2:
    input:
        "data/QC/{srr}.QC.fasta"
    output:
        "data/CQC/{srr}.CQC.fasta"
    shell:
        "vsearch --derep_fulllength {input} --output {output}"

##### UNIvec file filtration step.
rule univec:
    input:
        "data/CQC/{srr}.CQC.fasta"
    output:
        univec="data/krakenout/univec.{srr}",
        uCQC="data/krakenout/uCQC.{srr}.fasta",
        rep="data/logs/{srr}.univec.report"
    params:
        thread=THREADS
    log:
        "data/logs/{srr}_univec.kraken2_reads.log"
    shell:
        "kraken2 {input} --threads {params} -db database/univec/ -output {output.univec} --report {output.rep} --use-names --unclassified-out {output.uCQC}"

##### Very loosely map against indexed congener assembly with 100bp match to plant for tagging and removal.
rule fastmap:
    input:
        uCQC2="data/krakenout/uCQC.{srr}.fasta"
    output:
        "data/bwa/{srr}.bwafastmap"
    log:
        "data/logs/{srr}.fastmap.log"
    params: 
        cong=CONGS
    shell:
        "bwa fastmap -l 100 {params} {input.uCQC2} > {output}"

###### Find nonassembled reads by collapsing all lines, making read separators (//) line separators, and searching for matches.
rule nonassem:
    input:
        "data/bwa/{srr}.bwafastmap"
    output:
        "data/bwa/{srr}.non.assembly.reads"
    shell:
        "tr -s '\n', ' ' < {input} | tr -s '//', '\n' | grep -v 'EM' | awk '{{print $2}}' > {output}"
rule nomatch:
    input:
        nonassembly="data/bwa/{srr}.non.assembly.reads",
        uCQC1="data/krakenout/uCQC.{srr}.fasta"
    output:
        "data/no.match/{srr}.no.match.fasta"
    shell:
        "seqtk subseq {input.uCQC1} {input.nonassembly} > {output}"

##### Search for all fungal reads. Rapidly purge data.
rule kraken2:
    input:
        nomatch="data/no.match/{srr}.no.match.fasta",
        kraken2db="database/fungi"
    output:
        krakenout="data/krakenout2/krakenoutput.{srr}",
        rawclass="data/krakenout2/raw.kraken.classified.{srr}.fasta",
        report2="data/logs/{srr}.raw.kraken.report"
    params:
        thread=THREADS
    log:
        "data/logs/{srr}.raw.kraken2_reads.log"
    shell:
        "kraken2 {input.nomatch} --threads {params} -db {input.kraken2db} -output {output.krakenout} --report {output.report2} --use-names --report-minimizer-data --classified-out {output.rawclass}"

##### Fix Kraken2 printed taxids headers on classified fasta.
rule sed:
    input:
        "data/krakenout2/raw.kraken.classified.{srr}.fasta"
    output:
        "data/krakenout2/kraken.classified.{srr}.fasta"
    shell:
        "sed 's/ kraken:taxid|*//' {input} > {output}"

##### Filter genus matching reads.
rule blast1:
    input:
        krakenout1="data/krakenout2/kraken.classified.{srr}.fasta"
    output:
        "data/blast/{srr}.gen.blast.txt"
    params:
        thread=THREADS,
        gen=GENS
    shell:
        "blastn -query {input.krakenout1} -db {params.gen} -out {output} -num_alignments 3 -num_descriptions 3 -num_threads {params.thread} -word_size 25 -gapopen 2 -gapextend 1 -reward 1 -penalty -1 -evalue 1e-10"
rule grep1:
    input:
        "data/blast/{srr}.gen.blast.txt"
    output:
        "data/blast/no.gen.{srr}.ITS"
    shell:
        "grep 'No hits found' -B 5 {input} | grep 'Query' | cut -c 8- > {output}"
rule subseq1:
    input:
        krakenout2="data/krakenout2/kraken.classified.{srr}.fasta",
        noits="data/blast/no.gen.{srr}.ITS/"
    output:
        "data/blast/no.gen.{srr}.fasta"
    shell:
        "seqtk subseq {input.krakenout2} {input.noits} > {output}"

###### Filter focal species genbank reads.
rule blast2:
    input:
        blastout="data/blast/no.gen.{srr}.fasta"
    output:
        "data/blast/gen.genbank.{srr}.ITS"
    params:
        focal=FOCALS,
        thread=THREADS
    shell:
        "blastn -query {input.blastout} -db {params.focal} -task megablast -out {output} -num_alignments 3 -num_descriptions 3 -num_threads {params.thread} -evalue 1e-30"
rule grep2:
    input:
        "data/blast/gen.genbank.{srr}.ITS"
    output:
        "data/blast/no.gen.genbank.{srr}.ITS"
    shell:
        "grep 'No hits found' -B 5 {input} | grep 'Query' | cut -c 8- > {output}"
rule subseq2:
    input:
        krakenout3="data/blast/no.gen.{srr}.fasta",
        noitsb="data/blast/no.gen.genbank.{srr}.ITS"
    output:
        "data/blast/no.gen.genbank.{srr}.fasta"
    shell:
        "seqtk subseq {input.krakenout3} {input.noitsb} > {output}"

###### Filter chimeras, rename and dereplicate for formatting.
rule vsearch3:
    input:
        nogen="data/blast/no.gen.genbank.{srr}.fasta"
    output:
        nonchim="data/nonchimera/nonchimera.filtered.reads.{srr}.fasta",
        ITS1filt="data/nonchimera/ITS1.filtered.{srr}.txt"
    params:
        uchime1 = UCHIME1S
    shell:
        "vsearch --uchime_ref {input.nogen} --db {params} --nonchimeras {output.nonchim} --uchimeout {output.ITS1filt}"
rule vsearch4:
    input:
        nogen2="data/nonchimera/nonchimera.filtered.reads.{srr}.fasta"
    output:
        nonchim2="data/nonchimera/nonchimera.filtered.reads.2.{srr}.fasta",
        ITS2filt="data/nonchimera/ITS2.filtered.{srr}.txt"
    params:
        uchime2 = UCHIME2S
    shell:
        "vsearch --uchime_ref {input.nogen2} --db {params} --nonchimeras {output.nonchim2} --uchimeout {output.ITS2filt}"
rule seqtk:
    input:
        "data/nonchimera/nonchimera.filtered.reads.2.{srr}.fasta"
    output:
        "data/nonchimera/chimera.filter.{srr}.fasta"
    shell:
        "seqtk seq -i {input} | seqtk rename > {output}"
rule vsearch5:
    input:
        "data/nonchimera/chimera.filter.{srr}.fasta"
    output:
        "data/nonchimera/Final.chim.filter.{srr}.fasta"
    shell:
        "vsearch --derep_fulllength {input} --output {output}"

##### Assemble with Megahit (minimum contig size 200).
rule megahit:
    input:
        "data/nonchimera/Final.chim.filter.{srr}.fasta"
    output:
        outdir = directory("data/meta/{srr}"),
        mega = "data/meta/{srr}/final.contigs.fa"
    params:
        threadm=THREADMEGAS,
        mem=MEMS
    log:
        "data/logs/megahit.{srr}.log"
    shell:
        "megahit -r {input} --presets meta-sensitive --keep-tmp-files -m {params.mem} -o {output.outdir} -t {params.threadm} -f"

##### Combine scaffolds from all meta-assembly programs.
rule cat2:
    input:
        meta="data/meta/{srr}/final.contigs.fa",
        nonmeta="data/nonchimera/Final.chim.filter.{srr}.fasta"
    output:
        "data/final/contigs.reads.{srr}.fasta"
    shell:
        "cat {input.meta} {input.nonmeta} > {output}"

##### Dereplicate any remaining scaffolds.
rule vsearch6:
    input:
        "data/final/contigs.reads.{srr}.fasta"
    output:
        "data/final/F.c.reads.{srr}.fasta"
    shell:
        "vsearch --derep_fulllength {input} --output {output}"

##### Make unique identifiers for sequence names.
rule awk:
    input:
        "data/final/F.c.reads.{srr}.fasta"
    output:
        "data/final/F.c.e.reads.{srr}.fasta"
    shell:
        """awk '(/^>/ && s[$0]++){{$0=$0"_"s[$0]}}1;' {input} > {output}"""

##### Run ITSx on all sequences to bin sequences into different subregions of ITS.
rule itsx:
    input:
        "data/final/F.c.e.reads.{srr}.fasta"
    params:
        thread=THREADS
    output: "data/final/{srr}.ITSx"
    shell:
        "ITSx -i {input} --cpu {params} --multi_thread {params} -t F --save_regions all -o {output} --partial 70"
