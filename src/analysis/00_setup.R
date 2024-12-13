################################################################################
# 00 MAIN
################################################################################


# Dependencies ------------------------------------------------------------

if (!"pacman" %in% installed.packages()) install.packages("pacman")
pacman::p_load(here, tidyverse)


# Recreate processed data & reports ---------------------------------------

setup_scripts <- here() %>% 
  list.files(full.names = TRUE, recursive = TRUE) %>% 
  str_subset("00_setup.R") %>% 
  str_subset(here("src/analysis/00_setup.R"), negate = TRUE) 

walk(setup_scripts, source)
