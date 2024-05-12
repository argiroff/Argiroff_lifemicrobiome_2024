#!/usr/bin/env Rscript --vanilla

# name : make_rarefaction_curve_plots.R
# author: William Argiroff
# inputs : habitat specific rarefaction curve data
# output : R data object of rarefaction curve plot
# notes : expects order of inputs, output
#   expects input paths for 
#   data/processed/<16S or ITS>/asv_processed/<RE or RH or BS>_rarefaction_curves.txt 
#   and output results/rarefaction_curve_fig.rds

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
rarefaction_results <- clargs[7:12] %>%
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
    
  )

#### Function to get rarefaction curve figure ####

get_rarefaction_fig <- function(input.data) {
  
  tmp1 <- ggplot() +
    
    scale_x_continuous(labels = function(x) format_axis(x)) +
    
    scale_y_continuous(
      limits = c(0, NA),
      expand = expansion(mult = c(0, 0.05)),
      labels = function(x) format_axis(x)
    ) +
    
    # Line plot
    geom_line(
      data = input.data, 
      aes(
        x = n_seqs, 
        y = n_asvs, 
        group = sample_id, 
        colour = plant_habitat)
    ) +
    
    # Line color
    scale_colour_viridis(
      discrete = TRUE, 
      name = NULL,
      begin = 0.9,
      end = 0
    ) +
    
    # Titles
    labs(
      title = NULL,
      x = "Number of sequences",
      y = "Number of ASVs"
    ) +
    
    # Grid
    facet_wrap(
      ~ plot_title,
      scales = "free",
      ncol = 1
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
      axis.text.x = element_text(colour = "black", hjust = 0.75),
      axis.text.y = element_text(colour = "black"),
      axis.ticks = element_line(colour = "black"),
      
      # Facet strip
      strip.background = element_blank(),
      strip.text = element_text(colour = "black", size = 14, hjust = 0),
      
      # Legend
      legend.key = element_blank(),
      legend.text = element_text(colour = "black", size = 10, hjust = 0),
      legend.position = "bottom",

      # Margins
      plot.margin = margin(5.5, 9.5, 5.5, 5.5, "pt")
      
    )
  
  return(tmp1)
  
}

# Get figures
rarefaction_figs <- rarefaction_results %>%
  group_by(community) %>%
  group_split(.) %>%
  map(., .f = ungroup) %>%
  map(., .f = get_rarefaction_fig) %>%
  set_names(nm = c("ba", "fungi"))

# Get legend
rarefaction_legend <- get_plot_component(
  rarefaction_figs$ba,
  "guide-box-bottom",
  return_all = TRUE
)

# Combine figure panels
rarefaction_grid <- plot_grid(
  rarefaction_figs$ba + theme(legend.position = "none"),
  rarefaction_figs$fungi + theme(legend.position = "none"),
  align = "hv",
  axis = "l",
  nrow = 1,
  ncol = 2
)

# Add legend
rarefaction_out <- plot_grid(
  rarefaction_grid,
  rarefaction_legend,
  nrow = 2,
  ncol = 1,
  rel_heights = c(1, 0.05)
)

# Save
write_rds(
  rarefaction_out,
  clargs[length(clargs)]
)
