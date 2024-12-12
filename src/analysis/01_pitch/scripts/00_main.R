################################################################################
# 00 MAIN
################################################################################


# Dependencies ------------------------------------------------------------

if (!"pacman" %in% installed.packages()) install.packages("pacman")
pacman::p_load(here, tidyverse, quarto)


# Process Data ------------------------------------------------------------

if (!dir.exists(here("src/data/processed/pitch"))) {
  # create precalculated cropped grid cells, matching the outline of europe/germany
  source(here("src/analysis/01_pitch/scripts/01_process.R"))
}


# Render Pitch ------------------------------------------------------------

quarto_render(here("src/analysis/01_pitch/pitch.qmd"))
