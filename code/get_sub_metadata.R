#!/usr/bin/env Rscript --vanilla

# name : get_sub_metadata.R
# author: William Argiroff
# inputs : tibble of subsampled OTU relative abundances (SRS)
#   tibble of metadata
# output : tibble of metadata matching samples in subsampled OTU table
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_otu.txt
#   data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_metadata.txt
#   and output data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_sub_metadata.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Get sample ID filter
sample_id_filter <- read_tsv(clargs[1]) %>%
  select(sample_id) %>%
  distinct(.) %>%
  pull(sample_id)

# Trim metadata
metadata <- read_tsv(clargs[2]) %>%
  filter(sample_id %in% sample_id_filter)

# Save
write_tsv(
  metadata,
  clargs[3]
)
