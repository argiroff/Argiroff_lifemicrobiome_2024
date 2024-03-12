#!/usr/bin/env Rscript --vanilla

# name : get_titan_input.R
# author: William Argiroff
# inputs : subsampled OTU data split by habitat, corresponding metadata table
# output : titan2 input data (OTUs and metadata) split by habitat
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_sub_otu.txt
#   data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_sub_metadata.txt
#   and output data/processed/<16S or ITS>/titan/<RE or RH or BS>_titan_input.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

source("code/functions.R")

# Metadata
metadata <- clargs[2 : 3] %>%
  map(., .f = read_tsv) %>%
  bind_rows(.) %>%
  select(-c(sample_id, plant_habitat, community)) %>%
    distinct(.)

# Tree age
tree_age <- read_rds(clargs[4]) %>%
  pluck("age_df")

# Metabolites
metabolites <- read_tsv(clargs[1]) %>%
  select(-metabolite) %>%
  # Split by site
  inner_join(metadata, ., by = "tree_id") %>%
  inner_join(tree_age, ., by = "tree_id") %>%
  group_by(site) %>%
  group_split(.) %>%
  map(., .f = ungroup) %>%
  set_names(nm = c("site_A", "site_B", "site_D", "site_H")) %>%
  
  # Filter out missing metabolites
  map(., .f = drop_0conc_metab) %>%
  map(., .f = drop_0conc_trees)

#### Format TITAN metabolite input ####

format_titan_metab_input <- function(x) {
  
  # Metabolites
  tmp1 <- x %>%
    select(tree_id, metabolite_id, concentration) %>%
    
    # Wide format
    pivot_wider(
      id_cols = tree_id,
      names_from = "metabolite_id",
      values_from = "concentration",
      values_fill = 0
    ) %>%
    
    # Sort
    arrange(tree_id) %>%
    column_to_rownames(var = "tree_id") %>%
    as.data.frame(.)
  
  # Get sample ID order
  tmp2 <- rownames(tmp1)
  
  # Environment data
  tmp3 <- x %>%
    select(tree_id, dbh, tree_age_full, tree_age_site) %>%
    distinct(.) %>%
    arrange(match(tree_id, tmp2)) %>%
    column_to_rownames(var = "tree_id") %>%
    as.data.frame(.)
  
  # Combine
  tmp4 <- list(tmp1, tmp3) %>%
    set_names(nm = c("metab_df", "env_df"))
  
  return(tmp4)
  
}

# Metabolites
titan_metab_input <- metabolites %>%
  map(., .f = format_titan_metab_input)

# Save
write_rds(
  titan_metab_input,
  clargs[5]
)
