#!/usr/bin/env bash

# name: cluster_97_otu.sh
# author: William Argiroff
# inputs: QIIME2 merged_table.qza and merged_representative_sequence.qza files
# outputs: Clustered table and sequence qzas in final_qzas
# notes: expects path(relative to project root)/final_qzas/(16S or ITS)/(files) as inputs
#   ordered arg1 is table and arg2 is repseqs

# Activate QIIME2 environment
echo "Activating QIIME2 environment."
source activate /opt/miniconda3/envs/qiime2-2022.8

# Files
echo "Obtaining filepaths."

infile1=`echo "$PWD"/"$1"`
infile2=`echo "$PWD"/"$2"`
outdir=`echo "$infile1" | sed -E "s/merged_table.qza/otu_97/"`

# Cluster at 97% identify
progress1=`echo "$infile1" | sed -E "s/\/final_qzas\/merged_table.qza//"`
progress1=`echo "$infile1" | sed -E "s/(.*\/)//"`
progress2=`echo "$infile1" | sed -E "s/\/"$progress1"//" | sed -E "s/(.*\/)//"`

echo "Clustering ""$progress2"" OTUs."

qiime vsearch cluster-features-de-novo \
  --i-table $infile1 \
  --i-sequences $infile2 \
  --p-perc-identity 0.97 \
  --output-dir $outdir

echo "Finished clustering ""$progress2" OTUs.

# Deactivate QIIME2 environment
echo "Deactivating QIIME2 environment."

conda deactivate
