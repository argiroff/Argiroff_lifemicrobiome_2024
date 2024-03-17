#!/usr/bin/env Rscript --vanilla

# name : run_mantel.R
# author: William Argiroff
# inputs : .rds of Bray-Curtis distance matrix from vegdist,
#   with accompanying metadata, tree age, and metabolite distance matrices
# output :
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_bc_dist.rds
#   and output results/results/comp_metab_mantel.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(vegan)

# Names
bc_dist_names <- clargs[c(1 : (length(clargs) - 1))] %>%
  str_remove(., "data/processed/") %>%
  str_remove(., "asv_processed/") %>%
  str_remove(., "_bc_dist.rds") %>%
  str_replace(., "/", "_")

#### Function to run Mantel test ####

run_mantel <- function(x) {
  
  tmp1 <- mantel(x$asv_dist, x$metab_dist)
  
  tmp2 <- tibble(
    mantel_r = tmp1$statistic,
    p_val = tmp1$signif
  )
  
  return(tmp2)
  
}

# Input data
mantel_out <- clargs[c(1 : (length(clargs) - 1))] %>%
  map(., .f = read_rds) %>%
  
  # Run Mantel tests
  map(., .f = run_mantel) %>%
  set_names(nm = bc_dist_names) %>%
  bind_rows(., .id = "ID") %>%
  
  # Format
  separate(ID, into = c("community", "plant_habitat")) %>%
  mutate(
    
    community = ifelse(community == "16S", "Bacteria and Archaea", community),
    community = ifelse(community == "ITS", "Fungi", community),
    
    plant_habitat = ifelse(plant_habitat == "BS", "Soil", plant_habitat),
    plant_habitat = ifelse(plant_habitat == "RH", "Rhizosphere", plant_habitat),
    plant_habitat = ifelse(plant_habitat == "RE", "Root endosphere", plant_habitat)
    
  )

# Save
write_tsv(
  mantel_out,
  clargs[length(clargs)]
)
