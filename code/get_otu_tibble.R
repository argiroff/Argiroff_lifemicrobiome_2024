#!/usr/bin/env Rscript --vanilla

# name : get_otu_tibble.R
# author: William Argiroff
# inputs : Trimmed phyloseq object
# output : OTU table as a 3 column tibble
# notes : expects order of inputs, output
#   expects input paths for otu_processed/ps_trimmed.rds
#   and output data/processed/<16S or ITS>/otu_processed/otu_tibble.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(phyloseq)

ps <- read_rds(clargs[1])

# OTU table, long format
otu <- otu_table(ps) %>%
  
  as.data.frame(.) %>%

  as_tibble(rownames = NA) %>%
  
  rownames_to_column(var = "otu_id") %>%
  
  pivot_longer(
    -otu_id,
    names_to = "sample_id",
    values_to = "n_seqs"
  ) %>%
  
  select(sample_id, otu_id, n_seqs)

# Save
write_tsv(
  otu,
  file = clargs[2]
)
