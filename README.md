# ECAR_scripts
Code required to analyze transcriptomic data associated with the _Saturnispora_ aerobic fermentation comparative analysis 

RNA_trim_to_count.yml - A yaml file providing the details to set up a conda environment for these analyses.

Orthogroups.tsv - A tab separated file listing the reanalyzed Orthogroups using _Saturnispora_ translated gene sequences only giving the gene names for each Orthogroup. This file is needed to sum the counts of transcripts across orthogroups and facilitate comparisons of expression of orthogroups.

RNA_trimtocounts.sh - A bash file with the pipeline for analyzing the raw RNA seq data to generate counts for each gene.

sum_counts_OGv2.py - A python script to sum the counts of genes within the same orthogroup.
