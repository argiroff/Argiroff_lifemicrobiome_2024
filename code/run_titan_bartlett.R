#!/usr/bin/env Rscript --vanilla

# name : run_titan_bartlett.R
# author: William Argiroff
# inputs : text file of fsumz values
# output : .txt of Bartlett test
# notes : expects order of inputs, output
#   expects input paths for data/processed/titan/titan_fsumz.txt
#   and output results/titan_bartlett.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Format input data
titan_fsumz <- read_tsv(clargs[1]) %>%
  arrange(variable, community, plant_habitat, site)

# Bartlett test
fsumz_bartlett <- bartlett.test(
  cp ~ variable,
  data = titan_fsumz
) %>%
  
  # Extract results
  map(., .f = `[`) %>%
  bind_rows(.) %>%
  rename(
    `Bartlett's K-squared` = "statistic"
  )

# Save
write_tsv(
  fsumz_bartlett,
  clargs[2]
)
