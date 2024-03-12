#!/usr/bin/env Rscript --vanilla

# name : make_titan_fsumz_fig.R
# author: William Argiroff
# inputs : text file of fsumz values
# output : text file of paired t-test
# notes : expects order of inputs, output
#   expects input paths for data/processed/titan/titan_fsumz.txt
#   and results/titan_paired_ttest.txt
#   and output results/titan_paired_ttest.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(viridis)

source("code/functions.R")

# Read in data
titan_fsumz <- read_tsv(clargs[1]) %>%
  filter(!is.na(cp)) %>%
  mutate(
    
    plant_habitat = factor(
      plant_habitat,
      levels = c("Root endosphere", "Rhizosphere", "Soil")
    ),
    
    variable = factor(
      variable,
      levels = c("Decreasing", "Increasing")
    ),

    community = factor(
      community,
      levels = c("Bacteria and Archaea", "Fungi")
    )
  )

# Means
titan_fsumz_means <- titan_fsumz %>%
  group_by(variable) %>%
  summarise(
    mean_cp = mean(cp),
    se_cp = se(cp)
  ) %>%
  ungroup(.) %>%
  mutate(
    variable = factor(
      variable,
      levels = c("Decreasing", "Increasing")
    )
  )

# t test results
fsumz_ttest_pval <- read_tsv(clargs[2]) %>%
  pull(p.value)

# P value
if(fsumz_ttest_pval < 0.001) {
  
  fsumz_ttest_pval_label <- "italic(P) < 0.001"
  
} else {
  
  fsumz_ttest_pval_label <- paste("italic(P) = ", round(fsumz_ttest_pval, 3), sep = "")
  
}

# Tibble
fsumz_ttest_pval_label_tbl <- tibble(
  pval_label = fsumz_ttest_pval_label
)

# Figure
fsumz_fig <- ggplot() +
  
  geom_line(
    data = titan_fsumz,
    aes(
      x = variable,
      y = cp,
      colour = plant_habitat,
      group = interaction(community, plant_habitat, site)
    )
  ) +
  
  # Points
  geom_point(
    data = titan_fsumz,
    aes(
      x = variable,
      y = cp,
      fill = plant_habitat,
      shape = community
    ),
    size = 2.5
  ) +
  
  geom_errorbar(
    data = titan_fsumz_means,
    aes(
      x = variable,
      ymin = mean_cp - se_cp,
      ymax = mean_cp + se_cp
    ),
    colour = "black",
    linewidth = 1,
    width = 0
  ) +
  
  geom_segment(
    data = titan_fsumz_means,
    aes(
      x = as.integer(variable) - 0.25,
      xend = as.integer(variable) + 0.25,
      y = mean_cp,
      yend = mean_cp
    ),
    linewidth = 1,
    colour = "black"
  ) +
  
  geom_text(
    data = fsumz_ttest_pval_label_tbl,
    aes(x = 1.5, y = 112.5, label = pval_label),
    parse = TRUE,
    size = 4
  ) +
  
  scale_colour_viridis(
    discrete = TRUE,
    begin = 0.9,
    end = 0,
    guide = "none"
  ) +
  
  scale_fill_viridis(
    discrete = TRUE,
    begin = 0.9,
    end = 0,
    name = "Stand"
  ) +
  
  scale_shape_manual(
    name = NULL,
    values = c(21, 24)
  ) +
  
  labs(
    title = NULL,
    x = "OTU relationship with tree age",
    y = "Community change point (tree age, y)"
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
    axis.text.x = element_text(colour = "black"),
    axis.text.y = element_text(colour = "black"),
    axis.ticks = element_line(colour = "black"),
    
    # Legend
    legend.key = element_blank(),
    legend.text = element_text(colour = "black", size = 10, hjust = 0),
    legend.position = "right"
    
  ) +
  
  guides(
    
    shape = guide_legend(override.aes = list(
      pch = c(21, 24),
      size = 2.5,
      colour = "black",
      fill = "black"
    )),
    
    fill = guide_legend(override.aes = list(
      pch = 21,
      size = 2.5,
      colour = "black"
    ))
    
  )

# Save
write_rds(
  fsumz_fig,
  clargs[3]
)
