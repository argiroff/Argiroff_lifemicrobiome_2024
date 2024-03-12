#!/usr/bin/env Rscript --vanilla

# name : run_titan.R
# author: William Argiroff
# inputs : titan2 input data (OTUs and metadata) split by habitat and site
# output : titan2 output data (OTUs and metadata) split by habitat and site
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/titan/<RE or RH or BS>_titan_input.rds
#   and output data/processed/<16S or ITS>/titan/<RE or RH or BS>_titan_output.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(TITAN2)

# Read in data
titan_input <- read_rds(clargs[1])

#### Function to run TITAN by site, inner function ####

site_TITAN <- function(x, y) {
  
  print(paste("Running TITAN2 for site ", y, "...", sep = ""))
  
  tmp1 <- titan(
    x$env_df$tree_age_site,
    x$otu_df,
    minSplt = 5,
    numPerm = 1000,
    boot = TRUE,
    nBoot = 1000,
    imax = FALSE,
    ivTot = FALSE,
    pur.cut = 0.7,
    rel.cut = 0.7,
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
