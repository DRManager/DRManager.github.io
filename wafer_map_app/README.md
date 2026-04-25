# Wafer Map Visualizer — R Shiny App

This directory contains an R Shiny application for interactive die-level wafer
map visualisation.

## Requirements

Install the required R packages before running:

```r
install.packages(c("shiny", "ggplot2", "dplyr", "scales", "DT", "readr"))
```

## Running the app

From R or RStudio:

```r
shiny::runApp("wafer_map_app/app.R")
```

Or from the terminal:

```bash
Rscript -e "shiny::runApp('wafer_map_app/app.R')"
```

## Input data format

The app accepts a CSV with the following columns:

| Column        | Type    | Required | Description                                  |
|---------------|---------|----------|----------------------------------------------|
| `x`           | numeric | yes      | Die X coordinate (mm)                        |
| `y`           | numeric | yes      | Die Y coordinate (mm)                        |
| `measurement` | numeric | yes      | Measurement value (thickness, CD, overlay …) |
| `status`      | string  | no       | `Pass` / `Fail` (auto-computed if omitted)   |

A pre-built `sample_wafer_data.csv` is included in this directory.

## Features

- **Wafer Map tab** — colour-coded tile map with wafer edge, notch marker, and
  interactive hover tooltip showing die coordinates and measurement value.
- **Distribution tab** — measurement histogram, Pass/Fail box-plot, and radial
  profile (measurement vs. distance from wafer centre).
- **Data Table tab** — sortable, column-filterable table with colour-coded
  Pass/Fail rows.
- **Filters** — measurement range slider and Pass/Fail status checkboxes.
- **Display options** — five colour palettes (Viridis, Plasma, RdYlGn, RdBu,
  Spectral), Y-axis flip, optional die value labels.
- **Export** — filtered data as CSV and the current wafer map as a PNG.
