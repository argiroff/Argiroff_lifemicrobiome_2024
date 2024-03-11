#!/usr/bin/env Rscript --vanilla

# name : get_sub_taxonomy.R
# author: William Argiroff
# inputs : tibble of subsampled OTU relative abundances (SRS)
#   tibble of taxonomy
# output : tibble of taxonomy matching OTUs in subsampled OTU table
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_otu.txt
#   data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_taxonomy_table.txt
#   and output data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_sub_taxonomy_table.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Get OTU ID filter
otu_id_filter <- read_tsv(clargs[1]) %>%
  select(otu_id) %>%
  distinct(.) %>%
  pull(otu_id)

# Trim taxonomy
taxonomy <- read_tsv(clargs[2]) %>%
  filter(otu_id %in% otu_id_filter)

# Save
write_tsv(
  taxonomy,
  clargs[3]
)
