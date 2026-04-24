## Overview
The HHI explainer Balancing Authority Tool is an interactive component of the overall [Power Sector Competitiveness Dashboard](https://nicholasinstitute.duke.edu/project/power-sector-competitiveness-dashboard).

Built using R Shiny, the [HHI explainer Balancing Authority Tool](https://nicholasinstitute.duke.edu/project/power-sector-competitiveness-dashboard/simulator) enables users to explore trends in Concentration and Generation HHI across [Balancing Authorities]([https://nicholasinstitute.duke.edu/project/power-sector-competitiveness-dashboard/simulator](https://www.energy.gov/sites/default/files/2023-08/Balancing%20Authority%20Backgrounder_2022-Formatted_041723_508.pdf)) and time (1980-2024).

## Functionality
1. Scenario Design: Users can modify State policies, regulatory structures, and market arrangements that influence power sector competitiveness. Outputs are displayed through dynamically updated visualizations. 
2. Indicator Adjustment: The simulator maps policy and structural condition changes to adjustments in the indicators used to construct competitiveness scores. These indicators are normalized (0-1) and aggregated using a consistent methodology across states.
3. Score Recalculation: Once inputs are modified, the simulator recomputes:
   * Individual indicator values
   * Composite competitiveness scores
   * Relative state rankings
4. Weights: Users can optionally adjust the relative importance of the three core competitiveness dimensions:
    * Consumer
    * Structure
    * Regional Market
      
   By default, each category is equally weighted (33% each). All weights are applied dynamically and propagate through the composite scoring framework, updating overall competitiveness scores and state rankings in real time.

## This repo contains the following files:

`ba_shiny_app.R`
Code for running and formatting the Shiny app in the Power Sector Competitiveness Dashboard.

`ba_data.rds`
Processed HHI data used for the dashboard.

`ba_hhi_panel.csv`
Raw HHI data inputs before formatting or processing.

