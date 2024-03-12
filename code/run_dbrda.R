#!/usr/bin/env Rscript --vanilla

# name : run_dbrda.R
# author: William Argiroff
# inputs : subsampled OTU table and corresponding metadata
# output : .rds of dbRDA ordination
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_sub_otu.txt
#   data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_sub_metadata.txt
#   and output data/processed/<16S or ITS>/dbrda/<RE or RH or BS>_dbrda.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(vegan)

# OTU data
otu <- read_tsv(clargs[1]) %>%
  pivot_wider(
    id_cols = sample_id,
    names_from = "otu_id",
    values_from = "n_seqs",
    values_fill = 0
  ) %>%
  
  # Order
  arrange(sample_id) %>% 
  column_to_rownames(var = "sample_id") %>%
  as.data.frame(.)

# Sample ID filter
sample_id_filter <- rownames(otu)

# Metadata
metadata <- read_tsv(clargs[2])

# Add tree age data
env <- read_rds(clargs[3]) %>%
  pluck("age_df") %>%
  inner_join(metadata, ., by = "tree_id") %>%
  filter(sample_id %in% sample_id_filter) %>%
  arrange(match(sample_id, rownames(otu)))

# Run dbRDA
dbrda_output <- capscale(
  otu ~ tree_age_site * site,
  data = env,
  distance = "bray",
  sqrt.dist = TRUE
)

# Save
write_rds(
  dbrda_output,
  clargs[4]
)
