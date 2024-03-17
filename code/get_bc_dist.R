#!/usr/bin/env Rscript --vanilla

# name : get_bc_dist.R
# author: William Argiroff
# inputs : subsampled ASV table
# output : .rds of Bray-Curtis distance matrix from vegdist,
#   with accompanying metadata, tree age, and metabolite distance matrices
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_sub_otu.txt
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_sub_metadata.txt
#   data/processed/environ/tree_age_site.rds
#   and output data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_bc_dist.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(vegan)

source("code/functions.R")

# ASVs
asv <- read_tsv(clargs[1]) %>%
  
  # Wide format
  pivot_wider(
    id_cols = sample_id,
    names_from = "asv_id",
    values_from = "n_seqs",
    values_fill = 0
  ) %>%
  
  # Sort
  arrange(sample_id) %>%
  column_to_rownames(var = "sample_id") %>%
  as.data.frame(.)

# Metadata
metadata <- read_tsv(clargs[2])

# Add tree age
env <- read_rds(clargs[3]) %>%
  pluck("age_df") %>%
  inner_join(metadata, ., by = "tree_id")

# Extract tree age
age <- env %>%
  select(sample_id, tree_age_site) %>%
  arrange(sample_id) %>%
  column_to_rownames(var = "sample_id") %>%
  as.data.frame(.)

# Get sample ID filter
sample_id_filter <- env %>%
  select(sample_id, tree_id)

# Final env output
env_out <- env %>%
  arrange(sample_id) %>%
  column_to_rownames(var = "sample_id") %>%
  as.data.frame(.)

# Metabolites
metabolites <- read_tsv(clargs[4]) %>%
  inner_join(sample_id_filter, ., by = "tree_id") %>%
  drop_0conc_metab(.) %>%
  
  # Wide format
  select(sample_id, metabolite_id, concentration) %>%
  pivot_wider(
    id_cols = sample_id,
    names_from = "metabolite_id",
    values_from = "concentration",
    values_fill = 0
  ) %>%
  
  # Sort
  arrange(sample_id) %>%
  column_to_rownames(var = "sample_id") %>%
  as.data.frame(.)

# Distance matrices
asv_dist <- vegdist(asv, method = "bray")
metabolites_dist <- vegdist(metabolites, method = "bray")
age_dist <- vegdist(age, method = "euclidean")

# Final list of outputs
bc_dist <- list(
  asv,
  asv_dist,
  env_out,
  metabolites,
  metabolites_dist,
  age,
  age_dist
) %>%
  
  set_names(
    nm = c(
      "asv_df", "asv_dist", "env_df", 
      "metab_df", "metab_dist", "age_df", "age_dist"
    )
  )

# Save
write_rds(
  bc_dist,
  clargs[5]
)
