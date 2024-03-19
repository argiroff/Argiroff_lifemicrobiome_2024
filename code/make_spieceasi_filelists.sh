#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=20:00:00
#SBATCH --mem-per-cpu=64G
#SBATCH --job-name=selists
#SBATCH -p batch
#SBATCH -A bsd

cd /lustre/or-scratch/cades-bsd/7wa/Argiroff_lifemicrobiome_2024/data/processed/spieceasi

# input files
ls *_16s_input.rds > spieceasi_16s_infiles.txt
ls *_its_input.rds > spieceasi_its_infiles.txt
ls *_metab_input.rds > spieceasi_metab_infiles.txt

# output files
cp spieceasi_16s_infiles.txt spieceasi_outfiles.txt
sed -i -E "s/\_16s_input.rds/\_spieceasi_results.rds/g" spieceasi_outfiles.txt
