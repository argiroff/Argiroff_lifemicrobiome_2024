#!/usr/bin/env Rscript --vanilla

# name : tree_age.R
# author: William Argiroff
# inputs : tree age metadata file
# output : list with lm and tree age with interpolated values

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Filter for non-poplar samples
tree_id_filter <- read_tsv(clargs[1]) %>%
  select(tree_id) %>%
  distinct(.) %>%
  pull(tree_id)

# Read in
tree_age_raw <- read_tsv(clargs[2]) %>%
  filter(tree_id %in% tree_id_filter)

# Get data for age-DBH relationship
tree_age_dbh <- tree_age_raw %>%
  filter(!is.na(tree_age)) %>%
  filter(!grepl("Sap", tree_id))

# Get data for interpolation
tree_age_unk <- tree_age_raw %>%
  filter(is.na(tree_age)) %>%
  filter(!grepl("Sap", tree_id)) %>%
  select(tree_id, dbh)

# LM
age_dbh_lm <- lm(tree_age ~ poly(dbh, 2), data = tree_age_dbh)

# Get interpolation
age_dbh_interp <- tibble(
  tree_id = tree_age_unk$tree_id,
  tree_age_full = round(predict(age_dbh_lm, newdata = tree_age_unk), 0)
)

# Combine
tree_age_full <- tree_age_raw %>%
  full_join(., age_dbh_interp, by = "tree_id") %>%
  
  # Update data
  mutate(
    
    value_type = ifelse(is.na(tree_age_full), "Observed", "Interpolated"),
    value_type = factor(
      value_type,
      levels = c("Observed", "Interpolated")
    ),
    
    tree_age_full = ifelse(is.na(tree_age_full), tree_age, tree_age_full)
    
  ) %>%
  
  # Calculate min and max
  group_by(value_type) %>%
  mutate(
    min_dbh = min(dbh, na.rm = TRUE),
    max_dbh = max(dbh, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  mutate(
    min_dbh = max(min_dbh),
    max_dbh = min(max_dbh)
  ) %>%
  
  # Trim
  select(
    tree_id,
    tree_age,
    tree_age_full,
    value_type,
    min_dbh,
    max_dbh
  )

# Create list
tree_age_out <- list(
  age_dbh_lm,
  tree_age_full
) %>%
  set_names(nm = c("age_lm", "age_df"))

# Save
write_rds(
  tree_age_out,
  clargs[3]
)
