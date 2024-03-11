#!/usr/bin/env Rscript --vanilla

# name : format_metadata.R
# author: William Argiroff
# inputs : Sequence sample metadata files, manifest files
# output : Single uniform metadata file to merge with phyloseq object
# notes : expects order of inputs (manifest, site) output

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Read in manifest files and combine
manifest <- clargs[1 : (length(clargs) - 2)] %>%
  map(., .f = read_tsv) %>%
  bind_rows(.) %>%
  select(`sample-id`) %>%
  rename(sample_id = "sample-id") %>%
  
  # Extract tree IDs from sample names
  mutate(

    # Saplings
    tree_id = ifelse(
      str_detect(sample_id, "-Sap"),
      str_replace(sample_id, "-Sap-", "Sap"),
      sample_id
    ),
    
    # Format blanks and NTCs
    tree_id = ifelse(
      str_detect(tree_id, "NTC|Blank|blank|BLANK"),
      NA,
      tree_id
    ),
    
    # Get tree ID
    tree_id = str_remove(tree_id, "-.*"),

    # Plant habitat
    plant_habitat = NA,
    plant_habitat = str_extract(sample_id, "-RE-|-RH-|-BS-|wood"),
    plant_habitat = str_replace(plant_habitat, "wood", "SW"),

    plant_habitat = ifelse(
      plant_habitat == "-BS-",
      "Soil",
      plant_habitat
    ),

    plant_habitat = ifelse(
      plant_habitat == "-RE-",
      "Root endosphere",
      plant_habitat
    ),

    plant_habitat = ifelse(
      plant_habitat == "-RH-",
      "Rhizosphere",
      plant_habitat
    ),

    # Sample type
    sample_type = NA,

    sample_type = ifelse(
      str_detect(sample_id, "NTC"),
      "NTC",
      sample_type
    ),

    sample_type = ifelse(
      str_detect(sample_id, "Blank|blank|BLANK"),
      "Blank",
      sample_type
    ),

    sample_type = ifelse(
      is.na(sample_type),
      "Plant",
      sample_type
    ),

    # Community
    community = ifelse(
      str_detect(sample_id, "-16S"),
      "Bacteria and Archaea",
      "Fungi"
    )
    
  )

# Read in site metadata
metadata_out <- read_tsv(clargs[(length(clargs) - 1)]) %>%
  select(tree_id, site, lon, lat, root_dist, sample_date) %>%
  
  # Add manifest
  full_join(manifest, ., by = "tree_id") %>%
  filter(!is.na(sample_id))

# Save
write_tsv(
  metadata_out,
  clargs[length(clargs)]
)
