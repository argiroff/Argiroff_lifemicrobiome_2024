#!/usr/bin/env Rscript --vanilla

# name : get_combined_asv_metab_table.R
# author: William Argiroff
# inputs : Full 16S, ITS, and metabolite tables and metadata
# output : combined 16S, ITS, metabolite table with matching sample_id/tree_id
# notes : expects order of inputs, output
#   expects input paths for 
#   metadata 16s, metadata its, asv 16s, asv its, metabolites
#   and output data/processed/spieceasi/comb_16s_its_metab.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Metadata
metadata_16s <- read_tsv(clargs[1]) %>%
  mutate(sample_id2 = str_remove(sample_id, "-16S"))

metadata_its <- read_tsv(clargs[2]) %>%
  mutate(
    sample_id2 = str_remove(sample_id, "-ITS"),
    sample_id2 = str_replace(sample_id2, "-Sap-", "Sap")
  )

# Sample id2 filter
sample_id2_filter <- metadata_16s %>%
  select(sample_id2) %>%
  inner_join(., metadata_its, by = "sample_id2") %>%
  select(sample_id2) %>%
  pull(sample_id2)

# Tree ID filter
tree_id_filter <- read_tsv(clargs[5]) %>%
  
  # Match to 16S
  select(tree_id) %>%
  distinct(.) %>%
  inner_join(., metadata_16s, by = "tree_id") %>%
  
  # Match to ITS
  select(tree_id) %>%
  distinct(.) %>%
  inner_join(., metadata_its, by = "tree_id") %>%
  
  # Get ID
  select(tree_id) %>%
  distinct(.) %>%
  pull(tree_id)

# 16S sample ID filter
sample_id_filter_16s <- metadata_16s %>%
  filter(sample_id2 %in% sample_id2_filter) %>%
  filter(tree_id %in% tree_id_filter) %>%
  select(sample_id) %>%
  distinct(.) %>%
  pull(sample_id)

# ITS sample ID filter
sample_id_filter_its <- metadata_its %>%
  filter(sample_id2 %in% sample_id2_filter) %>%
  filter(tree_id %in% tree_id_filter) %>%
  select(sample_id) %>%
  distinct(.) %>%
  pull(sample_id)

# 16S ASV
asv_16s <- read_tsv(clargs[3]) %>%
  filter(sample_id %in% sample_id_filter_16s) %>%
  inner_join(metadata_16s, ., by = "sample_id") %>%
  mutate(data_type = "16S") %>%
  select(data_type, plant_habitat, sample_id, tree_id, asv_id, n_seqs) %>%
  rename(
    feature_id = "asv_id",
    relabund = "n_seqs"
  )

# ITS ASV
asv_its <- read_tsv(clargs[4]) %>%
  filter(sample_id %in% sample_id_filter_its) %>%
  inner_join(metadata_its, ., by = "sample_id") %>%
  mutate(data_type = "ITS") %>%
  select(data_type, plant_habitat, sample_id, tree_id, asv_id, n_seqs) %>%
  rename(
    feature_id = "asv_id",
    relabund = "n_seqs"
  )

# Metabolites
metabolites <- read_tsv(clargs[5]) %>%
  filter(tree_id %in% tree_id_filter) %>%
  mutate(
    sample_id = NA,
    plant_habitat = NA,
    data_type = "Metabolites"
  ) %>%
  select(data_type, plant_habitat, sample_id, tree_id, metabolite_id, concentration) %>%
  rename(
    feature_id = "metabolite_id",
    relabund = "concentration"
  )

# Combine
comb_asv_metab <- bind_rows(
  asv_16s,
  asv_its,
  metabolites
)

# Save
write_tsv(
  comb_asv_metab,
  clargs[6]
)
