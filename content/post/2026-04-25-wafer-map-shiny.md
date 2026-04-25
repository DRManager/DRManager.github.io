---
title: "Interactive Wafer Map Visualization with R Shiny"
date: "2026-04-25T13:00:00+00:00"
tags:
  - R
  - Shiny
  - Semiconductor
  - Wafer Map
  - Data Visualization
categories:
  - Technical
slug: "wafer-map-visualization-r-shiny"
description: "A step-by-step walkthrough of an R Shiny app that renders colour-coded wafer maps from die-level (x, y, measurement) data, with interactive filtering, distribution plots, and CSV export."
---

## Overview

In semiconductor manufacturing, a **wafer map** shows how a measured parameter
(film thickness, critical dimension, overlay error, …) varies across every die
on a wafer.  Spotting spatial patterns — centre-thick, edge roll-off, hot
spots — is crucial for process control and yield improvement.

The Shiny app in [`wafer_map_app/app.R`](https://github.com/DRManager/DRManager.github.io/tree/main/wafer_map_app)
lets engineers drop in a CSV and get an interactive map in seconds.

---

## Data Format

The app expects a CSV with at least three columns:

| Column        | Type    | Description                           |
|---------------|---------|---------------------------------------|
| `x`           | numeric | Die X coordinate (mm)                 |
| `y`           | numeric | Die Y coordinate (mm)                 |
| `measurement` | numeric | Numeric measurement value             |
| `status`      | string  | Optional — `Pass` / `Fail`            |

A sample dataset (`sample_wafer_data.csv`) is included so you can explore the
app immediately without your own data.

---

## Running the App

Install the dependencies once:

```r
install.packages(c("shiny", "ggplot2", "dplyr", "scales", "DT", "readr"))
```

Then launch:

```r
shiny::runApp("wafer_map_app/app.R")
```

---

## App Walkthrough

### Wafer Map tab

Each die is drawn as a coloured tile at its (x, y) position.  The fill colour
encodes the measurement value using the selected colour palette.  Hovering over
a tile shows the exact coordinates, measurement, and Pass/Fail status in a
status bar below the map.

Optional overlays include the wafer boundary circle and a flat/notch marker at
the bottom of the wafer.

### Distribution tab

Three supplementary plots help characterise the measurement population:

1. **Histogram** — distribution of values coloured by Pass/Fail status.
2. **Box plot** — side-by-side comparison of Pass and Fail distributions.
3. **Radial profile** — measurement vs. distance from wafer centre with a
   LOESS smoothing curve, revealing radial non-uniformity patterns.

### Data Table tab

A sortable, column-filterable table of every die in the current filter set.
Pass rows are highlighted green and Fail rows red.

---

## Key Implementation Details

### Generating the wafer boundary circle

```r
wafer_circle <- function(radius = 150, n = 360) {
  theta <- seq(0, 2 * pi, length.out = n)
  data.frame(x = radius * cos(theta), y = radius * sin(theta))
}
```

The circle is added as a `geom_path` layer so it sits on top of the die tiles
without interfering with the fill scale.

### Colour palettes

The app exposes five palettes via `ggplot2`:

| Name     | Best for                          |
|----------|-----------------------------------|
| Viridis  | Sequential, perceptually uniform  |
| Plasma   | Sequential, high contrast         |
| RdYlGn   | Diverging Pass/Fail spec window   |
| RdBu     | Diverging positive/negative error |
| Spectral | Diverging, broad range            |

### Reactive filtering

The measurement range slider and Pass/Fail checkboxes feed a `filtered_data()`
reactive expression that gates all five output objects (wafer map, histogram,
box plot, radial plot, data table) — so every view stays in sync.

---

## Extending the App

A few ideas for further development:

- **Multi-wafer comparison** — accept a column that identifies the wafer ID and
  add a faceted or tabbed view.
- **Spec limits** — add numeric inputs for LSL/USL and auto-colour dies outside
  spec as Fail.
- **Statistical control charts** — plot mean and standard deviation vs. wafer
  run order to detect process drift.
- **3-sigma outlier flagging** — automatically highlight dies more than 3σ from
  the lot mean.

---

## Source Code

The complete source is available in the repository:

```
wafer_map_app/
├── app.R                  # Shiny application
├── sample_wafer_data.csv  # 300 mm wafer demo dataset
└── README.md              # Setup and usage instructions
```
