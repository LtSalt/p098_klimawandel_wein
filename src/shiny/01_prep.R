################################################################################
# 01 Prep
# 
# Preps data for shiny app
################################################################################


# Dependencies ------------------------------------------------------------

if (!"pacman" %in% installed.packages()) install.packages("pacman")
pacman::p_load(here, 
               tidyverse,
               stars,
               lubridate,
               sf,
               RColorBrewer)

source(here("src/pitch/scripts/02_helpers.R"))


# Scenarios ---------------------------------------------------------------

rcp45 <- read_ncdf(here("src/data/raw/suitability/suitability_rcp45.nc"))
rcp85 <- read_ncdf(here("src/data/raw/suitability/suitability_rcp85.nc"))

sims <- c("rcp45" = rcp45, "rcp85" = rcp85, along = "scenario")


# Geometries --------------------------------------------------------------

germany <- read_sf(here("src/data/raw/vg2500_12-31.gk3.shape/vg2500/VG2500_STA.shp")) %>% 
  slice(1) %>% 
  st_transform(4326)

states <- read_sf(here("src/data/raw/vg2500_12-31.gk3.shape/vg2500/VG2500_LAN.shp")) %>%
  filter(GF == 9) %>% 
  st_transform(4326)

krs <- read_sf(here("src/data/raw/vg2500_12-31.gk3.shape/vg2500/VG2500_KRS.shp")) %>% 
  st_transform(4326)


# Scenarios Aggregated ----------------------------------------------------

rcp45_agg <- sims %>%
  filter(scenario == "rcp45") %>% 
  aggregate(krs, mean, na.rm = TRUE)

rcp85_agg <- sims %>%
  filter(scenario == "rcp85") %>% 
  aggregate(krs, mean, na.rm = TRUE)

scenarios_agg <- c("rcp45" = rcp45_agg, "rcp85" = rcp85_agg, along = "scenario")
