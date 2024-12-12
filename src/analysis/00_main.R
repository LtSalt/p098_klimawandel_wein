################################################################################
# 00 MAIN
################################################################################


# Dependencies ------------------------------------------------------------

if (!"pacman" %in% installed.packages()) install.packages("pacman")
pacman::p_load(here)

main_scripts <- here() %>% 
  list.files(full.names = TRUE, recursive = TRUE) %>% 
  str_subset("00_main.R")

walk(main_scripts, source)