#!/usr/bin/env Rscript --vanilla

# name : tree_age.R
# author: William Argiroff
# inputs : Sequence sample metadata files
#   merged OTU qza, merged tax qza, merged repseq qza
# output : phyloseq object
# notes : expects order of inputs, output
#   expects input paths for merged OTU and rep seqs qzas, tax qza, and metadata
#   and output data/processed/16S/otu_processed/ps_untrimmed.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(qiime2R)
library(phyloseq)

# Make phyloseq object
ps_16s <- qza_to_phyloseq(
  features = clargs[2],
  taxonomy = clargs[3]
)

# Add representative sequences
repseqs_16s_qza <- read_qza(
  file = clargs[1]
)

repseqs_16s <- repseqs_16s_qza$data

ps_16s <- merge_phyloseq(ps_16s, repseqs_16s)

# Add metadata
metadata_16s <- read_tsv(
  file = clargs[4]
) %>%
  
  # Match sample names
  filter(sample_id %in% sample_names(ps_16s)) %>%
  distinct(.) %>%
  arrange(match(sample_id, sample_names(ps_16s))) %>%
  column_to_rownames(var = "sample_id") %>%
  as.data.frame(.)

metadata_16s_input <- sample_data(metadata_16s)

ps_16s <- merge_phyloseq(ps_16s, metadata_16s_input)

# Filter
ps_16s_trimmed <- subset_samples(
  ps_16s,
  plant_habitat != "SW"
)

ps_16s_trimmed <- subset_samples(
  ps_16s_trimmed,
  sample_type != "Blank"
)

ps_16s_trimmed <- subset_samples(
  ps_16s_trimmed,
  sample_type != "NTC"
)

# Save
write_rds(
  ps_16s_trimmed,
  file = clargs[5]
)
