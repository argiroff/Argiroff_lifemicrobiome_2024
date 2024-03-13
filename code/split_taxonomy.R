#!/usr/bin/env Rscript --vanilla

# name : split_metadata.R
# author: William Argiroff
# inputs : taxonomy tibble, split ASV table
# output : taxonomy tibble for a specific habitat
# notes : expects order of inputs, output
#   expects input paths for data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_asv.txt
#   and output data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_taxonomy.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Get ASV ID filter based on ASV table
asv_id_filter <- read_tsv(clargs[2]) %>%
  select(asv_id) %>%
  distinct(.) %>%
  pull(asv_id)

# Taxonomy
taxonomy <- read_tsv(clargs[1]) %>%
  filter(asv_id %in% asv_id_filter)

# Save
write_tsv(
  taxonomy,
  clargs[3]
)
