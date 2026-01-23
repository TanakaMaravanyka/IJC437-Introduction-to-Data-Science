# ==============================================================================
# UK RAIL FARES ANALYSIS - TIME-SERIES ANALYSIS
# ==============================================================================
# Script 3: Calculate inflation rates and answer research questions
# Date: December 2025
# ==============================================================================

# Load tidyverse
library(tidyverse)

# Set working directory
setwd("c:/Tanaka Maravanyika/IJC437-Introduction-to-Data-Science")

# ==============================================================================
# STEP 1: LOAD THE DATA
# ==============================================================================

rail_data <- read_csv("data/rail_fares_long.csv")
rpi_data <- read_csv("data/rpi_data.csv")

# ==============================================================================
# STEP 2: CALCULATE YEAR-OVER-YEAR CHANGES
# ==============================================================================

# Calculate Year-over-Year Change and Cumulative Inflation
rail_data <- rail_data %>%
  arrange(Sector, `Ticket type`, Year) %>%
  group_by(Sector, `Ticket type`) %>%
  mutate(
    YoY_Change = (Fare_Index - lag(Fare_Index)) / lag(Fare_Index) * 100,
    Cumulative_Inflation = Fare_Index - 100
  ) %>%
  ungroup()

# 2025 inflation by ticket type
inflation_2025 <- rail_data %>%
  filter(Year == 2025, !is.na(Cumulative_Inflation)) %>%
  group_by(`Ticket type`) %>%
  summarise(Avg_Inflation = mean(Cumulative_Inflation)) %>%
  arrange(desc(Avg_Inflation))

inflation_2025

# ==============================================================================
# STEP 4: ANSWER RESEARCH QUESTION 2
# ==============================================================================

# Highest inflation ticket type
highest_inflation <- inflation_2025 %>% slice(1)
highest_inflation

# ==============================================================================
# STEP 5: AVERAGE ANNUAL INFLATION
# ==============================================================================

# By ticket type
avg_inflation_ticket <- rail_data %>%
  filter(!is.na(YoY_Change)) %>%
  group_by(`Ticket type`) %>%
  summarise(
    Avg_Annual_Inflation = mean(YoY_Change),
    Max_Annual_Inflation = max(YoY_Change),
    Min_Annual_Inflation = min(YoY_Change)
  ) %>%
  arrange(desc(Avg_Annual_Inflation))

avg_inflation_ticket

# By sector
avg_inflation_sector <- rail_data %>%
  filter(!is.na(YoY_Change)) %>%
  group_by(Sector) %>%
  summarise(
    Avg_Annual_Inflation = mean(YoY_Change),
    Max_Annual_Inflation = max(YoY_Change),
    Min_Annual_Inflation = min(YoY_Change)
  ) %>%
  arrange(desc(Avg_Annual_Inflation))

avg_inflation_sector

# ==============================================================================
# STEP 6: ANSWER RESEARCH QUESTION 3 - SECTOR COMPARISON
# ==============================================================================

sector_comparison <- rail_data %>%
  filter(Year %in% c(2004, 2025)) %>%
  group_by(Sector, Year) %>%
  summarise(Avg_Fare = mean(Fare_Index, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = Year, values_from = Avg_Fare, names_prefix = "Year_") %>%
  mutate(Change_2004_2025 = Year_2025 - Year_2004) %>%
  arrange(desc(Change_2004_2025))

sector_comparison

# ==============================================================================
# STEP 7: COMPARE WITH RPI
# ==============================================================================

# Prepare RPI data
rpi_long <- rpi_data %>%
  pivot_longer(
    cols = `2004`:`2025`,
    names_to = "Year",
    values_to = "RPI_Index"
  ) %>%
  mutate(Year = as.numeric(Year)) %>%
  select(Year, RPI_Index)

# Average rail fare by year
avg_fare_yearly <- rail_data %>%
  group_by(Year) %>%
  summarise(Avg_Fare_Index = mean(Fare_Index, na.rm = TRUE))

# Combine
comparison <- avg_fare_yearly %>%
  left_join(rpi_long, by = "Year") %>%
  mutate(Difference = Avg_Fare_Index - RPI_Index)

comparison

# 2025 comparison
comparison_2025 <- comparison %>% filter(Year == 2025)
comparison_2025

# ==============================================================================
# STEP 8: PERIODS OF SIGNIFICANT CHANGE
# ==============================================================================

yearly_changes <- rail_data %>%
  filter(!is.na(YoY_Change)) %>%
  group_by(Year) %>%
  summarise(Avg_Change = mean(YoY_Change))

yearly_changes

# Biggest increase year
biggest_increase <- yearly_changes %>%
  arrange(desc(Avg_Change)) %>%
  slice(1)

biggest_increase

# ==============================================================================
# STEP 9: SAVE RESULTS
# ==============================================================================

write_csv(rail_data, "data/analysis_with_calculations.csv")
write_csv(sector_comparison, "data/sector_comparison.csv")
write_csv(comparison, "data/rpi_comparison.csv")

# ==============================================================================
# KEY FINDINGS SUMMARY
# ==============================================================================

# 1. Highest inflation ticket type
highest_inflation

# 2. Sector with highest inflation
avg_inflation_sector %>% slice(1)

# 3. Rail fares vs RPI difference
comparison_2025$Difference

# ==============================================================================
# END OF SCRIPT 3

# ============================================
