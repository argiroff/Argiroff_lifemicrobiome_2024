#!/usr/bin/env Rscript --vanilla

# name : get_sub_taxonomy.R
# author: William Argiroff
# inputs : tibble of subsampled ASV relative abundances (SRS)
#   tibble of taxonomy
# output : tibble of taxonomy matching ASVs in subsampled OTU table
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_asv.txt
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_taxonomy_table.txt
#   and output data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_sub_taxonomy_table.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Get ASV ID filter
asv_id_filter <- read_tsv(clargs[1]) %>%
  select(asv_id) %>%
  distinct(.) %>%
  pull(asv_id)

# Trim taxonomy
taxonomy <- read_tsv(clargs[2]) %>%
  filter(asv_id %in% asv_id_filter)

# Save
write_tsv(
  taxonomy,
  clargs[3]
)
