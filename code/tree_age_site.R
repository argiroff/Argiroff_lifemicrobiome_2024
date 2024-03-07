#!/usr/bin/env Rscript --vanilla

# name : tree_age_site.R
# author: William Argiroff
# inputs : tree age metadata file
# output : list with lm by site and
#   tree age with interpolated values by site

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Filter for non-poplar samples
tree_id_filter <- read_tsv(clargs[1]) %>%
  select(tree_id) %>%
  distinct(.) %>%
  pull(tree_id)

# Read in
tree_age_raw <- read_tsv(clargs[2]) %>%
  filter(tree_id %in% tree_id_filter) %>%
  group_by(site) %>%
  group_split(.) %>%
  map(., .f = ungroup) %>%
  set_names(nm = c("A", "B", "D", "H"))

#### Get tree age data ####

get_tree_age <- function(x) {
  
  tmp1 <- x %>%
    filter(!is.na(tree_age)) %>%
    filter(!grepl("Sap", tree_id))
  
  return(tmp1)
  
}

# Split by site
tree_age_data <- tree_age_raw %>%
  map(., .f = get_tree_age)

#### Get age data for interpolation ####

get_age_unk <- function(x) {
  
  tmp1 <- x %>%
    filter(is.na(tree_age)) %>%
    filter(!grepl("Sap", tree_id)) %>%
    select(tree_id, dbh)
  
  return(tmp1)
  
}

# Get data for interpolation by site
tree_age_unk <- tree_age_raw %>%
  map(., .f = get_age_unk)

#### Get tree age LM ####

tree_age_lm <- function(x) {
  
  tmp1 <- lm(tree_age ~ dbh, data = x)
  
  return(tmp1)
  
}

# LM
age_dbh_lm <- tree_age_data %>%
  map(., .f = tree_age_lm)

#### Interpolate ages ####

interp_age <- function(x, y) {
  
  tmp1 <- tibble(
    tree_id = x$tree_id,
    tree_age_site = round(predict(y, newdata = x), 0)
  )
  
  return(tmp1)
  
}

# Read in full data
tree_age_full <- read_rds(file = clargs[3])

# Interpolate ages and combine with full data
tree_age_complete <- map2(
  tree_age_unk,
  age_dbh_lm,
  .f = interp_age
) %>%
  
  # Combine into single data frame and add full data
  bind_rows(.) %>%
  full_join(tree_age_full$age_df, ., by = "tree_id") %>%
  mutate(tree_age_site = ifelse(is.na(tree_age_site), tree_age, tree_age_site))

# Create output list
tree_age_out <- list(
  age_dbh_lm,
  tree_age_complete
) %>%
  set_names(nm = c("age_lm", "age_df"))

# Save
write_rds(
  tree_age_out,
  clargs[4]
)
