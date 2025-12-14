#!/usr/bin/env Rscript --vanilla

# name : run_hill_lmm.R
# author: William Argiroff
# inputs : .txt of Hill numbers
# output : summarized GLMM
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/dbrda/<RE or RH or BS>_hill_div.txt
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_sub_metadata.txt
#   data/processed/environ/tree_age_site.rds
#   and output data/processed/<16S or ITS>/dbrda/<RE or RH or BS>_hill_glmm.rds

# clargs <- commandArgs(trailingOnly = TRUE)
clargs <- c(
  "data/processed/16S/hill_div/RE_hill_div.txt",
  "data/processed/16S/asv_processed/RE_sub_metadata.txt",
  "data/processed/environ/tree_age_site.rds",
  "data/processed/16S/hill_div/RE_hill_glmm.rds" 
)

library(tidyverse)
library(lmerTest)

# Read in metadata
metadata <- read_tsv(clargs[2])

# Add tree age data
env <- read_rds(clargs[3]) %>%
  pluck("age_df") %>%
  inner_join(metadata, ., by = "tree_id")

# Prepare input data
hill_div <- read_tsv(clargs[1]) %>%
  inner_join(env, ., by = "sample_id") %>%
  mutate(site = factor(site, levels = c("A", "B", "D", "H"))) %>%
  group_by(hill_index) %>%
  group_split() %>%
  set_names(map_chr(., \(x) unique(x$hill_index))) %>%
  map(., .f = ungroup)

# Run LMM
hill_lmm <- map(
  hill_div,
  .f = function(x) {
    lmerTest::lmer(
      hill_value ~ tree_age_site + site + (1 + tree_age_site | site),
      data = x
    )
  }
)

# Summarize LMM
hill_lmm_summary <- map(
  hill_lmm,
  .f = summary
)

# ANOVA

