################################################################################
# 02 HELPERS
################################################################################



# Import ------------------------------------------------------------------

sims <- read_sf(here("src/data/processed/dashboard/predictions_germany/predictions_germany.shp"))


# Slice data for shiny maps -----------------------------------------------

get_map_data <- function(sims, Scenario, Year, Level) {
  dict_types <- c(
    "SUIT_E$" = "Sehr früh",
    "SUIT_EM" = "Früh",
    "SUIT_M$" = "Mittel",
    "SUIT_ML" = "Spät",
    "SUIT_L$" = "Sehr spät"
  )
  
  threshold <- 0.65
  
  sims %>% 
    filter(scenario == Scenario,
           year == Year,
           level == Level) %>% 
    mutate(idx = row_number()) %>% 
    pivot_longer(SUIT_E:SUIT_L, names_to = "type", values_to = "suitability") %>%
    mutate(type = str_replace_all(type, dict_types),
           type = fct_relevel(as.factor(type), dict_types),
           suitable = ifelse(suitability >= threshold, TRUE, FALSE)) 
}


# Plot variability --------------------------------------------------------

plot_variability <- function(sims) {
  sims %>% 
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
          legend.key.spacing.x = unit(0, "cm")) +
    geom_sf(data = krs, fill = NA, lwd = 0.1)
}


# Plot Types --------------------------------------------------------------

plot_types <- function(sf) {
  sf %>% 
    ggplot() +
    geom_sf(aes(fill = suitable, color = suitable)) +
    geom_sf(data = states, fill = NA, color = "black", lwd = 0.1) +
    facet_grid(cols = vars(type)) +
    labs(fill = NULL, color = NULL) +
    scale_fill_manual(values = c("#4C4F8B", "#53914D"), labels = c("geeignet", "ungeeignet")) +
    scale_color_manual(values = c("#4C4F8B", "#53914D"), labels = c("geeignet", "ungeeignet")) +
    labs(title = "Eignung nach Weintypen") +
    theme_light() +
    theme(panel.grid = element_blank(),
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          legend.position = "bottom") +
    geom_sf(data = krs, fill = NA, color = "white", lwd = 0.01)
}

plot_evolution <- function(sf) {
  custom_palette <- c("Geht verloren" = "#F8766D", "Hält sich" = "#00BA38", "Kommt dazu" = "#619CFF")
  
  sf %>% 
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
    labs(title = "Entwicklung nach Weintypen") +
    geom_sf(data = krs, fill = NA, color = "white", lwd = 0.01)
}



