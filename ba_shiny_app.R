# Loading required packages
library(shiny)
library(tidyverse)
library(bslib)
library(scales)
library(plotly)

# Load data
ba_data <- readRDS("ba_data.rds")

# Reorder BAs: RTOs first, then non-RTOs
rto_bas <- c("CAISO", "ERCOT", "ISO-NE", "MISO", "NYISO", "PJM", "SPP")
non_rto_bas <- c("BPA", "DUKE-CP", "DUKE-FL", "FPL", "NEVP", "PACE", "PSCO", "SOCO", "TVA")
available_bas <- c(rto_bas, non_rto_bas)

# Create color palette
ba_colors <- scales::hue_pal()(length(available_bas))
names(ba_colors) <- available_bas

# Create linetype map
linetype_map <- setNames(
  c(rep("solid", length(rto_bas)), rep("dashed", length(non_rto_bas))),
  available_bas
)

# Metric type choices (applies to both capacity and generation)
metric_choices <- c(
  "Local-Mean Smoothed" = "smoothed",
  "Normalized to 1990" = "norm_1990",
  "Effective # of Firms" = "eff_num_firms"
)

# Column name mappings
gen_metrics <- c(
  smoothed = "hhi_gen_smoothed",
  norm_1990 = "norm_hhi_gen_smoothed",
  eff_num_firms = "eff_no_firms_smoothed_gen"
)

cap_metrics <- c(
  smoothed = "hhi_cap_smoothed",
  norm_1990 = "norm_hhi_cap_smoothed",
  eff_num_firms = "eff_no_firms_smoothed_cap"
)

# Display labels
metric_labels <- c(
  smoothed = "Local-Mean Smoothed HHI",
  norm_1990 = "HHI Normalized to 1990",
  eff_num_firms = "Effective # of Firms"
)

# UI
ui <- fluidPage(
  theme = bs_theme(version = 5, bootswatch = "minty"),
  
  tags$head(
    tags$link(rel = "stylesheet",
              href = "https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap"),
    tags$style(HTML("
      body, h1, h2, h3, h4, h5, h6, label, select, button {
        font-family: 'Roboto', sans-serif !important;
        font-size: 0.92rem !important;
        font-weight: 400 !important;
        color: #2c3e50;
      }
    "))
  ),
  
  titlePanel(""),
  tags$div(
    style = "font-size: 0.95rem; margin-top: 10px; margin-bottom: 0px; line-height: 1.5;",
    "Users can select balancing authorities and a metric of interest using the interactive controls below."
  ),
  tags$div(
    style = "font-size: 0.9rem; margin-top: 10px; margin-bottom: 20px; line-height: 1.5; color: #495057;",
    
    tags$strong("Note:"),
    " These figures show trends in Capacity HHI (top) and Generation HHI (bottom) for the sixteen largest balancing authorities in terms of 2024 total retail sales. RTO/ISO market areas and non-RTO/ISO market areas are shown with colored solid and dashed lines, respectively.",
    tags$br(),
    " The HHI values are smoothed via local-mean polynomial regression to reduce year-to-year noise (see Metric Definitions for further details)."
  ),
  
  hr(),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      
      fluidRow(
        column(
          width = 6,
          checkboxGroupInput(
            "ba_select_1",
            "RTO/ISO Markets:",
            choices = available_bas[1:7],
            selected = available_bas[1]
          ),
          actionButton(
            "select_all_rto",
            "Select All RTOs",
            style = "font-size: 0.85rem; padding: 4px 8px; margin-top: 5px;"
          )
        ),
        column(
          width = 6,
          checkboxGroupInput(
            "ba_select_2",
            "Non-RTO/ISO Markets:",
            choices = available_bas[8:16],
            selected = NULL
          ),
          actionButton(
            "select_all_non_rto",
            "Select All Non-RTOs",
            style = "font-size: 0.85rem; padding: 4px 8px; margin-top: 5px;"
          )
        )
      ),
      
      selectInput(
        "metric_select",
        "Select Metric Type:",
        choices = metric_choices,
        selected = "smoothed"
      ),
      
      actionButton(
        "reset",
        "Reset Selection",
        style = "margin-top: 10px;"
      ),
      
      hr(),
      
      tags$details(
        tags$summary(
          style = "cursor: pointer; font-weight: 500; color: #2c3e50; margin-bottom: 10px;",
          "Metric Definitions"
        ),
        tags$div(
          style = "font-size: 0.85rem; line-height: 1.5; color: #495057; padding-left: 10px;",
          tags$p(tags$strong("Note:"), "All HHI values are smoothed using local-mean smoothing (degree 0 polynomial) with Epanechnikov kernel to reduce year-to-year noise. Years 1998–2000 are excluded from smoothing due to changes in EIA survey instruments and widespread restructuring during this period that likely affected reporting consistency."),
          tags$p(tags$strong("Local-Mean Smoothed HHI:"), "HHI values range from near zero in markets with a large number of small firms to 10,000 in pure monopoly markets."),
          tags$p(tags$strong("Normalized to 1990:"), "HHI values indexed to 1990 baseline (1990 = 1.0) to show relative change over time."),
          tags$p(tags$strong("Effective # of Firms:"), "Calculated as 1/HHI. Represents the number of equal-sized firms that would produce the same concentration.")
        )
      ),
      hr(),
      
      htmlOutput("selection_summary")
    ),
    
    mainPanel(
      width = 9,
      
      plotlyOutput("capacity_plot", height = "500px"),
      
      hr(style = "margin-top: 30px; margin-bottom: 30px;"),
      
      plotlyOutput("generation_plot", height = "500px"),
        )
  )
)

# Server
server <- function(input, output, session) {
  
  # Select ALL RTOs 
  observeEvent(input$select_all_rto, {
    updateCheckboxGroupInput(
      session, "ba_select_1",
      selected = available_bas[1:7]
    )
    
    updateCheckboxGroupInput(
      session, "ba_select_2",
      selected = character(0)   
    )
  })
  
  # Select ALL Non-RTOs 
  observeEvent(input$select_all_non_rto, {
    updateCheckboxGroupInput(
      session, "ba_select_2",
      selected = available_bas[8:16]
    )
    
    updateCheckboxGroupInput(
      session, "ba_select_1",
      selected = character(0)   
    )
  })
  
  # Combine both BA selections
  selected_bas <- reactive({
    c(input$ba_select_1, input$ba_select_2)
  })
  
  # Reset button
  observeEvent(input$reset, {
    updateCheckboxGroupInput(session, "ba_select_1", selected = available_bas[1])
    updateCheckboxGroupInput(session, "ba_select_2", selected = character(0))
  })
  
  # Filter data for generation
  gen_data <- reactive({
    req(selected_bas(), input$metric_select)
    
    col_name <- gen_metrics[input$metric_select]
    
    ba_data %>%
      filter(ba_code %in% selected_bas()) %>%
      select(year, ba_code, value = !!sym(col_name))
  })
  
  # Filter data for capacity
  cap_data <- reactive({
    req(selected_bas(), input$metric_select)
    
    col_name <- cap_metrics[input$metric_select]
    
    ba_data %>%
      filter(ba_code %in% selected_bas()) %>%
      select(year, ba_code, value = !!sym(col_name))
  })
  
  # Summary text
  output$selection_summary <- renderUI({
    req(selected_bas(), input$metric_select)
    
    n_bas <- length(selected_bas())
    ba_list <- paste(selected_bas(), collapse = ", ")
    metric_label <- metric_labels[input$metric_select]
    
    HTML(sprintf(
      '<div style="font-size: 0.9rem; color: #6c757d;">
        <strong>Currently viewing:</strong><br>
        %d BA%s: %s<br>
        Metric: %s
      </div>',
      n_bas,
      ifelse(n_bas > 1, "s", ""),
      ba_list,
      metric_label
    ))
  })
  
  # Helper function to create plot
  create_plot <- function(df, title_suffix, y_label) {
    metric_label <- metric_labels[input$metric_select]
    
    p <- ggplot(df, aes(x = year, y = value, color = ba_code, linetype = ba_code, group = ba_code,
                        text = paste0("BA: ", ba_code, 
                                      "<br>Year: ", year,
                                      "<br>", y_label, ": ", round(value, 2)))) +
      geom_line(linewidth = 1.2) +
      scale_linetype_manual(
        name = "",
        values = linetype_map,
        na.value = "solid"
      ) +
      geom_point(size = 2.5, alpha = 0.7) +
      scale_color_manual(
        values = ba_colors,
        name = "Balancing\nAuthority"
      ) +
      scale_x_continuous(
        breaks = c(1990, 2000, 2010, 2020, 2024),
        minor_breaks = seq(1990, 2024, by = 1)
      ) +
      labs(
        title = paste(metric_label, "-", title_suffix),
        x = "Year",
        y = y_label
      ) +
      theme_minimal(base_size = 14) +
      theme(
        text = element_text(family = "Roboto"),   
        plot.title = element_text(size = 16, face = "bold", margin = margin(b = 15)),
        axis.title = element_text(size = 12, face = "bold"),
        axis.text = element_text(size = 10),
        legend.title = element_text(size = 11, face = "bold"),
        legend.text = element_text(size = 10),
        legend.position = "right",
        panel.grid.major = element_line(color = "grey90"),
        panel.grid.minor = element_line(color = "grey95"),
        plot.margin = margin(10, 10, 10, 10)
      )
    
    ggplotly(p, tooltip = "text") %>%
      plotly::layout(
        font = list(family = "Roboto"),  
        hovermode = "closest",
        hoverlabel = list(
          bgcolor = "white",
          font = list(family = "Roboto", size = 12)
        ),
        annotations = list(
          list(
            x = 1,
            y = -0.1,
            text = "Source: EIA-860 and EIA-861 · Duke University Nicholas Institute (Weintraut, B., Parajon, E., Gowdy, T.M.)",
            showarrow = FALSE,
            xref = "paper",
            yref = "paper",
            xanchor = "right",
            yanchor = "auto",
            font = list(size = 10, color = "#6c757d")
          )
        )
      ) %>%
      plotly::config(
        displayModeBar = TRUE,
        displaylogo = FALSE,
        modeBarButtonsToRemove = c(
          "select2d", 
          "lasso2d", 
          "autoScale2d",
          "toggleSpikelines",
          "zoom",
          "zoomIn",
          "zoomOut",
          "resetScale",
          "pan"
        )
      )
    }
  
  # Generation plot
  output$generation_plot <- renderPlotly({
    req(gen_data())
    create_plot(gen_data(), "Generation", metric_labels[input$metric_select])
  })
  
  # Capacity plot
  output$capacity_plot <- renderPlotly({
    req(cap_data())
    create_plot(cap_data(), "Capacity", metric_labels[input$metric_select])
  })
}

shinyApp(ui, server)