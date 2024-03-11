#!/usr/bin/env Rscript --vanilla

# name : get_sub_repseqs.R
# author: William Argiroff
# inputs : tibble of subsampled OTU relative abundances (SRS)
#   fasta of representative sequences
# output : fasta of representative sequences matching OTUs in subsampled OTU table
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_otu.txt
#   data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_representative_sequences.fasta
#   and output data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_sub_representative_sequences.fasta

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Get OTU ID filter
otu_id_filter <- read_tsv(clargs[1]) %>%
  select(otu_id) %>%
  distinct(.) %>%
  pull(otu_id)

# Trim representative sequences
repseqs <- Biostrings::readDNAStringSet(
  filepath = clargs[2],
  format = "fasta"
)

repseqs_out <- repseqs[otu_id_filter]

# Save
Biostrings::writeXStringSet(
  repseqs_out,
  filepath = clargs[3],
  format = "fasta"
)
