#!/usr/bin/env Rscript --vanilla

# name : split_metadata.R
# author: William Argiroff
# inputs : taxonomy tibble, split otu table
# output : taxonomy tibble for a specific habitat
# notes : expects order of inputs, output
#   expects input paths for data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_otu.txt
#   and output data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_taxonomy.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Get OTU ID filter based on OTU table
otu_id_filter <- read_tsv(clargs[2]) %>%
  select(otu_id) %>%
  distinct(.) %>%
  pull(otu_id)

# Taxonomy
taxonomy <- read_tsv(clargs[1]) %>%
  filter(otu_id %in% otu_id_filter)

# Save
write_tsv(
  taxonomy,
  clargs[3]
)
