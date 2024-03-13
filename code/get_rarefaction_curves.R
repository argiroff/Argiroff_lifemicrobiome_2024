#!/usr/bin/env Rscript --vanilla

# name : get_rarefaction_curves.R
# author: William Argiroff
# inputs : habitat specific non-subsampled ASV table
# output : tibble of rarefaction curve results
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_asv.txt 
#   and output data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_rarefaction_curves.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(vegan)

source("code/functions.R")

# ASV input
asv_input <- read_tsv(clargs[1]) %>%
  
  # Drop low seq (< 100 reads) samples
  group_by(sample_id) %>%
  mutate(sample_n_seqs = sum(n_seqs)) %>%
  ungroup() %>%
  filter(sample_n_seqs > 100) %>%
  select(-sample_n_seqs) %>%
  drop_0seq_asvs(.) %>%
  
  # Wide format data frame
  pivot_wider(
    id_cols = sample_id,
    names_from = "asv_id",
    values_from = "n_seqs",
    values_fill = 0
  ) %>%
  column_to_rownames(var = "sample_id") %>%
  as.data.frame(.)

# Rarefaction curve
print("Generating rarefaction curves...")
rarefaction <- rarecurve(asv_input, step = 100)

# Format results
rarefaction_results <- map_dfr(rarefaction, bind_rows) %>% 
  bind_cols(sample_id = rownames(asv_input), .) %>% 
  
  # Long format
  pivot_longer(
    -sample_id, 
    names_to = "n_seqs", 
    values_to = "n_asvs"
  ) %>% 
  drop_na() %>% 
  mutate(n_seqs = as.numeric(str_replace(n_seqs, "N", "")))

# Save
write_tsv(
  rarefaction_results,
  clargs[2]
)

file.remove("Rplots.pdf")
