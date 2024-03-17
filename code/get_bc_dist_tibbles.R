#!/usr/bin/env Rscript --vanilla

# name : get_bc_dist_tibbles.R
# author: William Argiroff
# inputs : .rds of Bray-Curtis distance matrix from vegdist,
#   with accompanying metadata, tree age, and metabolite distance matrices
# output : 
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_bc_dist.rds
#   and output data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_bc_dist.txt

clargs <- commandArgs(trailingOnly = TRUE)
clargs <- "data/processed/16S/asv_processed/RH_bc_dist.rds"
library(tidyverse)
library(vegan)
test1 <- mantel(bc_dist$asv_dist, bc_dist$metab_dist)

source("code/functions.R")

#### Function to convert distance matrices to tibbles ####

distmat_to_tibble <- function(x) {
  
  tmp1 <- x %>%
    
    # Convert to tibble
    as.matrix(.) %>%
    as.data.frame(.) %>%
    as_tibble(rownames = NA) %>%
    rownames_to_column(var = "sample_id1") %>%
    
    # Long format
    pivot_longer(
      -sample_id1,
      names_to = "sample_id2",
      values_to = "bray"
    )
  
  return(tmp1)
  
}

#### Function to get unique sample pairs ####

get_unique_sample_pairs <- function(x, y) {
  
  tmp1 <- sort(c(x, y))
  
  tmp2 <- paste(tmp1[1], tmp1[2], sep = "_")
  
  return(tmp2)
  
}

#### Function to filter samples ####

filter_sample_pairs <- function(x) {
  
  tmp1 <- x %>%
    filter(sample_id1 != sample_id2) %>%
    
    # Get sample pairs
    mutate(
      
      sample_id_pair = map2_chr(
        sample_id1,
        sample_id2,
        .f = get_unique_sample_pairs
      )
      
    ) %>%
    
    # Trim
    select(sample_id_pair, bray) %>%
    distinct(.)
  
  return(tmp1)
  
}

# Read in data
bc_dist <- read_rds(clargs[1]) #%>% 
  `[`(c("asv_dist", "metab_dist", "age_dist")) %>%
  map(., .f = distmat_to_tibble) %>%
  map(., .f = filter_sample_pairs) %>%
  
  # Combine
  bind_rows(., .id = "ID") %>%
  pivot_wider(
    id_cols = sample_id_pair,
    names_from = "ID",
    values_from = "bray"
  ) %>%
  
  # Get sites
  separate(
    sample_id_pair,
    into = c("sample_id1", "sample_id2"),
    sep = "_",
    remove = FALSE
  ) %>%
  
  # Sites
  mutate(
    site1 = substring(sample_id1, 1, 1),
    site2 = substring(sample_id2, 1, 1)
  ) %>%
  relocate(
    sample_id_pair,
    sample_id1,
    sample_id2,
    site1,
    site2,
    asv_dist,
    metab_dist,
    age_dist
  )


test1 <- bc_dist %>%
  filter(site1 == site2) #%>%
  filter(site1 == "D")

plot(test1$metab_dist, test1$asv_dist)

test2 <- lmerTest::lmer(asv_dist ~ age_dist + (age_dist | site1), data = test1)
summary(lm(asv_dist ~ metab_dist, data = test1))
test3 <- ggplot() +
  
  geom_point(
    data = test1,
    aes(x = metab_dist, y = asv_dist, colour = site1)
  ) +
  
  geom_smooth(
    data = test1,
    aes(x = metab_dist, y = asv_dist, colour = site1),
    formula = y ~ x,
    method = "lm"
  )
