# ==============================================================================
# UK RAIL FARES ANALYSIS - EXPLORATORY DATA ANALYSIS
# ==============================================================================
# Script 2: Explore the data and create basic visualizations
# Date: December 2025
# ==============================================================================

# Load tidyverse
library(tidyverse)

# Set working directory
setwd("c:/Tanaka Maravanyika/IJC437-Introduction-to-Data-Science")

# ==============================================================================
# STEP 1: LOAD THE CLEANED DATA
# ==============================================================================

rail_data <- read_csv("data/rail_fares_long.csv")

# Quick look
head(rail_data)
glimpse(rail_data)

# ==============================================================================
# STEP 2: SUMMARY STATISTICS BY TICKET TYPE
# ==============================================================================

ticket_summary <- rail_data %>%
  group_by(`Ticket type`) %>%
  summarise(
    Count = n(),
    Average = mean(Fare_Index, na.rm = TRUE),
    Median = median(Fare_Index, na.rm = TRUE),
    SD = sd(Fare_Index, na.rm = TRUE),
    Q1 = quantile(Fare_Index, 0.25, na.rm = TRUE),
    Q3 = quantile(Fare_Index, 0.75, na.rm = TRUE),
    Minimum = min(Fare_Index, na.rm = TRUE),
    Maximum = max(Fare_Index, na.rm = TRUE)
  ) %>%
  arrange(desc(Average)) %>%
  # Round for professional presentation
  mutate(across(where(is.numeric), \(x) round(x, 2)))

ticket_summary

# ==============================================================================
# STEP 3: SUMMARY STATISTICS BY SECTOR
# ==============================================================================

sector_summary <- rail_data %>%
  group_by(Sector) %>%
  summarise(
    Count = n(),
    Average = mean(Fare_Index, na.rm = TRUE),
    Median = median(Fare_Index, na.rm = TRUE),
    SD = sd(Fare_Index, na.rm = TRUE),
    Q1 = quantile(Fare_Index, 0.25, na.rm = TRUE),
    Q3 = quantile(Fare_Index, 0.75, na.rm = TRUE),
    Minimum = min(Fare_Index, na.rm = TRUE),
    Maximum = max(Fare_Index, na.rm = TRUE)
  ) %>%
  arrange(desc(Average)) %>%
  # Round for professional presentation
  mutate(across(where(is.numeric), \(x) round(x, 2)))

sector_summary

# ==============================================================================
# STEP 4: AVERAGE FARE BY YEAR
# ==============================================================================

yearly_average <- rail_data %>%
  group_by(Year) %>%
  summarise(Average_Fare = mean(Fare_Index, na.rm = TRUE)) %>%
  # Round for professional presentation
  mutate(Average_Fare = round(Average_Fare, 2))

yearly_average

# ==============================================================================
# VISUALIZATION 1: OVERALL TREND LINE
# ==============================================================================

ggplot(yearly_average, aes(x = Year, y = Average_Fare)) +
  geom_line(color = "blue", size = 1.2) +
  geom_point(color = "blue", size = 2) +
  labs(
    title = "Average Rail Fare Index (2004-2025)",
    x = "Year",
    y = "Fare Index (2004 = 100)"
  ) +
  theme_minimal()

ggsave("visualizations/01_overall_trend.png", width = 10, height = 6)

# ==============================================================================
# VISUALIZATION 2: TRENDS BY TICKET TYPE
# ==============================================================================

ticket_yearly <- rail_data %>%
  group_by(Year, `Ticket type`) %>%
  summarise(Average_Fare = mean(Fare_Index, na.rm = TRUE), .groups = "drop")

ggplot(ticket_yearly, aes(x = Year, y = Average_Fare, color = `Ticket type`)) +
  geom_line(size = 1) +
  geom_point(size = 1.5) +
  labs(
    title = "Rail Fare Trends by Ticket Type (2004-2025)",
    x = "Year",
    y = "Fare Index (2004 = 100)",
    color = "Ticket Type"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("visualizations/02_trends_by_ticket_type.png", width = 12, height = 7)

# ==============================================================================
# VISUALIZATION 3: TRENDS BY SECTOR
# ==============================================================================

sector_yearly <- rail_data %>%
  group_by(Year, Sector) %>%
  summarise(Average_Fare = mean(Fare_Index, na.rm = TRUE), .groups = "drop")

ggplot(sector_yearly, aes(x = Year, y = Average_Fare, color = Sector)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  labs(
    title = "Rail Fare Trends by Sector (2004-2025)",
    x = "Year",
    y = "Fare Index (2004 = 100)",
    color = "Sector"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("visualizations/03_trends_by_sector.png", width = 12, height = 7)

# ==============================================================================
# STEP 5: KEY FINDINGS
# ==============================================================================

# Highest fare
highest <- rail_data %>%
  filter(!is.na(Fare_Index)) %>%
  arrange(desc(Fare_Index)) %>%
  slice(1)

highest

# Lowest fare
lowest <- rail_data %>%
  filter(!is.na(Fare_Index)) %>%
  arrange(Fare_Index) %>%
  slice(1)

lowest

# Overall change 2004 to 2025
fare_2004 <- yearly_average %>% filter(Year == 2004) %>% pull(Average_Fare)
fare_2025 <- yearly_average %>% filter(Year == 2025) %>% pull(Average_Fare)
increase <- round(fare_2025 - fare_2004, 2)

increase

# ==============================================================================
# END OF SCRIPT 2
# ==============================================================================


