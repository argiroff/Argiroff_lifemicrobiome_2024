#!/usr/bin/env Rscript --vanilla

# name : summarize_network_stats.R
# author: William Argiroff
# inputs : spieceasi/*_spieceasi_igraph.rds
# output : A table of network statistics
# notes : expects order of inputs, output
#   expects input path spieceasi/*_spieceasi_igraph.rds
#   and output paths in results

# clargs <- commandArgs(trailingOnly = TRUE)

clargs <- c(
  "data/processed/spieceasi/bs_spieceasi_igraph.rds",
  "data/processed/spieceasi/re_spieceasi_igraph.rds",
  "data/processed/spieceasi/rh_spieceasi_igraph.rds",
  "results/network_stats.rds"
)

# Libraries
library(tidyverse)

# Functions to get LCI and UCI
get_LCI <- function(x) {
  tmp1 <- t.test(x)
  tmp2 <- tmp1$conf.int[1]
  return(tmp2)
}

get_UCI <- function(x) {
  tmp1 <- t.test(x)
  tmp2 <- tmp1$conf.int[2]
  return(tmp2)
}

# Function to get network summary data
get_network_summary_data = function(network, node.metadata, edge.metadata) {
  
  # Mean shortest path
  mean_dist <- mean_distance(
    network,
    weights = abs(E(network)$weight),
    directed = FALSE,
    unconnected = TRUE,
    details = FALSE
  )
  
  # Nodes
  n_nodes <- node.metadata %>%
    nrow(.)
  
  # Nodes with >= 1 edge
  n_nodes_1 <- node.metadata %>% 
    filter(v_degree > 0) %>%
    nrow(.)
  
  # Degree, mean and CI
  degree_tbl <- node.metadata %>%
    summarise(
      mean_v_degree = mean(v_degree),
      lci_v_degree = get_LCI(v_degree),
      uci_v_degree = get_UCI(v_degree)
    )
  
  # Betweenness, mean and SE
  node_betw <- node.metadata %>%
    summarise(
      mean_v_betweenness = mean(v_betweenness),
      lci_v_betweenness = get_LCI(v_betweenness),
      uci_v_betweenness = get_UCI(v_betweenness)
    )
  
  # Diversity
  network_div <- diversity(
    network,
    weights = abs(E(network)$weight),
    vids = V(network)
  )
  
  # Heterogeneity
  node_het <- tibble(
    mean_heterogeneity = mean(!is.na(network_div)),
    lci_heterogeneity = get_LCI(!is.na(network_div)),
    uci_heterogeneity = get_UCI(!is.na(network_div))
  )
  
  # Clustering coefficient
  clust_coeff <- transitivity(
    network,
    type = c("undirected"),
    vids = V(network),
    weights = abs(E(network)$weight),
    isolates = c("NaN")
  )
  
  # Density
  network_dens <- edge_density(
    network,
    loops = FALSE
  )
  
  # Number of edges
  edges_n <- edge.metadata %>%
    nrow(.)
  
  # Number of positive edges
  edges_pos <- edge.metadata %>%
    filter(edge_weight > 0) %>%
    nrow(.)
  
  # Number of negative edges
  edges_neg <- edge.metadata %>%
    filter(edge_weight < 0) %>%
    nrow(.)
  
  # Number of hub taxa
  hub_n <- node.metadata %>%
    filter(hub == "hub") %>%
    nrow(.)
  
  # Compile summary data
  output <- tibble(
    Nodes = n_nodes,
    `Nodes with edges` = n_nodes_1,
    `Clustering coefficient` = tmp8,
    Density = tmp9,
    Edges = tmp10a,
    `Positive edges` = tmp10b,
    `Negative edges` = tmp10c,
    `Hub ASVs` = tmp11,
    `Mean shortest path` = mean_dist
  ) %>% 
    
    bind_cols(
      
      ., 
      
      tmp3a, 
      
      tmp3b, 
      
      tmp5
      
    )
  
  return(tmp12)
  
}

test1 <- read_rds("data/processed/spieceasi/rh_spieceasi_igraph.rds")

test2 <- test1$node_metadata %>%
  mutate(
    bact_arch_node = case_when(
      str_detect(Domain, "d__Bacteria|d__Archaea") ~ 1,
      is.na(Domain) ~ 0,
      TRUE ~ 0
    ),

    fungal_node = case_when(
      Domain == "Fungi" ~ 1,
      is.na(Domain) ~ 0,
      TRUE ~ 0
    ),
    
    metab_node = case_when(
      str_detect(entity_id, "metab_") ~ 1,
      TRUE ~ 0
    ),

    bact_arch_node_1 = case_when(
      str_detect(Domain, "d__Bacteria|d__Archaea") & v_degree > 0 ~ 1,
      is.na(Domain) ~ 0,
      TRUE ~ 0
    ),

    fungal_node_1 = case_when(
      Domain == "Fungi" & v_degree > 0 ~ 1,
      is.na(Domain) ~ 0,
      TRUE ~ 0
    ),
    
    metab_node_1 = case_when(
      str_detect(entity_id, "metab_") & v_degree > 0 ~ 1,
      TRUE ~ 0
    )
  )

test3 <- test2 %>%
  summarise(
    `Bacterial/Archaeal nodes` = sum(bact_arch_node),
    `Bacterial/Archaeal nodes with edges` = sum(bact_arch_node_1),
    `Fungal nodes` = sum(fungal_node),
    `Fungal nodes with edges` = sum(fungal_node_1),
    `Metabolite nodes` = sum(metab_node),
    `Metabolite nodes with edges` = sum(metab_node_1)
  ) %>%
    mutate(
      `Total nodes` = sum(
        `Bacterial/Archaeal nodes`,
        `Fungal nodes`,
        `Metabolite nodes`
      ),

      `Total nodes with edges` = sum(
        `Bacterial/Archaeal nodes with edges`,
        `Fungal nodes with edges`,
        `Metabolite nodes with edges`
      )
    )
