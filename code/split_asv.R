#!/usr/bin/env Rscript --vanilla

# name : split_asv.R
# author: William Argiroff
# inputs : metadata tibble, ASV table as a 3 column tibble
# output : non-subsampled ASV table for a specific habitat
# notes : expects order of inputs, output
#   expects input paths for data/processed/<16S or ITS>/asv_processed/asv_tibble.txt
#   and output data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_asv.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

source("code/functions.R")

# Metadata
metadata <- read_tsv(clargs[1])

# ASV
asv <- read_tsv(clargs[2]) %>%
  inner_join(metadata, ., by = "sample_id")

# Trim ASV
if(str_detect(clargs[3], "BS_asv.txt")) {
  
  asv_trimmed <- asv %>%
    filter(plant_habitat == "Soil")
  
} else if(str_detect(clargs[3], "RE_asv.txt")) {
  
  asv_trimmed <- asv %>%
    filter(plant_habitat == "Root endosphere")
  
} else if(str_detect(clargs[3], "RH_asv.txt")) {
  
  asv_trimmed <- asv %>%
    filter(plant_habitat == "Rhizosphere")
  
} else {
  
  asv_trimmed <- asv
  
}

# Drop samples and ASVs with no reads
asv_out <- asv_trimmed %>%
  drop_0seq_samples(.) %>%
  drop_0seq_asvs(.) %>%
  
  select(sample_id, asv_id, n_seqs)

# Save
write_tsv(
  asv_out,
  clargs[3]
)
