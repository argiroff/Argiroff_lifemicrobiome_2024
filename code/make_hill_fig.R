#!/usr/bin/env Rscript --vanilla

# name : make_hill_fig.R
# author: William Argiroff
# inputs : habitat specific Hill diversity and LM
# output : R data object of Hill diversity plot
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_hill_div.txt
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_hill_lm.rds
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_sub_metadata.txt
#   data/processed/environ/tree_age_site.rds
#   and output results/rarefaction_curve_fig.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(cowplot)
library(viridis)

source("code/functions.R")

# Names
list_names <- c(
  "BS_16S", "RE_16S", "RH_16S",
  "BS_ITS", "RE_ITS", "RH_ITS"
)

# Read in LM
hill_lm <- clargs[7:12] %>%
  map(., .f = read_rds) %>%
  set_names(., nm = list_names)

# Read in tree age
tree_age <- read_rds(clargs[19]) %>%
  pluck("age_df")
  
# Read in metadata
metadata <- clargs[13:18] %>%
  map(., .f = read_tsv) %>%
  map(
    .,
    .f = function(x) {
      output <- inner_join(x, tree_age, by = "tree_id")

      return(output)
    }
  ) %>%
  set_names(., nm = list_names)

# Read in Hill numbers
hill_div <- clargs[1:6] %>%
  map(., .f = read_tsv) %>%
  set_names(., nm = list_names) %>%
  map2(
    metadata,
    .,
    .f = function(x, y) {
      output <- inner_join(x, y, by = "sample_id")
      
      return(output)
    }
  ) %>%
  map(
    .,
    .f = function(x) {
      output <- x %>%
        select(
          sample_id, site, community, plant_habitat,
          tree_age_site, hill_index, hill_value
        )
    }
  ) %>%
  bind_rows(.id = "hab") %>%
  filter(hill_index == "hill1") %>%
  unite(
    row_id,
    community, plant_habitat,
    sep = "\n",
    remove = FALSE
  ) %>%
  mutate(
    site = paste("Stand", site, sep = " ") %>%
      factor(., levels = paste("Stand", c("A", "B", "D", "H"), sep = " ")),

    row_id = str_replace(
      row_id,
      "Bacteria and Archaea",
      "Bacteria/Archaea"
    ) %>%
      factor(
        .,
        levels = c(
          "Bacteria/Archaea\nRoot endosphere",
          "Bacteria/Archaea\nRhizosphere",
          "Bacteria/Archaea\nSoil",
          "Fungi\nRoot endosphere",
          "Fungi\nRhizosphere",
          "Fungi\nSoil"
        )
      ),
    
    # Plant habitat
    plant_habitat = factor(
      plant_habitat,
      levels = c("Root endosphere", "Rhizosphere", "Soil")
    )
  )

# Plot Hill diversity
hill_fig <- ggplot() +

  # Points
  geom_point(
    data = hill_div,
    aes(
      x = tree_age_site,
      y = hill_value,
      colour = plant_habitat
    )
  ) +
  
  # Colors
  scale_colour_viridis(  
    discrete = TRUE,
    begin = 0.8,
    end = 0,
    guide = "none"
  ) +
  
  # Facets
  facet_grid(
    rows = vars(row_id),
    cols = vars(site),
    scales = "free_y"
  ) +
  
  # Titles
  labs(
    title = NULL,
    x = "Tree age (years)",
    y = bquote("Hill number ("^1*italic(D)*")")
  ) +
  
  # Formatting
  theme(
    # Panel
    panel.border = element_rect(colour = "black", fill = NA, linewidth = 1),
    panel.background = element_blank(),
    panel.grid = element_blank(),
    
    # Titles
    axis.title = element_text(colour = "black", size = 12),
    
    # Axis
    axis.ticks = element_line(colour = "black", linewidth = 0.25),
    axis.text = element_text(colour = "black", size = 10),

    # Facets
    strip.background = element_blank(),
    strip.text = element_text(colour = "black", size = 10)
  )

# Save
write_rds(
  hill_fig,
  clargs[length(clargs)]
)