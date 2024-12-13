################################################################################
# 03 DASHBOARD
################################################################################


# Dependencies ------------------------------------------------------------

if (!"pacman" %in% installed.packages()) install.packages("pacman")
pacman::p_load(here, tidyverse, bslib, shiny, sf)

source(here("src/analysis/03_dashboard/02_helpers.R"))


# Import ------------------------------------------------------------------

sims <- read_sf(here("src/data/processed/dashboard/predictions_germany/predictions_germany.shp"))


# App ---------------------------------------------------------------------

ui <- page_sidebar(
  title = "Weinanbau & Klimawandel in Deutschland",
  sidebar = sidebar(
      selectInput("scen", "Szenario", c("rcp45", "rcp85")),
      sliderInput("year", "Jahr", min = 2024, max = 2099, value = 2050, step = 1, ticks = FALSE, sep = ""),
      selectInput("level", "Ebene", c("Grid", "Landkreise")),
      plotOutput("variability"),
    ),
  navset_card_underline(
    nav_panel(
      title = "Flächen", 
      plotOutput("types"),
      plotOutput("evolution")
    ),
    nav_panel(
        title = "Landkreis-Suche",
        selectizeInput(
          "search",
          "",
          choices = krs$name,
          multiple = FALSE
        ),
    plotOutput("linegraph")
    )
  )
)

server <- function(input, output, session) {
  map_baseline <- reactive(get_map_data(sims, input$scen, 2024, input$level))
  map_target <- reactive(get_map_data(sims, input$scen, input$year, input$level))
  region_target <- reactive(get_regional_data(sims, input$scen, input$search))
  
  output$variability <- renderPlot({ plot_variability(map_target(), input$level) })
  output$types <- renderPlot({ plot_types(map_target(), input$level) })
  output$evolution <- renderPlot({ plot_evolution(bind_rows(map_baseline(), map_target()), input$level) })
  output$linegraph <- renderPlot({ plot_linegraph(region_target(), input$year) })
}

shinyApp(ui = ui, server = server)
