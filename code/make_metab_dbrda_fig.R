#!/usr/bin/env Rscript --vanilla

# name : make_metab_dbrda_fig.R
# author: William Argiroff
# inputs : habitat specific dbRDA and dbRDA ANOVA
# output : R data object of rarefaction curve plot
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_rarefaction_curves.txt 
#   and output results/rarefaction_curve_fig.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(vegan)
library(cowplot)
library(viridis)

source("code/functions.R")

# Read in dbRDAs
metab_dbrda <- read_rds(clargs[1])

# Read in dbRDA ANOVAs
asv_aov <- read_tsv(clargs[2]) 
  format_dbRDA_aov(.) %>%
  mutate(
    xpos = -1,
    ypos = -1.5
  )

# Read in tree age
tree_age <- read_rds(clargs[4]) %>%
  pluck("age_df")

# Read in metadata
metadata <- read_tsv(clargs[3]) %>%
  inner_join(., tree_age, by = "tree_id")

# Get dbRDA scores
metab_dbrda_scores <- get_dbRDA_scores(
  asv_dbrda,
  metadata
)

# Plot dbRDA
dbrda_out <- plot_dbRDA(
  metab_dbrda_scores,
  # metab_aov,
  NULL
)

# Save
write_rds(
  dbrda_out,
  clargs[length(clargs)]
)
