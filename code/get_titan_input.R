#!/usr/bin/env Rscript --vanilla

# name : get_titan_input.R
# author: William Argiroff
# inputs : subsampled OTU data split by habitat, corresponding metadata table
# output : titan2 input data (ASVs and metadata) split by habitat
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_sub_asv.txt
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_sub_metadata.txt
#   and output data/processed/<16S or ITS>/titan/<RE or RH or BS>_titan_input.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

source("code/functions.R")

# Metadata
metadata <- read_tsv(clargs[2])

tree_age <- read_rds(clargs[3]) %>%
  pluck("age_df")

# ASV data
asv <- read_tsv(clargs[1]) %>%
  
  # Split by site
  inner_join(metadata, ., by = "sample_id") %>%
  inner_join(tree_age, ., by = "tree_id") %>%
  group_by(site) %>%
  group_split(.) %>%
  map(., .f = ungroup) %>%
  set_names(nm = c("site_A", "site_B", "site_D", "site_H")) %>%
  
  # Filter out ASVs not present in at least 3 samples
  map(., .f = drop_0seq_asvs) %>%
  map2(., rep(3, 4), .f = trim_asv_pa) %>%
  map(., .f = drop_0seq_samples)

#### Format TITAN ASV input ####

format_titan_input <- function(x) {
  
  # ASV
  tmp1 <- x %>%
    select(sample_id, asv_id, n_seqs) %>%
    
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
  
  # Get sample ID order
  tmp2 <- rownames(tmp1)
  
  # Environment data
  tmp3 <- x %>%
    select(sample_id, tree_id, dbh, tree_age_full, tree_age_site) %>%
    distinct(.) %>%
    arrange(match(sample_id, tmp2)) %>%
    column_to_rownames(var = "sample_id") %>%
    as.data.frame(.)
  
  # Combine
  tmp4 <- list(tmp1, tmp3) %>%
    set_names(nm = c("asv_df", "env_df"))
  
  return(tmp4)
  
}

# ASV table
titan_input <- asv %>%
  map(., .f = format_titan_input)

# Save
write_rds(
  titan_input,
  clargs[4]
)
