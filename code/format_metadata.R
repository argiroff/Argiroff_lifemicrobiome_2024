#!/usr/bin/env Rscript --vanilla

# name : format_metadata.R
# author: William Argiroff
# inputs : Sequence sample metadata files
# output : Single uniform metadata file to merge with phyloseq object
# notes : expects order of inputs (args 1-3) output

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

