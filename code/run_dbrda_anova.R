#!/usr/bin/env Rscript --vanilla

# name : run_dbrda_anova.R
# author: William Argiroff
# inputs : subsampled ASV table and corresponding metadata
# output : .rds of dbRDA ordination
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_sub_asv.txt
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_sub_metadata.txt
#   and output data/processed/<16S or ITS>/dbrda/<RE or RH or BS>_dbrda.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(vegan)

# Read in dbrda
dbrda_input <- read_rds(clargs[1])

# Run ANOVA
dbrda_anova <- anova.cca(
  dbrda_input,
  permutations = 999,
  model = "reduced",
  by = "terms",
  parallel = 10
)

# ANOVA output
dbrda_anova_out <- dbrda_anova %>%
  as.data.frame(.) %>%
  as_tibble(rownames = NA) %>%
  rownames_to_column(var = "variable")

# Save
write_tsv(
  dbrda_anova_out,
  clargs[2]
)
