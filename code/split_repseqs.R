#!/usr/bin/env Rscript --vanilla

# name : split_metadata.R
# author: William Argiroff
# inputs : representative sequence fasta, split otu table
# output : fasta for a specific habitat
# notes : expects order of inputs, output
#   expects input paths for data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_otu.txt
#   and output data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_representative_sequences.fasta

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Get OTU ID filter based on OTU table
otu_id_filter <- read_tsv(clargs[2]) %>%
  select(otu_id) %>%
  distinct(.) %>%
  pull(otu_id)

# Repseqs
repseqs <- Biostrings::readDNAStringSet(
  filepath = clargs[1],
  format = "fasta"
)

repseqs_out <- repseqs[otu_id_filter]

# Save
Biostrings::writeXStringSet(
  repseqs_out,
  filepath = clargs[3],
  format = "fasta"
)
