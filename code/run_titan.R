#!/usr/bin/env Rscript --vanilla

# name : run_titan.R
# author: William Argiroff
# inputs : titan2 input data (ASVs and metadata) split by habitat and site
# output : titan2 output data (ASVs and metadata) split by habitat and site
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/titan/<RE or RH or BS>_titan_input.rds
#   and output data/processed/<16S or ITS>/titan/<RE or RH or BS>_titan_output.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(TITAN2)

# Read in data
titan_input <- read_rds(clargs[1])

#### Function to convert to proportion ####

perc_to_prop <- function(x) {
  
  tmp1 <- x / 100
  
  return(tmp1)
  
}

# Get cutoff
titan_cutoff <- clargs[2] %>%
  str_remove(., "data/processed/16S/titan/|data/processed/ITS/titan/") %>%
  str_remove(., "/.*") %>%
  as.numeric(.) %>%
  perc_to_prop(.)

#### Function to run TITAN by site, inner function ####

site_TITAN <- function(x, y) {
  
  print(paste("Running TITAN2 for site ", y, "...", sep = ""))
  
  tmp1 <- titan(
    x$env_df$tree_age_full,
    x$asv_df,
    minSplt = 5,
    numPerm = 1000,
    boot = TRUE,
    nBoot = 1000,
    imax = FALSE,
    ivTot = FALSE,
    pur.cut = titan_cutoff,
    rel.cut = titan_cutoff,
    ncpus = 10,
    memory = FALSE
  )
  
  return(tmp1)
  
}

# Run TITAN2
titan_output <- map2(
  titan_input,
  c("A", "B", "D", "H"),
  .f = site_TITAN
)

# Save
write_rds(
  titan_output,
  clargs[2]
)
