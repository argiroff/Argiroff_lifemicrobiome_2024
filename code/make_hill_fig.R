#!/usr/bin/env Rscript --vanilla

# name : make_hill_fig.R
# author: William Argiroff
# inputs : habitat specific Hill diversity and LM
# output : R data object of Hill diversity plot
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_hill_div.txt
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_hill_lm.rds
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_sub_metadata.txt
#   data/processed/environ/tree_age_site.rds
#   and output results/rarefaction_curve_fig.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(cowplot)
library(viridis)

source("code/functions.R")

# Read in Hill numbers
hill_div <- clargs[1:6] %>%
  map(., .f = read_tsv) %>%
  set_names(
    .,
    nm = c(
      "BS_16S", "RE_16S", "RH_16S",
      "BS_ITS", "RE_ITS", "RH_ITS"
    )
  ) %>%
  bind_rows(.id = "hab")

print(hill_div)