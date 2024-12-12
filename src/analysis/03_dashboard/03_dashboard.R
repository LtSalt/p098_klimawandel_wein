################################################################################
# 03 DASHBOARD
################################################################################



# Import ------------------------------------------------------------------

sims <- read_sf(here("src/data/processed/dashboard/predictions_germany/predictions_germany.shp"))

states <- read_sf(here("src/data/raw/vg2500_12-31.gk3.shape/vg2500/VG2500_LAN.shp")) %>%
  filter(GF == 9) %>% 
  st_transform(4326)

krs <- read_sf(here("src/data/raw/vg2500_12-31.gk3.shape/vg2500/VG2500_KRS.shp")) %>% 
  st_transform(4326)


# App ---------------------------------------------------------------------

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      selectInput("scen", "Szenario", c("rcp45", "rcp85")),
      numericInput("year", "Jahr", value = 2050, min = 2024, max = 2099),
      selectInput("level", "Ebene", c("Grid", "Landkreise")),
      plotOutput("variability"),
    ),
    mainPanel(
      plotOutput("types"),
      plotOutput("evolution")
    )
  )
)

server <- function(input, output, session) {
  
  baseline <- reactive(get_map_data(sims, input$scen, 2024, input$level))
  target <- reactive(get_map_data(sims, input$scen, input$year, input$level))
  
  output$variability <- renderPlot({ plot_variability(target()) })
  output$types <- renderPlot({ plot_types(target()) })
  output$evolution <- renderPlot({ plot_evolution(bind_rows(baseline(), target())) })
}