#!/usr/bin/env Rscript --vanilla

# name : split_metadata.R
# author: William Argiroff
# inputs : representative sequence fasta, split ASV table
# output : fasta for a specific habitat
# notes : expects order of inputs, output
#   expects input paths for data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_asv.txt
#   and output data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_representative_sequences.fasta

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Get ASV ID filter based on ASV table
asv_id_filter <- read_tsv(clargs[2]) %>%
  select(asv_id) %>%
  distinct(.) %>%
  pull(asv_id)

# Repseqs
repseqs <- Biostrings::readDNAStringSet(
  filepath = clargs[1],
  format = "fasta"
)

repseqs_out <- repseqs[asv_id_filter]

# Save
Biostrings::writeXStringSet(
  repseqs_out,
  filepath = clargs[3],
  format = "fasta"
)
