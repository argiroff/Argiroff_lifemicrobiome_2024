#!/usr/bin/env Rscript --vanilla

# name : run_hill_lm.R
# author: William Argiroff
# inputs : .txt of Hill numbers
# output : summarized LM
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/dbrda/<RE or RH or BS>_hill_div.txt
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_sub_metadata.txt
#   data/processed/environ/tree_age_site.rds
#   and output data/processed/<16S or ITS>/dbrda/<RE or RH or BS>_hill_lm.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(emmeans)

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

# Run LM
hill_lm <- map(
  hill_div,
  .f = function(x) {
    lm(
      hill_value ~ tree_age_site * site,
      data = x
    )
  }
)

# Summary
hill_lm_summary <- map(
  hill_lm,
  .f = summary
)

# Slopes
hill_lm_slopes <- map(
  hill_lm,
  .f = function(x) {
    emtrends(x, "site", var = "tree_age_site")
  }
)

# Slopes summary
hill_lm_slopes_summary <- map(
  hill_lm_slopes,
  .f = function(x) {
    summary(x, infer = c(TRUE, TRUE))
  }
)

# Slopes comparisons with Tukey's adjustment
hill_lm_slopes_pairs <- map(
  hill_lm_slopes,
  .f = pairs
)

# Slopes comparisons summary
hill_lm_slopes_pairs_summary <- map(
  hill_lm_slopes_pairs,
  .f = summary
)

# Site means comparison
hill_lm_sites <- map(
  hill_lm,
  .f = function(x) {
    emmeans(x, "site")
  }
)

# Site means comparison summary
hill_lm_sites_summary <- map(
  hill_lm_sites,
  .f = function(x) {
    summary(x, infer = c(TRUE, TRUE))
  }
)

# Site means pairs
hill_lm_sites_pairs <- map(
  hill_lm_sites,
  .f = pairs
)

# Site means pairs summary
hill_lm_sites_pairs_summary <- map(
  hill_lm_sites_pairs,
  .f = summary
)

# Combine results
hill_lm_list <- list(
  hill_lm = hill_lm,
  hill_lm_summary = hill_lm_summary,
  hill_lm_slopes = hill_lm_slopes,
  hill_lm_slopes_summary = hill_lm_slopes_summary,
  hill_lm_slopes_pairs = hill_lm_slopes_pairs,
  hill_lm_slopes_pairs_summary = hill_lm_slopes_pairs_summary,
  hill_lm_sites = hill_lm_sites,
  hill_lm_sites_summary = hill_lm_sites_summary,
  hill_lm_sites_pairs = hill_lm_sites_pairs,
  hill_lm_sites_pairs_summary = hill_lm_sites_pairs_summary
)

# Save
write_rds(
  hill_lm_list,
  clargs[4]
)