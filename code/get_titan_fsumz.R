#!/usr/bin/env Rscript --vanilla

# name : get_titan_fsumz.R
# author: William Argiroff
# inputs : titan2 output data (ASVs and metadata) split by habitat and site
# output : text file of fsumz values
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/titan/*/<RE or RH or BS>_titan_output.rds
#   and output data/processed/titan/titan_fsumz.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

source("code/functions.R")

# List names
titan_output_names <- clargs[1 : (length(clargs) - 1)] %>%
  get_TITAN_list_names(.)

#### Get TITAN sumz, inner ####

get_TITAN_sumz_inner <- function(x) {
  
  tmp1 <- x$sumz.cp %>%
    as.data.frame(.) %>%
    as_tibble(rownames = NA) %>%
    rownames_to_column(var = "variable") %>%
    
    # Select columnds
    select(variable, cp, `0.05`, `0.95`) %>%
    rename(
      lci = "0.05",
      uci = "0.95"
    )
  
  return(tmp1)
  
}

#### Get TITAN sumz outer ####

get_TITAN_sumz <- function(x) {
  
  tmp1 <- map(x, .f = get_TITAN_sumz_inner) %>%
    bind_rows(.id = "site") %>%
    mutate(site = str_remove(site, "site_"))
  
  return(tmp1)
  
}

# Get fsumz as one tibble
titan_output <- clargs[1 : (length(clargs) - 1)] %>%
  map(., .f = read_rds) %>%
  set_names(nm = titan_output_names) %>%
  map(., get_TITAN_sumz) %>%
  
  # Combine
  bind_rows(.id = "ID") %>%
  format_TITAN_outputs(.)

# Save
write_tsv(
  titan_output,
  clargs[length(clargs)]
)
