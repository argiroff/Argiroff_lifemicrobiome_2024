#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=20:00:00
#SBATCH --mem-per-cpu=2G
#SBATCH --job-name=se_%a
#SBATCH --output=se_%a.out
#SBATCH -p batch
#SBATCH -A bsd
#SBATCH --array=1-11

cd /lustre/or-scratch/cades-bsd/7wa/Argiroff_lifemicrobiome_2024/data/processed/spieceasi

# file variables
infile1=$(awk "NR==${SLURM_ARRAY_TASK_ID}" spieceasi_16s_infiles.txt)
infile2=$(awk "NR==${SLURM_ARRAY_TASK_ID}" spieceasi_its_infiles.txt)
infile3=$(awk "NR==${SLURM_ARRAY_TASK_ID}" spieceasi_metab_infiles.txt)
outfile=$(awk "NR==${SLURM_ARRAY_TASK_ID}" spieceasi_outfiles.txt)

source activate r-cades-subil

Rscript /lustre/or-scratch/cades-bsd/7wa/Argiroff_lifemicrobiome_2024/code/spieceasi.R $infile1 $infile2 $infile3 $outfile

conda deactivate
