#!/usr/bin/env Rscript --vanilla

# name : hill_lm_table.R
# author: William Argiroff
# inputs : .rds of Hill LM
# output : compiled table for supporting information
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/dbrda/<RE or RH or BS>_hill_lm.rds
#   and output results/hill_lm_table.rds

# clargs <- commandArgs(trailingOnly = TRUE)
clargs <- c(
  "data/processed/16S/hill_div/BS_hill_lm.rds",
  "data/processed/16S/hill_div/RE_hill_lm.rds",
  "data/processed/16S/hill_div/RH_hill_lm.rds",
  "data/processed/ITS/hill_div/BS_hill_lm.rds",
  "data/processed/ITS/hill_div/RE_hill_lm.rds",
  "data/processed/ITS/hill_div/RH_hill_lm.rds",
  "hill_lm_table.rds"
)

# Packages
library(tidyverse)

# Names
list_names <- clargs[1:6] %>%
  str_remove(., "data/processed/") %>%
  str_remove(., "hill_div/") %>%
  str_remove(., "_hill_lm.rds") %>%
  str_replace(., "\\/", "_")

# Read in
hill_lm <- map(
  clargs[1:6],
  .f = read_rds
) %>%
  set_names(nm = list_names)
