# Wafer Map Visualization — R Shiny App
# Visualizes measurement results on a wafer using x,y die coordinates.
# Supports CSV upload or built-in sample data generation.

library(shiny)
library(ggplot2)
library(dplyr)
library(scales)
library(DT)
library(readr)

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

#' Generate sample wafer data (circular die grid with simulated measurements)
generate_sample_data <- function(wafer_radius = 150, die_size = 10,
                                  seed = 42) {
  set.seed(seed)
  coords <- expand.grid(
    x = seq(-wafer_radius, wafer_radius, by = die_size),
    y = seq(-wafer_radius, wafer_radius, by = die_size)
  )
  # Keep only dies inside wafer boundary (edge exclusion = 5 mm)
  coords <- coords[sqrt(coords$x^2 + coords$y^2) <= (wafer_radius - 5), ]

  n <- nrow(coords)
  # Simulate a centre-thick + random noise measurement pattern
  r <- sqrt(coords$x^2 + coords$y^2)
  coords$measurement <- 200 - 0.003 * r^2 + rnorm(n, mean = 0, sd = 3)

  # Add a categorical pass/fail column (spec: 185 - 215)
  coords$status <- ifelse(coords$measurement >= 185 & coords$measurement <= 215,
                          "Pass", "Fail")
  coords
}

#' Build a wafer boundary circle for ggplot annotation
wafer_circle <- function(radius = 150, n = 360) {
  theta <- seq(0, 2 * pi, length.out = n)
  data.frame(x = radius * cos(theta), y = radius * sin(theta))
}

#' Return the appropriate ggplot2 fill scale
palette_function <- function(name) {
  switch(name,
    "Viridis"   = scale_fill_viridis_c(option = "viridis"),
    "Plasma"    = scale_fill_viridis_c(option = "plasma"),
    "RdYlGn"    = scale_fill_distiller(palette = "RdYlGn",   direction = 1),
    "RdBu"      = scale_fill_distiller(palette = "RdBu",     direction = 1),
    "Spectral"  = scale_fill_distiller(palette = "Spectral", direction = 1),
    scale_fill_viridis_c(option = "viridis")
  )
}

# ---------------------------------------------------------------------------
# UI
# ---------------------------------------------------------------------------

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; }
      .well { background-color: #f8f9fa; border: 1px solid #dee2e6; }
      h3 { color: #2c3e50; }
      .stat-box {
        background: #fff;
        border: 1px solid #dee2e6;
        border-radius: 4px;
        padding: 10px 15px;
        margin-bottom: 8px;
      }
      .stat-label { font-size: 12px; color: #6c757d; margin-bottom: 2px; }
      .stat-value { font-size: 20px; font-weight: bold; color: #2c3e50; }
    "))
  ),

  titlePanel(
    div(
      h2("Wafer Map Visualizer", style = "margin-bottom:4px;"),
      p("Interactive die-level measurement viewer for semiconductor wafers",
        style = "color:#6c757d; font-size:14px; margin-top:0;")
    )
  ),

  sidebarLayout(
    sidebarPanel(
      width = 3,

      # --- Data source ---
      h4("Data Source"),
      radioButtons("data_source", label = NULL,
                   choices = c("Use sample data" = "sample",
                                "Upload CSV"       = "upload")),

      conditionalPanel(
        condition = "input.data_source == 'upload'",
        fileInput("csv_file", "Choose CSV file",
                  accept = c(".csv", "text/csv")),
        helpText("Required columns: x, y, measurement.
                  Optional column: status (Pass/Fail).")
      ),

      conditionalPanel(
        condition = "input.data_source == 'sample'",
        sliderInput("wafer_radius", "Wafer radius (mm)",
                    min = 50, max = 300, value = 150, step = 25),
        sliderInput("die_size", "Die pitch (mm)",
                    min = 5, max = 30, value = 10, step = 1),
        numericInput("seed", "Random seed", value = 42, min = 1, max = 9999)
      ),

      hr(),

      # --- Display options ---
      h4("Display Options"),
      selectInput("color_palette", "Color palette",
                  choices  = c("Viridis", "Plasma", "RdYlGn", "RdBu", "Spectral"),
                  selected = "RdYlGn"),

      checkboxInput("show_wafer_edge", "Show wafer boundary", value = TRUE),
      checkboxInput("show_notch",      "Show notch marker",   value = TRUE),
      checkboxInput("show_values",     "Show measurement values on dies",
                    value = FALSE),
      checkboxInput("flip_y",          "Flip Y axis (wafer flat at bottom)",
                    value = FALSE),

      hr(),

      # --- Filters ---
      h4("Filters"),
      uiOutput("meas_range_ui"),
      checkboxGroupInput("status_filter", "Status",
                         choices  = c("Pass", "Fail"),
                         selected = c("Pass", "Fail")),

      hr(),

      # --- Download ---
      h4("Export"),
      downloadButton("download_data", "Download data (CSV)"),
      br(), br(),
      downloadButton("download_plot", "Download wafer map (PNG)")
    ),

    mainPanel(
      width = 9,
      tabsetPanel(
        tabPanel(
          "Wafer Map",
          br(),
          fluidRow(
            column(3, div(class = "stat-box",
              div(class = "stat-label", "Total dies"),
              div(class = "stat-value", textOutput("stat_total", inline = TRUE))
            )),
            column(3, div(class = "stat-box",
              div(class = "stat-label", "Yield (Pass %)"),
              div(class = "stat-value", textOutput("stat_yield", inline = TRUE))
            )),
            column(3, div(class = "stat-box",
              div(class = "stat-label", "Mean measurement"),
              div(class = "stat-value", textOutput("stat_mean", inline = TRUE))
            )),
            column(3, div(class = "stat-box",
              div(class = "stat-label", "Std deviation"),
              div(class = "stat-value", textOutput("stat_sd", inline = TRUE))
            ))
          ),
          br(),
          plotOutput("wafer_map", height = "550px",
                     hover = hoverOpts("plot_hover", delay = 80)),
          verbatimTextOutput("hover_info")
        ),

        tabPanel(
          "Distribution",
          br(),
          fluidRow(
            column(6, plotOutput("hist_plot", height = "350px")),
            column(6, plotOutput("box_plot",  height = "350px"))
          ),
          br(),
          fluidRow(
            column(12, plotOutput("radial_plot", height = "350px"))
          )
        ),

        tabPanel(
          "Data Table",
          br(),
          DTOutput("data_table")
        ),

        tabPanel(
          "How to Use",
          br(),
          uiOutput("help_text")
        )
      )
    )
  )
)

# ---------------------------------------------------------------------------
# Server
# ---------------------------------------------------------------------------

server <- function(input, output, session) {

  # --- Reactive: raw data ---
  raw_data <- reactive({
    if (input$data_source == "sample") {
      generate_sample_data(wafer_radius = input$wafer_radius,
                           die_size     = input$die_size,
                           seed         = input$seed)
    } else {
      req(input$csv_file)
      df <- tryCatch(
        read_csv(input$csv_file$datapath, show_col_types = FALSE),
        error = function(e) NULL
      )
      validate(
        need(!is.null(df),
             "Could not read file. Please upload a valid CSV."),
        need("x"           %in% names(df) &&
               "y"           %in% names(df) &&
               "measurement" %in% names(df),
             "CSV must contain columns: x, y, measurement")
      )
      if (!"status" %in% names(df)) df$status <- "Pass"
      df
    }
  })

  # --- Dynamic measurement range slider ---
  output$meas_range_ui <- renderUI({
    df <- raw_data()
    mn <- floor(min(df$measurement,   na.rm = TRUE))
    mx <- ceiling(max(df$measurement, na.rm = TRUE))
    sliderInput("meas_range", "Measurement range",
                min   = mn, max = mx,
                value = c(mn, mx), step = 0.1)
  })

  # --- Reactive: filtered data ---
  filtered_data <- reactive({
    df <- raw_data()
    req(input$meas_range)
    df %>%
      filter(
        measurement >= input$meas_range[1],
        measurement <= input$meas_range[2],
        status %in% input$status_filter
      )
  })

  # --- Summary statistics ---
  output$stat_total <- renderText({ nrow(filtered_data()) })

  output$stat_yield <- renderText({
    df <- filtered_data()
    if (nrow(df) == 0) return("N/A")
    sprintf("%.1f%%", mean(df$status == "Pass", na.rm = TRUE) * 100)
  })

  output$stat_mean <- renderText({
    sprintf("%.2f", mean(filtered_data()$measurement, na.rm = TRUE))
  })

  output$stat_sd <- renderText({
    sprintf("%.2f", sd(filtered_data()$measurement, na.rm = TRUE))
  })

  # --- Wafer map (shared between render and download) ---
  wafer_map_plot <- reactive({
    df <- filtered_data()
    validate(need(nrow(df) > 0, "No data to display after filtering."))

    radius <- if (input$data_source == "sample") {
      input$wafer_radius
    } else {
      ceiling(max(sqrt(raw_data()$x^2 + raw_data()$y^2), na.rm = TRUE)) + 5
    }

    ds <- if (input$data_source == "sample") {
      input$die_size
    } else {
      xs <- sort(unique(raw_data()$x))
      if (length(xs) > 1) diff(xs)[1] else 10
    }

    p <- ggplot(df, aes(x = x, y = y, fill = measurement)) +
      geom_tile(width = ds * 0.92, height = ds * 0.92,
                colour = "white", linewidth = 0.2) +
      palette_function(input$color_palette) +
      coord_fixed() +
      labs(
        title = "Wafer Map",
        x     = "X coordinate (mm)",
        y     = "Y coordinate (mm)",
        fill  = "Measurement"
      ) +
      theme_minimal(base_size = 13) +
      theme(
        plot.title     = element_text(face = "bold", hjust = 0.5),
        legend.position = "right",
        panel.grid      = element_blank()
      )

    if (input$show_wafer_edge) {
      circle_df <- wafer_circle(radius)
      p <- p +
        geom_path(data = circle_df, aes(x = x, y = y),
                  inherit.aes = FALSE,
                  colour = "black", linewidth = 0.8)
    }

    if (input$show_notch) {
      notch_size <- radius * 0.04
      notch_df <- data.frame(
        x = c(-notch_size, 0,  notch_size),
        y = c(-radius,     -radius - notch_size * 1.5, -radius)
      )
      p <- p +
        geom_polygon(data = notch_df, aes(x = x, y = y),
                     inherit.aes = FALSE, fill = "black")
    }

    if (input$show_values) {
      p <- p +
        geom_text(aes(label = round(measurement, 1)),
                  size = 2.5, colour = "black")
    }

    if (input$flip_y) p <- p + scale_y_reverse()

    p
  })

  output$wafer_map <- renderPlot({ wafer_map_plot() })

  # --- Hover tooltip ---
  output$hover_info <- renderText({
    hover <- input$plot_hover
    df    <- filtered_data()
    if (is.null(hover) || nrow(df) == 0) return("")

    df$dist <- sqrt((df$x - hover$x)^2 + (df$y - hover$y)^2)
    nearest  <- df[which.min(df$dist), ]
    ds       <- if (input$data_source == "sample") input$die_size else 10

    if (nearest$dist > ds) return("")
    sprintf(
      "Die  x=%.0f  y=%.0f   |   Measurement: %.3f   |   Status: %s",
      nearest$x, nearest$y, nearest$measurement, nearest$status
    )
  })

  # --- Distribution tab ---
  output$hist_plot <- renderPlot({
    df <- filtered_data()
    validate(need(nrow(df) > 0, "No data."))

    ggplot(df, aes(x = measurement, fill = status)) +
      geom_histogram(bins = 30, colour = "white", linewidth = 0.2) +
      scale_fill_manual(
        values = c("Pass" = "#2ecc71", "Fail" = "#e74c3c"),
        drop   = FALSE
      ) +
      labs(title = "Measurement Distribution",
           x = "Measurement", y = "Count", fill = "Status") +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(face = "bold", hjust = 0.5))
  })

  output$box_plot <- renderPlot({
    df <- filtered_data()
    validate(need(nrow(df) > 0, "No data."))

    ggplot(df, aes(x = status, y = measurement, fill = status)) +
      geom_boxplot(outlier.shape = 21, outlier.size = 2, colour = "grey40") +
      geom_jitter(width = 0.15, alpha = 0.25, size = 1) +
      scale_fill_manual(
        values = c("Pass" = "#2ecc71", "Fail" = "#e74c3c"),
        drop   = FALSE
      ) +
      labs(title = "Measurement by Status",
           x = "Status", y = "Measurement") +
      theme_minimal(base_size = 12) +
      theme(plot.title     = element_text(face = "bold", hjust = 0.5),
            legend.position = "none")
  })

  output$radial_plot <- renderPlot({
    df <- filtered_data()
    validate(need(nrow(df) > 0, "No data."))

    df$radius_mm <- sqrt(df$x^2 + df$y^2)

    ggplot(df, aes(x = radius_mm, y = measurement)) +
      geom_point(aes(colour = status), alpha = 0.55, size = 2) +
      geom_smooth(method  = "loess", formula = y ~ x,
                  colour  = "#2c3e50", se = TRUE, linewidth = 1) +
      scale_colour_manual(
        values = c("Pass" = "#2ecc71", "Fail" = "#e74c3c"),
        drop   = FALSE
      ) +
      labs(title  = "Measurement vs. Radial Distance",
           x      = "Radial distance (mm)",
           y      = "Measurement",
           colour = "Status") +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(face = "bold", hjust = 0.5))
  })

  # --- Data table ---
  output$data_table <- renderDT({
    df <- filtered_data()
    df$measurement <- round(df$measurement, 4)
    datatable(
      df,
      options  = list(pageLength = 20, scrollX = TRUE),
      rownames = FALSE,
      filter   = "top"
    ) %>%
      formatStyle(
        "status",
        backgroundColor = styleEqual(
          c("Pass", "Fail"),
          c("#d4edda", "#f8d7da")
        )
      )
  })

  # --- Help tab ---
  output$help_text <- renderUI({
    tagList(
      h4("Overview"),
      p("This app visualises die-level measurement results on a semiconductor
        wafer. Each coloured tile represents one die location identified by its
        (x, y) coordinates on the wafer."),

      h4("Data Format"),
      tags$ul(
        tags$li(strong("x"), " — die X coordinate (mm, integer or float)"),
        tags$li(strong("y"), " — die Y coordinate (mm, integer or float)"),
        tags$li(strong("measurement"), " — numeric measurement value
                (e.g. film thickness, CD, overlay ...)"),
        tags$li(strong("status"), " (optional) — Pass / Fail classification;
                if omitted every die is treated as Pass")
      ),

      h4("Example CSV"),
      tags$pre(
"x,y,measurement,status
-10,-10,199.8,Pass
0,-10,201.2,Pass
10,-10,185.0,Fail"
      ),

      h4("Tabs"),
      tags$ul(
        tags$li(strong("Wafer Map"),
                " — colour-coded tile map; hover over a die for details."),
        tags$li(strong("Distribution"),
                " — histogram, box-plot, and radial profile."),
        tags$li(strong("Data Table"),
                " — sortable, filterable table of all dies in the current
                  filter set.")
      ),

      h4("Controls"),
      tags$ul(
        tags$li(strong("Color palette"), " — choose a diverging or sequential
                colour scale."),
        tags$li(strong("Show wafer boundary"), " — overlay the wafer edge
                circle."),
        tags$li(strong("Show notch marker"), " — draw a flat/notch indicator
                at the bottom."),
        tags$li(strong("Show measurement values"), " — print each die's value
                on the tile (best with large die pitch)."),
        tags$li(strong("Flip Y axis"), " — orient the map with the wafer flat
                at the bottom."),
        tags$li(strong("Measurement range / Status"), " — filter out-of-spec
                or unwanted dies.")
      )
    )
  })

  # --- Downloads ---
  output$download_data <- downloadHandler(
    filename = "wafer_data.csv",
    content  = function(file) write_csv(filtered_data(), file)
  )

  output$download_plot <- downloadHandler(
    filename = "wafer_map.png",
    content  = function(file) {
      ggsave(file, plot = wafer_map_plot(),
             width = 8, height = 7, dpi = 180, bg = "white")
    }
  )
}

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------

shinyApp(ui = ui, server = server)
