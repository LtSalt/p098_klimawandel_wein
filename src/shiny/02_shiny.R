################################################################################
# Shiny App
################################################################################


# Dependencies ------------------------------------------------------------

if (!"pacman" %in% installed.packages()) install.packages("pacman")
pacman::p_load(here, 
               tidyverse, 
               sf, 
               shiny,
               RColorBrewer,
               lubridate)

source(here("src/shiny/01_prep.R"))


# UI ----------------------------------------------------------------------

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      selectInput("scen", "Szenario", c("rcp45", "rcp85")),
      numericInput("year", "Jahr", value = 2024, min = 1980, max = 2099),
    ),
    mainPanel(
      plotOutput("map", click = "map_click"),
      plotOutput("linegraph")
    )
  )
)


# Server ------------------------------------------------------------------

server <- function(input, output, session) {
  selection_time <- reactive(
    sims %>% 
      get_slices(input$scen, input$year) %>% 
      crop_to("germany") %>% 
      compute_scores()
  )
  
  output$map <- renderPlot({
    selection_time() %>% 
      ggplot() +
      geom_sf(aes(fill = score, color = score), show.legend = TRUE) +
      geom_sf(data = states, fill = NA, color = "black") +
      theme_light() +
      scale_fill_brewer(palette = "Greens",
                        limits = c("0", "1", "2", "3", "4", "5")) +
      scale_color_brewer(palette = "Greens",
                         limits = c("0", "1", "2", "3", "4", "5")) +
      guides(fill = guide_legend(nrow = 1),
             color = guide_legend(nrow = 1)) +
      labs(fill = "Variabilität",
           color = "Variabilität") +
      theme(panel.grid = element_blank(),
            axis.text = element_blank(),
            axis.ticks = element_blank(),
            legend.position = "top",
            legend.text.position = "bottom",
            legend.title.position = "top",
            legend.title = element_text(hjust = 0.5),
            legend.key.spacing.x = unit(0, "cm"))
  })
}


# Start App ---------------------------------------------------------------

shinyApp(ui = ui, server = server)
