#!/usr/bin/env Rscript --vanilla

# name : make_sample_sequence_total_plots.R
# author: William Argiroff
# inputs : habitat specific sample totals data
# output : R data object of bar plot
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/otu_processed/<RE or RH or BS>_sample_total.txt 
#   and output results/sample_sequence_totals_fig.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(cowplot)
library(viridis)

source("code/functions.R")

# Metadata
metadata <- clargs[1:6] %>%
  map(., .f = read_metadata) %>%
  bind_rows(.)

# Input data
sample_total <- clargs[7:12] %>%
  map(., .f = read_tsv) %>%
  bind_rows(.) %>%
  inner_join(metadata, ., by = "sample_id") %>%
  
  # Facet titles
  mutate(
    
    plant_habitat = factor(
      plant_habitat,
      levels = c("Root endosphere", "Rhizosphere", "Soil")
    ),
    
    plot_title = NA,
    
    plot_title = map2_chr(
      community,
      plant_habitat,
      .f = get_facet_title
    )
    
  ) %>%
  
  # Order
  arrange(plant_habitat, community, n_seqs) %>%
  mutate(sample_id = factor(sample_id, levels = sample_id))

# Figure
sample_total_figs <- ggplot() +
  
  scale_y_continuous(
    limits = c(0, NA),
    expand = expansion(mult = c(0, 0.05)),
    labels = function(x) format_axis(x)
  ) +
  
  # Bars
  geom_col(
    data = sample_total,
    aes(
      x = sample_id,
      y = n_seqs,
      fill = plant_habitat,
      colour = plant_habitat
    )
  ) +
  
  # Line color
  scale_colour_viridis(
    discrete = TRUE, 
    name = NULL,
    begin = 0.9,
    end = 0,
    guide = "none"
  ) +
  
  # Bar color
  scale_fill_viridis(
    discrete = TRUE, 
    name = NULL,
    begin = 0.9,
    end = 0
  ) +
  
  # Titles
  labs(
    title = NULL,
    x = NULL,
    y = "Number of OTUs"
  ) +
  
  # Grid
  facet_wrap(
    ~ plot_title,
    scales = "free",
    ncol = 2,
    nrow = 3
  ) +
  
  # Formatting
  theme(
    
    # Panel background and border
    panel.border = element_rect(colour = "black", fill = NA, linewidth = 1),
    panel.background = element_blank(),
    
    # Title text
    axis.title.y = element_text(colour = "black", size = 12),
    axis.title.x = element_text(colour = "black", size = 12),
    
    # Axis text and ticks
    axis.text.x = element_blank(),
    axis.text.y = element_text(colour = "black"),
    axis.ticks.x = element_blank(),
    axis.ticks.y = element_line(colour = "black"),
    
    # Facet strip
    strip.background = element_blank(),
    strip.text = element_text(colour = "black", size = 14, hjust = 0),
    
    # Legend
    legend.key = element_blank(),
    legend.text = element_text(colour = "black", size = 10, hjust = 0),
    legend.position = "bottom"  
    
  )
  
# Save
write_rds(
  sample_total_figs,
  clargs[length(clargs)]
)
