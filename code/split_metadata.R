#!/usr/bin/env Rscript --vanilla

# name : split_metadata.R
# author: William Argiroff
# inputs : Metadata tibble, split otu table
# output : metadata tibble for a specific habitat
# notes : expects order of inputs, output
#   expects input paths for data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_otu.txt
#   and output data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_metadata.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Get sample ID filter based on OTU table
sample_id_filter <- read_tsv(clargs[2]) %>%
  select(sample_id) %>%
  distinct(.) %>%
  pull(sample_id)

# Filter metadata
metadata <- read_tsv(clargs[1]) %>%
  filter(sample_id %in% sample_id_filter)

# Save
write_tsv(
  metadata,
  clargs[3]
)
