################################################################################
# 01 Extract
# 
# Extract and aggregate predictions for Germany
# Write to shapefile
################################################################################



# Import ------------------------------------------------------------------

rcp45 <- read_ncdf(here("src/data/raw/suitability/suitability_rcp45.nc"))
rcp85 <- read_ncdf(here("src/data/raw/suitability/suitability_rcp85.nc"))

germany <- read_sf(here("src/data/raw/vg2500_12-31.gk3.shape/vg2500/VG2500_STA.shp")) %>% 
  slice(1) %>% 
  st_transform(4326) %>% 
  select(geometry)

krs <- read_sf(here("src/data/raw/vg2500_12-31.gk3.shape/vg2500/VG2500_KRS.shp")) %>% 
  st_transform(4326) %>% 
  select(name = GEN, geometry)


# Aggregate predictions for municipalities --------------------------------

rcp45_agg <- rcp45 %>%
  aggregate(krs, mean, na.rm = TRUE)

rcp85_agg <- rcp85 %>%
  aggregate(krs, mean, na.rm = TRUE)


# Transform to simple feature objects -------------------------------------

sims_grid <- c("rcp45" = rcp45, "rcp85" = rcp85, along = "scenario") %>% 
  st_crop(germany) %>% 
  st_as_sf(long = TRUE) %>% 
  st_intersection(germany) %>% # crop cells to match German borders
  mutate(level = "Grid")

sims_krs <- c("rcp45" = rcp45_agg, "rcp85" = rcp85_agg, along = "scenario") %>% 
  st_as_sf(long = TRUE) %>% 
  mutate(level = "Landkreise") %>% 
  st_join(krs, join = st_equals)


# Combine sf objects and write to disk ------------------------------------

bind_rows(sims_grid, sims_krs) %>% 
  mutate(year = year(TIME)) %>% 
  select(-TIME) %>% 
  write_sf(here("src/data/processed/dashboard/predictions_germany/predictions_germany.shp"))



