#!/usr/bin/env Rscript --vanilla

# name : get_sub_asv.R
# author: William Argiroff
# inputs : ASV tables split by habitat
# output : tibble of subsampled ASV relative abundances (SRS)
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_asv.txt 
#   and output data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_sub_asv.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(SRS)

source("code/functions.R")

# Get sequence cutoff
if(str_detect(clargs[2], "16S/asv_processed/BS_sub_asv.txt")) {
  
  seq_cutoff <- 18000
  
} else if(str_detect(clargs[2], "16S/asv_processed/RE_sub_asv.txt")) {
  
  seq_cutoff <- 2000
  
} else if(str_detect(clargs[2], "16S/asv_processed/RH_sub_asv.txt")) {
  
  seq_cutoff <- 22000
  
} else if(str_detect(clargs[2], "ITS/asv_processed/BS_sub_asv.txt")) {
  
  seq_cutoff <- 9000
  
} else if(str_detect(clargs[2], "ITS/asv_processed/RE_sub_asv.txt")) {
  
  seq_cutoff <- 1000
  
} else if(str_detect(clargs[2], "ITS/asv_processed/RH_sub_asv.txt")) {
  
  seq_cutoff <- 4000
  
} else {
  
  seq_cutoff <- 0
  
}

# Format ASV table for SRS input
asv_trim <- read_tsv(clargs[1]) %>%
  
  # Trim samples by sequence cutoff
  group_by(sample_id) %>%
  mutate(sample_n_seqs = sum(n_seqs)) %>%
  ungroup(.) %>%
  filter(sample_n_seqs > seq_cutoff) %>%
  drop_0seq_asvs(.)

# Wide format
asv_in <- asv_trim %>%
  select(-sample_n_seqs) %>%
  pivot_wider(
    id_cols = asv_id,
    names_from = "sample_id",
    values_from = "n_seqs",
    values_fill = 0
  ) %>%
  column_to_rownames(var = "asv_id") %>%
  as.data.frame(.)

# Get sequence minimum for subsampling
seq_min <- asv_trim %>%
  select(sample_id, sample_n_seqs) %>%
  distinct(.) %>%
  summarise(min_n_seqs = min(sample_n_seqs)) %>%
  pull(min_n_seqs)

# Subsample
asv_sub <- SRS(asv_in, Cmin = seq_min, set_seed = TRUE, seed = 12345)
rownames(asv_sub) <- rownames(asv_in)

# Format output
asv_out <- as_tibble(asv_sub, rownames = NA) %>% 
  rownames_to_column(var = "asv_id") %>% 
  
  # Long format
  pivot_longer(
    -asv_id,
    names_to = "sample_id",
    values_to = "n_seqs"
  ) %>%
  
  # Drop ASVs with no sequences
  drop_0seq_asvs(.)

# Save
write_tsv(
  asv_out,
  clargs[2]
)
