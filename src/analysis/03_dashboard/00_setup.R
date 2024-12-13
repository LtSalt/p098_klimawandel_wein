################################################################################
# 00 MAIN
################################################################################


# Dependencies ------------------------------------------------------------

if (!"pacman" %in% installed.packages()) install.packages("pacman")
pacman::p_load(here, stars, sf, tidyverse, shiny)


# Scripts -----------------------------------------------------------------

dest <- here("src/data/processed/dashboard")

if (!dir.exists(dest)) source(here("src/analysis/03_dashboard/01_process.R"))
