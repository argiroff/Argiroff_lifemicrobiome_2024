#!/usr/bin/env Rscript --vanilla

# name : make_hill_fig.R
# author: William Argiroff
# inputs : habitat specific Hill diversity and LM
# output : R data object of Hill diversity plot
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_hill_div.txt
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_hill_lm.rds
#   and output results/rarefaction_curve_fig.rds

clargs <- commandArgs(trailingOnly = TRUE)

print(clargs)