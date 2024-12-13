################################################################################
# 00 Main
################################################################################


# Dependencies ------------------------------------------------------------

if (!"pacman" %in% installed.packages()) install.packages("pacman")
pacman::p_load(here, quarto)

quarto_render(here("src/analysis/02_tutorial/01_tutorial.qmd"))
