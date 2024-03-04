#!/usr/bin/env bash

# name: assign_tax_16s.sh
# author: William Argiroff
# inputs: QIIME2 clustered repseq files and SILVA classifier
# outputs: QIIME2 taxonomy file in final_qzas/otu_97_taxonomy/
# notes: expects path(relative to project root)/repseq as arg1 and classifier as arg2

# Activate QIIME2 environment
echo "Activating QIIME2 environment."
source activate /opt/miniconda3/envs/qiime2-2022.8

# Files
echo "Obtaining filepaths."

infile1=`echo "$PWD"/"$1"`
infile2=`echo "$PWD"/"$2"`
outdir=`echo "$PWD"/"data/qiime2/final_qzas/16S/otu_97_taxonomy"`

if test -d $outdir; then
  echo "$outdir"" already exists. Removing old directory."
  rm -r $outdir
fi

# Assign taxonomy
progress=`echo "$infile" | sed -E "s/\/demux.qza//" | sed -E "s/(.*\/)//"`
echo "Classifying ""$1".

qiime feature-classifier classify-sklearn \
    --i-classifier $infile2 \
    --i-reads $infile1 \
    --output-dir $outdir

echo "Finished classifying ""$1".

# Deactivate QIIME2 environment
echo "Deactivating QIIME2 environment."

conda deactivate
