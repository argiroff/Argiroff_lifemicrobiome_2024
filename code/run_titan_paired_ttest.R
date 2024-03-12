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

# Format input data
titan_fsumz <- read_tsv(clargs[1]) %>%
  arrange(variable, community, plant_habitat, site) %>%
  select(-lci, -uci) %>%
  pivot_wider(
    names_from = "variable",
    values_from = "cp"
  )

# t test
fsumz_t_test <- t.test(
  titan_fsumz$Decreasing,
  titan_fsumz$Increasing,
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

# Save
write_tsv(
  fsumz_t_test,
  clargs[2]
)
