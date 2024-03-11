#!/usr/bin/env Rscript --vanilla

# name : split_otu.R
# author: William Argiroff
# inputs : metadata tibble, OTU table as a 3 column tibble
# output : non-subsampled OTU table for a specific habitat
# notes : expects order of inputs, output
#   expects input paths for data/processed/<16S or ITS>/otu_processed/otu_tibble.txt
#   and output data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_otu.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

source("code/functions.R")

# Metadata
metadata <- read_tsv(clargs[1])

# OTU
otu <- read_tsv(clargs[2]) %>%
  inner_join(metadata, ., by = "sample_id")

# Trim OTU
if(str_detect(clargs[3], "BS_otu.txt")) {
  
  otu_trimmed <- otu %>%
    filter(plant_habitat == "Soil")
  
} else if(str_detect(clargs[3], "RE_otu.txt")) {
  
  otu_trimmed <- otu %>%
    filter(plant_habitat == "Root endosphere")
  
} else if(str_detect(clargs[3], "RH_otu.txt")) {
  
  otu_trimmed <- otu %>%
    filter(plant_habitat == "Rhizosphere")
  
} else {
  
  otu_trimmed <- otu
  
}

# Drop samples and OTUs with no reads
otu_out <- otu_trimmed %>%
  drop_0seq_samples(.) %>%
  drop_0seq_otus(.) %>%
  
  select(sample_id, otu_id, n_seqs)

# Save
write_tsv(
  otu_out,
  clargs[3]
)
