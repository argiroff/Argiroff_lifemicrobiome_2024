#!/usr/bin/env Rscript --vanilla

# name : run_hill_lmm.R
# author: William Argiroff
# inputs : .txt of Hill numbers
# output : summarized LM
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/dbrda/<RE or RH or BS>_hill_div.txt
#   and output data/processed/<16S or ITS>/dbrda/<RE or RH or BS>_hill_lmm.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(emmeans)

# Prepare input data
hill_div <- read_tsv(clargs[1]) %>%
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

# Slopes comparisons
hill_lm_slopes_pairs <- map(
  hill_lm_slopes,
  .f = pairs
)

# Slopes comparisons summary
hill_lm_slopes_pairs_summary <- map(
  hill_lm_slopes_pairs,
  .f = summary
)



print(hill_lm_slopes_pairs_summary)