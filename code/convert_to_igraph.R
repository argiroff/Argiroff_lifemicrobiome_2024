#!/usr/bin/env Rscript --vanilla

# name : convert_to_igraph.R
# author: William Argiroff
# inputs : Files in data/processed/spieceasi for 16S and ITS
# output : SPIECEASI results output as spieceasi/*_spieceasi_igraph.rds
#          A list of igraph, node metadata, edge metadata
# notes : expects order of inputs, output
#   expects input path spieceasi/*_spieceasi_results.rds
#   and output paths in spieceasi/*_spieceasi_igraph.rds

clargs <- commandArgs(trailingOnly = TRUE)

# Libraries
library(tidyverse)
library(igraph)

# Read in SPIEC-EASI results
spieceasi_matrix <- read_rds(clargs[1])

# Convert to igraph object
network_igraph <- graph_from_adjacency_matrix(
    spieceasi_matrix,  
    mode = "undirected",
    weighted = TRUE
  )

# Taxonomy tables
tax_16s <- read_tsv(clargs[2]) %>%
  rename(entity_id = "asv_id")

tax_its <- read_tsv(clargs[3]) %>%
  rename(entity_id = "asv_id")

# Metabolites
metab <- read_tsv(clargs[4]) %>%
  select(metabolite_id, metabolite) %>%
  rename(entity_id = "metabolite_id") %>%
  distinct()

if (any(tax_16s$entity_id %in% tax_its$entity_id)) {
  stop("16S and ITS taxonomy tables have overlapping ASV ID numbers.")
}

# Combine
tax_tbl <- bind_rows(
  tax_16s,
  tax_its,
  metab
) %>%
  rename(Domain = "Kingdom")

# Calculate node statistics
node_stats <- tibble(
  entity_id = V(network_igraph)$name
) %>%
  mutate(
    v_degree = degree(network_igraph),

    v_betweenness = betweenness(
      network_igraph,
      weights = abs(E(network_igraph)$weight),
      directed = FALSE
    )
  ) %>%

  # Hub taxa
  mutate(
    hub = case_when(
      v_degree > quantile(v_degree, 0.9) & v_betweenness > quantile(v_betweenness, 0.9) ~ "hub",
      TRUE ~ "non_hub"
    )
  ) %>%
  inner_join(tax_tbl, ., by = "entity_id")

# "From" tax
from_tax_tbl <- tax_tbl %>%
  rename_with(
    .,
    .fn = ~ paste0("from_", .x),
    .cols = everything()
  ) %>%
  rename(from_node = "from_entity_id")

# "To" tax
to_tax_tbl <- tax_tbl %>%
  rename_with(
    .,
    .fn = ~ paste0("to_", .x),
    .cols = everything()
  ) %>%
  rename(to_node = "to_entity_id")

# Calculate edge statistics
edge_stats <- as_long_data_frame(network_igraph) %>%  
  rename(
    from_index = "from",
    to_index = "to",
    edge_weight = "weight",
    from_node = "from_name",
    to_node = "to_name"
  ) %>% 
  select(
    from_node, to_node, from_index,
    to_index, edge_weight
  ) %>%
  inner_join(., from_tax_tbl, by = "from_node") %>%
  inner_join(., to_tax_tbl, by = "to_node")

# Output list
output <- list(
  igraph_network = network_igraph,
  node_metadata = node_stats,
  edge_metadata = edge_stats
)

# Save
write_rds(
  output,
  clargs[5]
)