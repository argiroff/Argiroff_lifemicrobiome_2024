#!/usr/bin/env Rscript --vanilla

# name : get_titan_otu.R
# author: William Argiroff
# inputs : titan2 output data (OTUs and metadata) split by habitat and site
#   subsampled taxonomy tables split by habitat
# output : text file of OTU responses with taxonomic assignments
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/titan/<RE or RH or BS>_titan_output.rds
#   data/processed/
#   and output data/processed/titan/titan_fsumz.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

source("code/functions.R")

# List names
titan_output_names <- clargs[1 : 6] %>%
  get_TITAN_list_names(.)

#### Get TITAN OTU, inner ####

get_TITAN_otu_inner <- function(x) {
  
  tmp1 <- x$sppmax %>%
    as.data.frame(.) %>%
    as_tibble(rownames = NA) %>%
    rownames_to_column(var = "otu_id")
  
  return(tmp1)
  
}

#### Get TITAN OTU outer ####

get_TITAN_otu <- function(x) {
  
  tmp1 <- map(x, .f = get_TITAN_otu_inner) %>%
    bind_rows(.id = "site") %>%
    mutate(site = str_remove(site, "site_"))
  
  return(tmp1)
  
}

# Get taxonomy data
taxonomy <- clargs[7 : 12] %>%
  map(., .f = read_tsv) %>%
  set_names(nm = titan_output_names) %>%
  bind_rows(.) %>%
  distinct(.)

# Get OTUs as one tibble
titan_output <- clargs[1 : 6] %>%
  map(., .f = read_rds) %>%
  set_names(nm = titan_output_names) %>%
  map(., get_TITAN_otu) %>%
  
  # Combine
  bind_rows(.id = "ID") %>%
  format_TITAN_outputs(.) %>%
  mutate(
    
    variable = NA,
    
    variable = ifelse(
      filter == 0,
      "Insensitive",
      variable
    ),
    
    variable = ifelse(
      filter == 1,
      "Decreasing",
      variable
    ),
    
    variable = ifelse(
      filter == 2,
      "Increasing",
      variable
    )
  ) %>%
  
  # Add taxonomy
  inner_join(taxonomy, ., by = "otu_id")

# Save
write_tsv(
  titan_output,
  clargs[length(clargs)]
)
