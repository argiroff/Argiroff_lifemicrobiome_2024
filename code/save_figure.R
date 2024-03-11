#!/usr/bin/env Rscript --vanilla

# name : save_figure.R
# author: William Argiroff
# inputs : figure in .rds R object, device type (e.g., pdf)
#   fig height, fig width, resolution (in dpi) or NULL, 
# output : figure in specified format (e.g., pdf)
# notes : expects order of inputs, output

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(viridis)
library(cowplot)

source("code/functions.R")

# Get plot
fig <- read_rds(clargs[1])

# Check resolution
dpi_value <- eval(parse(text = clargs[3]))

# Width, height, and units
fig_width = eval(parse(text = clargs[4]))
fig_height = eval(parse(text = clargs[5]))

if(is.null(dpi_value)) {
  
  ggsave2(
    filename = clargs[7],
    fig,
    device = clargs[2],
    width = fig_width,
    height = fig_height,
    units = clargs[6]
  )
  
} else {
  
  ggsave2(
    filename = clargs[7],
    fig,
    device = clargs[2],
    dpi = dpi_value,
    width = fig_width,
    height = fig_height,
    units = clargs[6]
  )
  
}

file.remove("Rplots.pdf")
