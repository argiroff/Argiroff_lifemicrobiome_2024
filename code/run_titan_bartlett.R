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

source("code/functions.R")

# List names
titan_fsumz_names <- read_tsv(clargs[1]) %>%
  mutate(cutoff = ifelse(str_detect(variable, "f"), cutoff, 0)) %>%
  select(cutoff) %>%
  distinct(.) %>%
  pull(cutoff)

# Input data
titan_fsumz <- read_tsv(clargs[1]) %>%
  format_fsumz(.) %>%
  
  # Split
  group_by(cutoff) %>%
  group_split(.) %>%
  map(., .f = ungroup) %>%
  set_names(nm = titan_fsumz_names)

#### Function to run Bartlett test ####

run_bartlett <- function(x) {
  
  # Arrange by variables
  tmp1 <- x %>%
    arrange(cutoff, variable, community, plant_habitat, site)
  
  # Test
  tmp2 <- bartlett.test(
    cp ~ variable,
    data = tmp1
  ) %>%
    
    # Extract results
    map(., .f = `[`) %>%
    bind_rows(.) %>%
    rename(
      `Bartlett's K-squared` = "statistic"
    )
  
  # Return
  return(tmp2)
  
}

# Test
fsumz_bartlett <- titan_fsumz %>%
  map(., .f = run_bartlett) %>%
  bind_rows(., .id = "cutoff")

# Save
write_tsv(
  fsumz_bartlett,
  clargs[2]
)
