#!/usr/bin/env Rscript --vanilla

# name : run_titan_paired_ttest.R
# author: William Argiroff
# inputs : text file of fsumz values
# output : text file of paired t-test
# notes : expects order of inputs, output
#   expects input paths for data/processed/titan/titan_fsumz.txt
#   and output results/titan_paired_ttest.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

source("code/functions.R")

# List names
titan_fsumz_names <- read_tsv(clargs[1]) %>%
  mutate(cutoff = ifelse(str_detect(variable, "f"), cutoff, 0)) %>%
  select(cutoff) %>%
  distinct(.) %>%
  pull(cutoff)

#### Function to run paired t-test ####

run_paired_t <- function(x) {
  
  # Format
  tmp1 <- x %>%
    arrange(cutoff, variable, community, plant_habitat, site) %>%
    
    # Wide format
    pivot_wider(
      names_from = "variable",
      values_from = "cp"
    )
  
  # t test
  tmp2 <- t.test(
    tmp1$Decreasing,
    tmp1$Increasing,
    mu = 0,
    paired = TRUE,
    var.equal = TRUE,
    conf.level = 0.95
  ) %>%
    
    # Extract results
    map(., .f = `[`) %>%
    bind_rows(.) %>%
    mutate(conf = c("lci", "uci")) %>%
    pivot_wider(
      names_from = "conf",
      values_from = "conf.int"
    )
  
  return(tmp2)
  
}

# Format input data
fsumz_t_test <- read_tsv(clargs[1]) %>%
  format_fsumz(.) %>%
  
  # Split
  group_by(cutoff) %>%
  group_split(.) %>%
  map(., .f = ungroup) %>%
  set_names(nm = titan_fsumz_names) %>%
  
  # Run t-test
  map(., .f = run_paired_t) %>%
  bind_rows(., .id = "cutoff")

# Save
write_tsv(
  fsumz_t_test,
  clargs[2]
)
