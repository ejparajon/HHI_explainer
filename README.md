## Overview
The Balancing Authority Time Series Analysis Tool is an interactive component of the overall [Power Sector Competitiveness Dashboard](https://nicholasinstitute.duke.edu/project/power-sector-competitiveness-dashboard). Built using R Shiny, this tool enables users to explore trends in market concentration across [Balancing Authorities](https://www.energy.gov/sites/default/files/2023-08/Balancing%20Authority%20Backgrounder_2022-Formatted_041723_508.pdf) over time (1990-2024).

The tool displays both Generation HHI and Capacity HHI metrics for the sixteen largest balancing authorities in terms of 2024 total retail sales, allowing users to examine how market concentration has evolved differently across generation activity versus installed capacity.

## Functionality

1. **Balancing Authority Selection**: Users can select any combination of the 16 largest balancing authorities, organized into two groups:
   * RTO/ISO Markets (CAISO, ERCOT, ISO-NE, MISO, NYISO, PJM, SPP)
   * Non-RTO/ISO Markets (BPA, DUKE-CP, DUKE-FL, FPL, NEVP, PACE, PSCO, SOCO, TVA)

2. **Metric Options**: Users can view concentration through four different specifications:
   * **LOESS Smoothed**: HHI values smoothed using local polynomial regression to reduce year-to-year noise (excludes 1998-2000 due to survey instrument changes)
   * **Raw HHI**: Herfindahl-Hirschman Index calculated directly from annual data without smoothing
   * **Normalized to 1990**: HHI values indexed to 1990 baseline to show relative change over time
   * **Effective # of Firms**: Calculated as 1/HHI, representing the number of equal-sized firms that would produce equivalent concentration

3. **Synchronized Visualization**: The tool displays two vertically aligned time series plots:
   * Generation HHI (top panel): Shows concentration in actual electricity generation
   * Capacity HHI (bottom panel): Shows concentration in installed generation capacity
   
   Both plots respond to the same BA and metric selections, enabling direct comparison of how concentration patterns differ between capacity ownership and generation activity.

4. **Interactive Features**: Plotly-based visualizations include zoom, pan, hover tooltips with exact values, and downloadable PNG exports.

## Repository Contents

**`ba_shiny_app.R`**  
Complete R Shiny application code for the Balancing Authority Time Series Analysis Tool.

**`ba_data.rds`**  
Processed panel dataset containing HHI metrics (generation and capacity) for all 16 balancing authorities across all years and metric specifications.

**`ba_hhi_panel.csv`**  
Raw HHI data before processing and formatting.

## Data Sources
EIA-860 (generator-level capacity data) and EIA-861 (utility-level generation and sales data)

