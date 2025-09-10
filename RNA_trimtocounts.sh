#!/bin/bash

###make hisat indices
###Copy TruSeq-3 file to directory
###Copy gtf file to directory

conda env create -f RNA_trim_to_count.yml

conda activate RNA_trim_to_count

unset PYTHONPATH

###Update with paths to Jave and Trimmomatic installations
Java=path_to_your_java_installation
Trimmomatic=path_to_trimmomatic0.30
FastQC=path_to_FastQC
Hisat2=path_to_hisat2
Hisat_index=path_to_hisat_indices
Samtools=path_to_samtools1.9
Htseq=path_to_htseq_count_2.0.3

for f1 in *_R1_001.fastq.gz
do
#Trimmomatic first
f2=${f1%%_R1_001.fastq.gz}"_R2_001.fastq.gz" 
bf=${f1%%_R1_001.fastq.gz}
echo $bf
$Java -jar $Trimmomatic PE -phred33 $f1 $f2 $bf.R1_pairedtrimAd.fastq $bf.R1_unpairedtrimAd.fastq $bf.R2_pairedtrimAd.fastq $bf.R2_unpairedtrimAd.fastq ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:8:TRUE LEADING:3 TRAILING:3 SLIDINGWINDOW:3:30 MINLEN:36
done

###FastQC check
for f in *_pairedtrimAd.fastq
do
$FastQC $f 
done

mkdir FastQCresults/
for g in *_pairedtrimAd_fastqc.html
do
mv $g FastQCresults/
done

for h in *_pairedtrimAd_fastqc.zip
do
mv $h FastQCresults/
done


###Update hisat indices location
###HiSat
#This code uses only the fasta files for alignments
#We specify a max-intron length because we are working with yeast and it is unlikely that we will have long introns
#This code will output a sam file and a summary file with alignment statistics
for m1 in *.R1_pairedtrimAd.fastq
do
m2=${m1%%.R1_pairedtrimAd.fastq}".R2_pairedtrimAd.fastq" 
bm=${m1%%.R1_pairedtrimAd.fastq}
$Hisat2 -x $Hisat_index -1 $m1 -2 $m2 --max-intronlen 500 --summary-file $bm.align_summary.txt -S $bm.aligned_paired.sam
done


###Sorting sam files
#This code will sort sam files base on position
#This code will produce a bam file and a bai file for viewing in IGV
for us1 in *_paired.sam
do
bus1=${us1%%_paired.sam}
$Samtools sort $us1 -o $bus1.sorted.sam
$Samtools view -Sb -o $bus1.sorted.bam $bus1.sorted.sam
$Samtools index $bus1.sorted.bam
done

###Update gtf file to species of interest
###htseq
#We specified that our sam file is sorted by position (default in htseq-count is by name) 
#We are telling htseq count to count everything in the CDS because by default it looks for exons, and we aren't totally sure about those from our aer annotation
#We use -s reverse because that is how most libraries nowadays are made
#We are using --nonunique fraction because we are planning to sum orthogroups
for s1 in *sorted.sam
do
bs=${s1%%sorted.sam}
echo $bs
$Htseq -f sam -r pos -t CDS -s reverse --nonunique fraction $s1 yHMPu5000035659_saturnispora_dispora_160519.final.gtf > $bs.count_fraction.txt
done

mkdir htseqcount_nonuniqueFRACTION_out/

for c1 in *.count_fraction.txt
do 
mv $c1 htseqcount_nonuniqueFRACTION_out/
done

conda deactivate