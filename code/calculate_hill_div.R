#!/usr/bin/env Rscript --vanilla

# name : calculate_hill_div.R
# author: William Argiroff
# inputs : subsampled ASV table and corresponding metadata
# output : .txt of Hill numbers
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_sub_asv.txt
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_sub_metadata.txt
#   and output data/processed/<16S or ITS>/dbrda/<RE or RH or BS>_hill_div.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(hillR)

# ASV data
asv <- read_tsv(clargs[1]) %>%
  pivot_wider(
    id_cols = sample_id,
    names_from = "asv_id",
    values_from = "n_seqs",
    values_fill = 0
  ) %>%
  
  # Order
  arrange(sample_id) %>% 
  column_to_rownames(var = "sample_id") %>%
  as.data.frame(.)

# Sample ID filter
sample_id_filter <- rownames(asv)

# Metadata
metadata <- read_tsv(clargs[2])

# Run Hill diversity
hill_div <- list(0, 1, 2) %>%
  set_names(., nm = paste0("hill", 0:2)) %>%
  map(
    .,
    .f = function(x) {

      hill_results <- hill_taxa(asv, q = x)
      
      output <- tibble(
        sample_id = names(hill_results),
        hill_value = hill_results
      )

      return(output)

    }
  ) %>%
  bind_rows(.id = "hill_index")

# Output directory
out_path <- dirname(clargs[3])
if (!dir.exists(out_path)) {
  dir.create(out_path)
}

# Save
write_tsv(
  hill_div,
  clargs[3]
)