#!/usr/bin/env Rscript --vanilla

# name : get_sample_sequence_totals.R
# author: William Argiroff
# inputs : OTU tables split by habitat
# output : tibble of sequence totals by sample
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_otu.txt 
#   and output data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_sample_total.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

source("code/functions.R")

# Calculate sample total
sample_total <- read_tsv(clargs[1]) %>%
  group_by(sample_id) %>%
  summarise(n_seqs = sum(n_seqs)) %>%
  ungroup(.) %>%
  arrange(n_seqs)

# Save
write_tsv(
  sample_total,
  clargs[2]
)
