#!/usr/bin/env Rscript --vanilla

# name : get_sub_repseqs.R
# author: William Argiroff
# inputs : tibble of subsampled ASV relative abundances (SRS)
#   fasta of representative sequences
# output : fasta of representative sequences matching ASVs in subsampled OTU table
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>asv.txt
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_representative_sequences.fasta
#   and output data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_sub_representative_sequences.fasta

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Get ASV ID filter
asv_id_filter <- read_tsv(clargs[1]) %>%
  select(asv_id) %>%
  distinct(.) %>%
  pull(asv_id)

# Trim representative sequences
repseqs <- Biostrings::readDNAStringSet(
  filepath = clargs[2],
  format = "fasta"
)

repseqs_out <- repseqs[asv_id_filter]

# Save
Biostrings::writeXStringSet(
  repseqs_out,
  filepath = clargs[3],
  format = "fasta"
)
