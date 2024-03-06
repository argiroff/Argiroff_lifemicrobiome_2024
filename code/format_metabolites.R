#!/usr/bin/env Rscript --vanilla

# name : format_metabolites.R
# author: William Argiroff
# inputs : metabolite data
# output : .txt file with long-format and filtered metabolite data

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Samples to drop
drop_id <- c(
  "BSap3",
  "B303",
  "B317",
  "B322",
  "B333",
  "D016",
  "H514",
  "H526",
  "H533",
  "H537"
)

# Read in data
metabolites <- read_tsv(clargs[1]) %>%
  
  # Add metabolite ID column
  mutate(metabolite_id = paste("metab", c(1 : n()), sep = "_")) %>%
  
  # Long format
  pivot_longer(
    -c(metabolite, metabolite_id),
    names_to = "tree_id",
    values_to = "relabund"
  ) %>%
  
  # Update tree ID
  mutate(tree_id = str_replace(tree_id, "-Sap-", "Sap")) %>%
  
  # Remove samples and unique metabolites that are not Populus
  filter(!(tree_id %in% drop_id)) %>%
  group_by(metabolite) %>%
  mutate(metab_total = sum(relabund)) %>%
  ungroup(.) %>%
  filter(metab_total > 0) %>%
  select(-metab_total)

# Save
write_tsv(
  metabolites,
  clargs[2]
)
