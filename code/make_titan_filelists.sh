#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=20:00:00
#SBATCH --mem-per-cpu=64G
#SBATCH --job-name=titan_list
#SBATCH --output=titan_list.out
#SBATCH -p batch
#SBATCH -A bsd

# name: make_titan_outfilelist.sh
# author: William Argiroff
# inputs: .txt file with list of titan input names
# output: .txt file with list of titan output names

cd /lustre/or-scratch/cades-bsd/7wa/Argiroff_lifemicrobiome_2024

# Get input files
infiles=`echo "$1"`
outfiles=`echo "$2"`

# Generate input file list
input=`ls data/processed/16S/titan/*_titan_input.rds`
input2=`echo "$input" | sed "s/.*\///"`
outdirs=`ls -d data/processed/*/titan/*/`

# Output
for i in $outdirs
do
    for j in $input2
    do
        echo "$i""$j"
    done
done > $outfiles

# Input files
cp $outfiles $infiles
sed -i "s/\_input.rds/\_output.rds/g" $infiles

echo "Done."