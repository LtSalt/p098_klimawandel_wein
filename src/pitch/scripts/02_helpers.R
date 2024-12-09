################################################################################
# HELPERS
# 
# Wrangling and plotting helpers for pitch
################################################################################


# Dependencies ------------------------------------------------------------

if (!"pacman" %in% installed.packages()) install.packages("pacman")
pacman::p_load(tidyverse, sf, stars, lubridate)


# Import ------------------------------------------------------------------

cells_europe <- read_sf(here("src/data/processed/cells/europe/europe.shp"))
cells_germany <- read_sf(here("src/data/processed/cells/germany/germany.shp"))


# Slice NETCDF data cube --------------------------------------------------

get_slice <- function(sims, scen, year) {
  sims %>% 
    filter(scenario == scen,
           year(TIME) == year) %>% 
    st_as_sf() %>% 
    mutate(idx = row_number(),
           scenario = scen,
           year = year)
}

get_slices <- function(sims, scens, years) {
  combinations <- as.list(expand_grid(scens, years))
  
  map2(combinations$scens, combinations$years, 
       \(scen, year) get_slice(sims, scen, year)) %>% 
    bind_rows()
}


# Grab cropped cells ------------------------------------------------------

crop_to <- function(sf, region) {
  cells <- switch(region,
                  "europe" = cells_europe,
                  "germany" = cells_germany,
                  stop("Must define a valid region"))
  
  crs <- st_crs(sf)
  
  sf %>%
    as_tibble() %>%
    right_join(cells, by = "idx") %>%
    select(-geometry.x) %>%
    rename(geometry = geometry.y) %>%
    st_as_sf(crs = crs)
}


# Compute suitability scores ----------------------------------------------

# suitabitlity index ranges from 0 to 1. 
# all values equal to or greater than 0.65 are considered suitable (see paper)
cutoff <- 0.65

compute_scores <- function(sf) {
  sf %>% 
    mutate(across(SUIT_E:SUIT_L, \(value) value >= cutoff),
           score = SUIT_E + SUIT_EM + SUIT_M + SUIT_ML + SUIT_L,
           suitable = score > 0,
           score = as.factor(score))
}


# Save plots for gif ------------------------------------------------------

save_png <- function(YEAR, dest) {
  p <- sims %>% 
    get_slice("rcp45", YEAR) %>% 
    crop_to("europe") %>% 
    compute_scores() %>% 
    ggplot() +
    geom_sf(aes(fill = suitable, color = suitable)) +
    geom_sf(data = countries, fill = NA, color = "#292A50", lwd = 0.1) +
    theme_binary() +
    labs(title = YEAR)
  
  ggsave(paste0(dest, YEAR, ".png"), p)
}

save_pngs <- function(years, dest) {
  walk(years, \(year) save_png(year, dest))
}


# Themes ------------------------------------------------------------------

theme_binary <- function() {
  list(
    coord_sf(expand = FALSE),
    labs(fill = NULL, color = NULL),
    scale_fill_manual(values = c("#4C4F8B", "#53914D"), labels = c("geeignet", "ungeeignet")),
    scale_color_manual(values = c("#4C4F8B", "#53914D"), labels = c("geeignet", "ungeeignet")),
    theme_light() +
    theme(panel.grid = element_blank(),
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          legend.position = "none",
          panel.background = element_rect(fill = "#E5E7EB"))
  )
}
