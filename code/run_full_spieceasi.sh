#!/usr/bin/env bash

# name: run_full_spieceasi.sh
# author: William Argiroff
# inputs: 16S, ITS, metabolite matrices
# outputs: Spieceasi results rds
# notes: expects path(relative to project root)/*_input.rds as inputs

# Activate SPIEC-EASI conda environment
echo "Activating SPIEC-EASI environment..."
source activate r-spieceasi

# Files
echo "Obtaining filepaths..."

infile1=`echo "$PWD"/"$1"`
infile2=`echo "$PWD"/"$2"`
infile3=`echo "$PWD"/"$3"`
outfile=`echo "$PWD"/"$4"`

# Run SPIEC-EASI
echo "Running SPIEC-EASI on ""$infile1"" ""$infile2"" ""$infile3""..." 
Rscript code/spieceasi.R $infile1 $infile2 $infile3 $outfile

echo "Deactivating SPIEC-EASI environment..."
conda deactivate
echo "Done!"