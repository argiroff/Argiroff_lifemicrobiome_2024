#!/usr/bin/env Rscript --vanilla

# name : run_dbrda.R
# author: William Argiroff
# inputs : subsampled ASV table and corresponding metadata
# output : .rds of dbRDA ordination
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_sub_asv.txt
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_sub_metadata.txt
#   and output data/processed/<16S or ITS>/dbrda/<RE or RH or BS>_dbrda.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(vegan)

# ASV data
asv <- read_tsv(clargs[1]) %>%
  pivot_wider(
    id_cols = sample_id,
    names_from = "asv_id",
    values_from = "n_seqs",
    values_fill = 0
  ) %>%
  
  # Order
  arrange(sample_id) %>% 
  column_to_rownames(var = "sample_id") %>%
  as.data.frame(.)

# Sample ID filter
sample_id_filter <- rownames(asv)

# Metadata
metadata <- read_tsv(clargs[2])

# Add tree age data
env <- read_rds(clargs[3]) %>%
  pluck("age_df") %>%
  inner_join(metadata, ., by = "tree_id") %>%
  filter(sample_id %in% sample_id_filter) %>%
  arrange(match(sample_id, rownames(asv)))

# Run dbRDA
dbrda_output <- capscale(
  asv ~ tree_age_full * site,
  data = env,
  distance = "bray",
  sqrt.dist = TRUE
)

# Save
write_rds(
  dbrda_output,
  clargs[4]
)
