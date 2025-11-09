#!/usr/bin/env Rscript --vanilla

# name : make_dbrda_fig.R
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
asv_dbrda <- clargs[1:6] %>%
  map(., .f = read_rds)

#### Function to format dbRDA ANOVAs ####

# format_dbRDA_aov <- function(x) {
  
#   aov_results <- x %>%
#     select(variable, `Pr(>F)`) %>%
#     filter(variable != "Residual") %>%
    
#     mutate(
      
#       variable = ifelse(
#         variable == "tree_age_site",
#         "Age",
#         variable
#       ),
      
#       variable = ifelse(
#         variable == "site",
#         "Stand",
#         variable
#       ),
      
#       variable = ifelse(
#         variable == "tree_age_site:site",
#         "Age%*%stand",
#         variable
#       ),
      
#       `Pr(>F)` = ifelse(
#         `Pr(>F)` == 0.001,
#         "italic(P)<0.001",
#         paste("italic(P)=", `Pr(>F)`, sep = "")
#       )
      
#     ) %>%
    
#     # Combine
#     unite(sig_label, variable, `Pr(>F)`, sep = "~") %>%
#     pull(sig_label)
  
#   # Add new lines
#   aov_out <- tibble(
#     sig_label = paste(aov_results, collapse = "\n")
#   )
  
#   return(aov_out)
  
# }

# Read in dbRDA ANOVAs
asv_aov <- clargs[7:12] %>%
  set_names(nm = c("BS_16S", "RE_16S", "RH_16S", "BS_ITS", "RE_ITS", "RH_ITS")) %>%
  map(., .f = read_tsv) %>%
  map(., .f = format_dbRDA_aov) %>%
  bind_rows(.id = "hab") %>%
  mutate(
    xpos = c(-1, 2, -1, -0.75, -2, -0.75),
    ypos = c(-1.5, 1.75, -1.5, 1.5, 2.5, 1.75)
  ) %>%
  group_by(hab) %>%
  group_split(.) %>%
  map(., .f = ungroup)

# Read in tree age
tree_age <- read_rds(clargs[19]) %>%
  pluck("age_df")
  
# Read in metadata
metadata <- clargs[13:18] %>%
  map(., .f = read_tsv) %>%
  map(.f = inner_join, ., tree_age, by = "tree_id")

# Get dbRDA scores
asv_dbrda_scores <- map2(
  asv_dbrda,
  metadata,
  .f = get_dbRDA_scores
)

# Plot dbRDA
asv_dbrda_figs <- pmap(
  list(
    asv_dbrda_scores,
    asv_aov,
    c("(a)", "(c)", "(e)", "(b)", "(d)", "(f)")
  ),
  .f = plot_dbRDA
)

# Get legend
dbrda_legend <- get_plot_component(
  asv_dbrda_figs[[1]],
  "guide-box-bottom",
  return_all = TRUE
)

# Plots
dbrda_grid <- plot_grid(
  asv_dbrda_figs[[1]] + theme(legend.position = "none"),
  asv_dbrda_figs[[4]] + theme(legend.position = "none"),
  asv_dbrda_figs[[2]] + theme(legend.position = "none"),
  asv_dbrda_figs[[5]] + theme(legend.position = "none"),
  asv_dbrda_figs[[3]] + theme(legend.position = "none"),
  asv_dbrda_figs[[6]] + theme(legend.position = "none"),
  nrow = 3,
  ncol = 2,
  align = "hv"
)

# Final
dbrda_out <- plot_grid(
  dbrda_grid,
  dbrda_legend,
  nrow = 2,
  ncol = 1,
  rel_heights = c(1, 0.1)
)

# Save
write_rds(
  dbrda_out,
  clargs[length(clargs)]
)
