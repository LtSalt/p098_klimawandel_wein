################################################################################
# 02 HELPERS
################################################################################


# Dependencies ------------------------------------------------------------

if (!"pacman" %in% installed.packages()) install.packages("pacman")
pacman::p_load(tidyverse, sf, RColorBrewer)


# Import ------------------------------------------------------------------

states <- read_sf(here("src/data/raw/vg2500_12-31.gk3.shape/vg2500/VG2500_LAN.shp")) %>%
  filter(GF == 9) %>% 
  st_transform(4326)

krs <- read_sf(here("src/data/raw/vg2500_12-31.gk3.shape/vg2500/VG2500_KRS.shp")) %>% 
  st_transform(4326) %>% 
  select(name = GEN,
         geometry)

# Variables ---------------------------------------------------------------

dict_types <- c(
    "SUIT_E$" = "Sehr früh",
    "SUIT_EM" = "Früh",
    "SUIT_M$" = "Mittel",
    "SUIT_ML" = "Spät",
    "SUIT_L$" = "Sehr spät"
)
  
threshold <- 0.65


# Reusable wrangling helper -----------------------------------------------

wrangle <- function(sf) {
  sf %>% 
    pivot_longer(SUIT_E:SUIT_L, names_to = "type", values_to = "suitability") %>%
    mutate(type = str_replace_all(type, dict_types),
           type = fct_relevel(as.factor(type), dict_types),
           suitable = ifelse(suitability >= threshold, TRUE, FALSE)) 
}


# Slice data for shiny maps -----------------------------------------------

get_map_data <- function(sims, Scenario, Year, Level) {
  sims %>% 
    filter(scenario == Scenario,
           year == Year,
           level == Level) %>% 
    mutate(idx = row_number()) %>% 
    wrangle()
}

get_regional_data <- function(sims, Scenario, search) {
  sims %>% 
    filter(scenario == Scenario, 
           level == "Landkreise",
           name == search) %>% 
   wrangle()
}



# Plot --------------------------------------------------------------------

plot_variability <- function(sims, level) {
  p <- sims %>% 
    mutate(score = as.factor(sum(suitable)), .by = c(idx)) %>% 
    distinct(idx, .keep_all = TRUE) %>% 
    ggplot() +
    geom_sf(aes(fill = score, color = score), show.legend = TRUE) +
    geom_sf(data = states, fill = NA, color = "black", lwd = 0.1) +
    theme_light() +
    scale_fill_brewer(palette = "Greens",
                      limits = c("0", "1", "2", "3", "4", "5")) +
    scale_color_brewer(palette = "Greens",
                       limits = c("0", "1", "2", "3", "4", "5")) +
    guides(fill = guide_legend(nrow = 1),
           color = guide_legend(nrow = 1)) +
    labs(fill = "Variabilität",
         color = "Variabilität",
         title = "Variabiliät") +
    theme(panel.grid = element_blank(),
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          legend.position = "bottom",
          legend.text.position = "bottom",
          legend.title.position = "top",
          legend.title = element_blank(),
          legend.key.spacing.x = unit(0, "cm"))
  
  if (level == "Grid") {
    p
  } else {
    p +
      geom_sf(data = krs, fill = NA, lwd = 0.1)
  }
}

plot_types <- function(sf, level) {
  p <- sf %>% 
    ggplot() +
    geom_sf(aes(fill = suitable, color = suitable)) +
    geom_sf(data = states, fill = NA, color = "black", lwd = 0.1) +
    facet_grid(cols = vars(type)) +
    labs(fill = NULL, color = NULL) +
    scale_fill_manual(values = c("#4C4F8B", "#53914D"), labels = c("ungeeignet", "geeignet")) +
    scale_color_manual(values = c("#4C4F8B", "#53914D"), labels = c("ungeeignet", "geeignet")) +
    labs(title = "Eignung nach Weintypen") +
    theme_light() +
    theme(panel.grid = element_blank(),
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          legend.position = "bottom")

  if (level == "Grid") {
    p
  } else {
    p +
      geom_sf(data = krs, fill = NA, color = "white", lwd = 0.01)
  }
}

plot_evolution <- function(sf, level) {
  custom_palette <- c("Geht verloren" = "#F8766D", "Hält sich" = "#00BA38", "Kommt dazu" = "#619CFF")
  
  p <- sf %>% 
    select(-suitability) %>% 
    mutate(year = ifelse(year == 2024, "now", "then")) %>% 
    pivot_wider(names_from = year, values_from = suitable) %>% 
    mutate(region = case_when(then > now ~ "Kommt dazu",
                              then & now ~ "Hält sich",
                              then < now ~ "Geht verloren",
                              !(then | now) ~  NA_character_)) %>% 
    ggplot() +
    geom_sf(aes(fill = region, color = region)) +
    geom_sf(data = states, fill = NA, color = "black", lwd = 0.1) +
    facet_grid(cols = vars(type)) +
    theme_light() +
    scale_fill_manual(values = custom_palette, limits = names(custom_palette)) +
    scale_color_manual(values = custom_palette, limits = names(custom_palette)) +
    theme(panel.grid = element_blank(),
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          legend.position = "bottom",
          legend.title = element_blank()) +
    labs(title = "Entwicklung nach Weintypen")
  
  if (level == "Grid") {
    p
  } else {
    p +
      geom_sf(data = krs, fill = NA, color = "white", lwd = 0.01)
  }
}

plot_linegraph <- function(sf, Year) {
  sf %>% 
    ggplot() +
    geom_line(aes(x = year, y = suitability, color = type)) +
    geom_vline(xintercept = Year, linetype = "dashed") +
    geom_hline(yintercept = threshold, linetype = "dashed") +
    theme_light() +
    scale_color_manual(values = brewer.pal(5, "Greens")) +
    coord_cartesian(expand = FALSE, xlim = c(1980, 2100), ylim = c(0, 1)) +
    labs(x = NULL,
         y = "Suitability",
         color = "Weintyp")
}

