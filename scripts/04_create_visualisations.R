# ==============================================================================
# UK RAIL FARES ANALYSIS - CREATE VISUALIZATIONS
# ==============================================================================
# Script 4: Create charts for the report
# Student: [Your Name]
# Date: December 2025
# ==============================================================================

# Load tidyverse
library(tidyverse)

# Set working directory
setwd("c:/Tanaka Maravanyika/IJC437-Introduction-to-Data-Science")

# ==============================================================================
# STEP 1: LOAD THE DATA
# ==============================================================================

rail_data <- read_csv("data/analysis_with_calculations.csv")
rpi_comparison <- read_csv("data/rpi_comparison.csv")

# ==============================================================================
# VISUALIZATION 1: FARE TRENDS BY TICKET TYPE
# ==============================================================================

ticket_trends <- rail_data %>%
  group_by(Year, `Ticket type`) %>%
  summarise(Avg_Fare = mean(Fare_Index, na.rm = TRUE), .groups = "drop")

ggplot(ticket_trends, aes(x = Year, y = Avg_Fare, color = `Ticket type`)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "gray") +
  labs(
    title = "UK Rail Fare Trends by Ticket Type (2004-2025)",
    subtitle = "Index: 2004 = 100",
    x = "Year",
    y = "Fare Index",
    color = "Ticket Type"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("visualizations/chart1_ticket_trends.png", width = 12, height = 7, dpi = 300)

# ==============================================================================
# VISUALIZATION 2: AVERAGE INFLATION BY SECTOR
# ==============================================================================

sector_inflation <- rail_data %>%
  filter(!is.na(YoY_Change)) %>%
  group_by(Sector) %>%
  summarise(Avg_Inflation = mean(YoY_Change)) %>%
  arrange(desc(Avg_Inflation))

ggplot(sector_inflation, aes(x = reorder(Sector, Avg_Inflation), y = Avg_Inflation, fill = Sector)) +
  geom_col() +
  geom_text(aes(label = paste0(round(Avg_Inflation, 2), "%")), 
            vjust = -0.5, size = 4) +
  labs(
    title = "Average Annual Inflation Rate by Sector (2004-2025)",
    x = "Sector",
    y = "Average Annual Inflation (%)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("visualizations/chart2_sector_inflation.png", width = 10, height = 6, dpi = 300)

# ==============================================================================
# VISUALIZATION 3: SECTOR COMPARISON (FACETED)
# ==============================================================================

sector_trends <- rail_data %>%
  group_by(Year, Sector) %>%
  summarise(Avg_Fare = mean(Fare_Index, na.rm = TRUE), .groups = "drop")

ggplot(sector_trends, aes(x = Year, y = Avg_Fare)) +
  geom_line(color = "blue", size = 1.2) +
  geom_point(color = "blue", size = 2) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "gray") +
  facet_wrap(~ Sector, ncol = 1) +
  labs(
    title = "Rail Fare Trends by Sector (2004-2025)",
    subtitle = "Separate panels for each sector",
    x = "Year",
    y = "Fare Index (2004 = 100)"
  ) +
  theme_minimal()

ggsave("visualizations/chart3_sector_faceted.png", width = 10, height = 10, dpi = 300)

# ==============================================================================
# VISUALIZATION 4: RAIL FARES VS RPI
# ==============================================================================

rpi_plot_data <- rpi_comparison %>%
  pivot_longer(
    cols = c(Avg_Fare_Index, RPI_Index),
    names_to = "Index_Type",
    values_to = "Index_Value"
  ) %>%
  mutate(Index_Type = ifelse(Index_Type == "Avg_Fare_Index", 
                              "Rail Fares", 
                              "RPI (General Inflation)"))

ggplot(rpi_plot_data, aes(x = Year, y = Index_Value, color = Index_Type)) +
  geom_line(size = 1.3) +
  geom_point(size = 2.5) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "gray") +
  labs(
    title = "Rail Fares vs General Inflation (RPI) - 2004 to 2025",
    subtitle = "Comparing rail fare increases with Retail Prices Index",
    x = "Year",
    y = "Index (2004 = 100)",
    color = "Index Type"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("visualizations/chart4_fares_vs_rpi.png", width = 12, height = 7, dpi = 300)

# ==============================================================================
# VISUALIZATION 5: BOX PLOT - DISTRIBUTION BY TICKET TYPE
# ==============================================================================

ggplot(rail_data %>% filter(!is.na(Fare_Index)), 
       aes(x = reorder(`Ticket type`, Fare_Index, FUN = median), 
           y = Fare_Index, 
           fill = `Ticket type`)) +
  geom_boxplot() +
  labs(
    title = "Distribution of Fare Indices by Ticket Type (2004-2025)",
    subtitle = "Shows spread and outliers across all years",
    x = "Ticket Type",
    y = "Fare Index (2004 = 100)"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave("visualizations/chart5_boxplot_distribution.png", width = 10, height = 6, dpi = 300)

# ==============================================================================
# VISUALIZATION 6: CUMULATIVE INFLATION BY TICKET TYPE
# ==============================================================================

inflation_2025 <- rail_data %>%
  filter(Year == 2025, !is.na(Cumulative_Inflation)) %>%
  group_by(`Ticket type`) %>%
  summarise(Avg_Inflation = mean(Cumulative_Inflation)) %>%
  arrange(desc(Avg_Inflation))

ggplot(inflation_2025, aes(x = reorder(`Ticket type`, Avg_Inflation), 
                            y = Avg_Inflation, 
                            fill = `Ticket type`)) +
  geom_col() +
  geom_text(aes(label = paste0(round(Avg_Inflation, 1), "%")), 
            hjust = -0.2, size = 4) +
  coord_flip() +
  labs(
    title = "Total Fare Increase by Ticket Type (2004-2025)",
    subtitle = "Cumulative inflation over 21 years",
    x = "Ticket Type",
    y = "Cumulative Inflation (%)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("visualizations/chart6_cumulative_inflation.png", width = 10, height = 6, dpi = 300)

# ==============================================================================
# END OF SCRIPT 4
# ==============================================================================
