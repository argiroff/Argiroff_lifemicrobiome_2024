#!/usr/bin/env Rscript --vanilla

# name : get_sub_otu.R
# author: William Argiroff
# inputs : OTU tables split by habitat
# output : tibble of subsampled OTU relative abundances (SRS)
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_otu.txt 
#   and output data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_sub_otu.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(SRS)

source("code/functions.R")

# Get sequence cutoff
if(str_detect(clargs[2], "16S/otu_processed/BS_sub_otu.txt")) {
  
  seq_cutoff <- 18000
  
} else if(str_detect(clargs[2], "16S/otu_processed/RE_sub_otu.txt")) {
  
  seq_cutoff <- 2000
  
} else if(str_detect(clargs[2], "16S/otu_processed/RH_sub_otu.txt")) {
  
  seq_cutoff <- 22000
  
} else if(str_detect(clargs[2], "ITS/otu_processed/BS_sub_otu.txt")) {
  
  seq_cutoff <- 9000
  
} else if(str_detect(clargs[2], "ITS/otu_processed/RE_sub_otu.txt")) {
  
  seq_cutoff <- 1000
  
} else if(str_detect(clargs[2], "ITS/otu_processed/RH_sub_otu.txt")) {
  
  seq_cutoff <- 4000
  
} else {
  
  seq_cutoff <- 0
  
}

# Format OTU table for SRS input
otu_trim <- read_tsv(clargs[1]) %>%
  
  # Trim samples by sequence cutoff
  group_by(sample_id) %>%
  mutate(sample_n_seqs = sum(n_seqs)) %>%
  ungroup(.) %>%
  filter(sample_n_seqs > seq_cutoff) %>%
  drop_0seq_otus(.)

# Wide format
otu_in <- otu_trim %>%
  select(-sample_n_seqs) %>%
  pivot_wider(
    id_cols = otu_id,
    names_from = "sample_id",
    values_from = "n_seqs",
    values_fill = 0
  ) %>%
  column_to_rownames(var = "otu_id") %>%
  as.data.frame(.)

# Get sequence minimum for subsampling
seq_min <- otu_trim %>%
  select(sample_id, sample_n_seqs) %>%
  distinct(.) %>%
  summarise(min_n_seqs = min(sample_n_seqs)) %>%
  pull(min_n_seqs)

# Subsample
otu_sub <- SRS(otu_in, Cmin = seq_min, set_seed = TRUE, seed = 12345)
rownames(otu_sub) <- rownames(otu_in)

# Format output
otu_out <- as_tibble(otu_sub, rownames = NA) %>% 
  rownames_to_column(var = "otu_id") %>% 
  
  # Long format
  pivot_longer(
    -otu_id,
    names_to = "sample_id",
    values_to = "n_seqs"
  ) %>%
  
  # Drop OTUs with no sequences
  drop_0seq_otus(.)

# Save
write_tsv(
  otu_out,
  clargs[2]
)
