#!/usr/bin/env Rscript --vanilla

# name : get_input_for_spieceasi.R
# author: William Argiroff
# inputs : combined 16S, ITS, metabolite table with matching sample_id/tree_id
# output : 16S, ITS, metabolite tables by habitat with matching sample_id/tree_id
# notes : expects order of inputs, output
#   expects input paths for 
#   metadata 16s, metadata its, asv 16s, asv its, metabolites
#   and output data/processed/spieceasi/<bs, re, rh>_<16s, its, metab>_input.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

source("code/functions.R")

# Read in data
in_data <- read_tsv(clargs[1])

# Trim ASV/metabolite data
if(str_detect(clargs[2], "bs_16s_input.rds|bs_its_input.rds|bs_metab_input.rds")) {
  
  out_trimmed <- in_data %>%
    filter(plant_habitat == "Soil" | is.na(plant_habitat))
  
} else if(str_detect(clargs[2], "re_16s_input.rds|re_its_input.rds|re_metab_input.rds")) {
  
  out_trimmed <- in_data %>%
    filter(plant_habitat == "Root endosphere" | is.na(plant_habitat))
  
} else if(str_detect(clargs[2], "rh_16s_input.rds|rh_its_input.rds|rh_metab_input.rds")) {
  
  out_trimmed <- in_data %>%
    filter(plant_habitat == "Rhizosphere" | is.na(plant_habitat))
  
} else {
  
  out_trimmed <- in_data
  
}

# Clean up memory
rm(in_data)
gc()

# Split by data type
out_split <- out_trimmed %>%
  group_by(data_type) %>%
  group_split(.) %>%
  map(., .f = ungroup) %>%
  set_names(nm = c("BA", "FUNGI", "METAB")) %>%
  map(., .f = drop_0relabund_features) %>%
  map(., .f = drop_0relabund_trees)

# Filter features
out_filtered_temp <- pmap(
  list(out_split[1:2], 0.1, 100),
  .f = filter_features
) %>%
  map(., .f = drop_0relabund_features) %>%
  map(., .f = drop_0relabund_trees)

# Combine
out_filtered <- list(
  out_filtered_temp$BA,
  out_filtered_temp$FUNGI,
  out_split$METAB
) %>%
  set_names(nm = c("BA", "FUNGI", "METAB"))

# Clean up memory
rm(
  out_split,
  out_filtered_temp)

gc()

# Get tree filter
tree_id_filter <- get_tree_id_filter(
  out_filtered$BA,
  out_filtered$FUNGI,
  out_filtered$METAB
)

# Format final OTU table
if(str_detect(clargs[2], "_16s_input.rds")) {
  
  output <- out_filtered$BA %>%
    filter(tree_id %in% tree_id_filter) %>%
    arrange(match(tree_id, tree_id_filter))
  
} else if(str_detect(clargs[2], "_its_input.rds")) {
  
  output <- out_filtered$FUNGI %>%
    filter(tree_id %in% tree_id_filter) %>%
    arrange(match(tree_id, tree_id_filter))
  
} else if(str_detect(clargs[2], "_metab_input.rds")) {
  
  output <- out_filtered$METAB %>%
    filter(tree_id %in% tree_id_filter) %>%
    arrange(match(tree_id, tree_id_filter))
  
} else {
  
  output <- out_filtered
  
}

# Wide format
out_final <- output %>%
  select(tree_id, feature_id, relabund) %>%
  pivot_wider(
    id_cols = tree_id,
    names_from = "feature_id",
    values_from = "relabund",
    values_fill = 0
  ) %>%
  column_to_rownames(var = "tree_id") %>%
  as.data.frame(.) %>%
  as.matrix(.)

# Save OTU table
write_rds(
  out_final,
  file = clargs[2]
)
