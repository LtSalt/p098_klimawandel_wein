################################################################################
# 01 PROCESS
# 
# Pre-calculates cropped grid cells for Europe and Germany
################################################################################


# Dependencies ------------------------------------------------------------

if (!"pacman" %in% installed.packages()) install.packages("pacman")
pacman::p_load(here, tidyverse, sf, stars, lubridate)

# spherical geometries will fail (presumably because of error in raw geometries)
sf_use_s2(FALSE)


# Import ------------------------------------------------------------------

rcp45 <- read_ncdf(here("src/data/raw/suitability/suitability_rcp45.nc"))

countries <- read_sf(here("src/data/raw/CNTR_RG_10M_2024_4326.shp/CNTR_RG_10M_2024_4326.shp")) %>% 
  st_crop(st_bbox(rcp45)) %>% 
  select(geometry) %>% 
  st_make_valid()

europe <- st_union(countries)

germany <- read_sf(here("src/data/raw/vg2500_12-31.gk3.shape/vg2500/VG2500_STA.shp")) %>% 
  slice(1) %>% 
  st_transform(4326)


# Crop Cells --------------------------------------------------------------

# 1. extract grid cells for all of europe
# 2. raster to vector
# 3. add an index variable

template <- rcp45 %>% 
  filter(year(TIME) == 2024) %>% 
  select(SUIT_E) %>% 
  st_as_sf() %>% 
  mutate(idx = row_number()) %>% 
  select(idx, geometry)

# crop regular grid to match the outline of europe
cells_europe <- st_intersection(template, europe)

# do the same for grid cells in germany
cells_germany <- template %>% 
  st_crop(st_bbox(germany)) %>% 
  st_intersection(germany) %>% 
  select(idx, geometry)

# -> use these cropped cells for plotting 
# -> `crop_to` will grab these templates by joining over the cell index


# Export ------------------------------------------------------------------

dir.create(here("src/data/processed/pitch/cells_europe"), recursive = TRUE)
write_sf(cells_europe,
         here("src/data/processed/pitch/cells_europe/cells_europe.shp"))

dir.create(here("src/data/processed/pitch/cells_germany"))
write_sf(cells_germany,
         here("src/data/processed/pitch/cells_germany/cells_germany.shp"))


# Cleanup -----------------------------------------------------------------

sf_use_s2(TRUE)

