#!/usr/bin/env Rscript --vanilla

# name : run_dbrda_metabolies.R
# author: William Argiroff
# inputs : metabolite table, metadata, tree age
# output : .rds of dbRDA ordination
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/environ/root_metabolites.txt
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_sub_metadata.txt
#   and output data/processed/dbrda/metabolites_dbrda.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(vegan)

# Metadata
metadata <- read_tsv(clargs[2 : (length(clargs) - 2)]) %>%
  bind_rows(.) %>%
  select(tree_id, site) %>%
  distinct(.)

# Add tree age data
env <- read_rds(clargs[(length(clargs) - 1)]) %>%
  pluck("age_df") %>%
  inner_join(metadata, ., by = "tree_id") %>%
  arrange(tree_id)

# Tree ID filter
tree_id_filter <- env %>%
  pull(tree_id)

# Metabolite data
metabolites <- read_tsv(clargs[1]) %>%
  pivot_wider(
    id_cols = tree_id,
    names_from = "metabolite_id",
    values_from = "concentration",
    values_fill = 0
  ) %>%
  
  # Order
  filter(tree_id %in% tree_id_filter) %>%
  arrange(match(tree_id, rownames(env))) %>% 
  column_to_rownames(var = "tree_id") %>%
  as.data.frame(.)

# Run dbRDA
dbrda_output <- capscale(
  metabolites ~ tree_age_site * site,
  data = env,
  distance = "bray",
  sqrt.dist = TRUE
)

# Save
write_rds(
  dbrda_output,
  clargs[length(clargs)]
)
