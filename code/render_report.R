#!/usr/bin/env Rscript --vanilla

# name : render_report.R
# author: William Argiroff
# inputs : Argiroff_tech_eval_report.Rmd
# output : rendered report (Argiroff_tech_eval_report.html)

# Get arguments from command line
clargs <- commandArgs(trailingOnly = TRUE)

# Load packages
library(rmarkdown)

# Render
render(
  input = clargs[1],
  output_file = clargs[2]
)
