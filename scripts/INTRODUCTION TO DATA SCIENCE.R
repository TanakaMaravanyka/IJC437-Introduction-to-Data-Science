# ==============================================================================
# INTRODUCTION TO DATA SCIENCE
# UK RAIL FARES ANALYSIS - COMPLETE WORKFLOW
# ==============================================================================
# Combined Script: All steps from data conversion to final visualizations
# Date: December 2025
# ==============================================================================

# ==============================================================================
# SCRIPT 0: ODS TO CSV CONVERSION
# ==============================================================================
# Convert the raw ODS data to CSV format
# ==============================================================================

# Set options to display full decimal precision in RStudio
options(digits = 14)  # Show up to 22 significant digits
options(pillar.sigfig = 14)  # For tibble display

# 1. Install and load readODS package if needed
if (!require("readODS")) install.packages("readODS")
library(readODS)

# 2. Define paths
ods_path <- "c:/Tanaka Maravanyika/IJC437-Introduction-to-Data-Science/data/table-7182-average-change-in-fares-by-ticket-type.ods"
csv_path <- "c:/Tanaka Maravanyika/IJC437-Introduction-to-Data-Science/data/7182_Change_by_ticket_type.csv"

# 3. Read the ODS file
# We skip the first 4 rows to start exactly at the "Sector" header row
# Note: This will preserve the "hidden" full decimal precision
rail_data <- read_ods(ods_path, 
                      sheet = "7182_Change_by_ticket_type",
                      skip = 4,
                      col_names = TRUE)

# 4. Clean headers (Remove newlines and extra spaces)
# This is necessary so Script 1 can find the column names correctly
colnames(rail_data) <- gsub("\n", " ", colnames(rail_data))
colnames(rail_data) <- gsub("\\s+", " ", colnames(rail_data))
colnames(rail_data) <- trimws(colnames(rail_data))

# 5. Save as CSV file
# By not rounding, we keep the full decimal precision for better results
if (!dir.exists("c:/Tanaka Maravanyika/IJC437-Introduction-to-Data-Science/data")) dir.create("c:/Tanaka Maravanyika/IJC437-Introduction-to-Data-Science/data")

# Save as CSV file (without row names)
write.csv(rail_data, csv_path, row.names = FALSE)

# ==============================================================================
# END OF SCRIPT 0
# ==============================================================================


# ==============================================================================
# SCRIPT 1: DATA PREPROCESSING
# ==============================================================================
# Load and clean the rail fares data
# ==============================================================================

# Load the tidyverse package
library(tidyverse)

# Set working directory
setwd("c:/Tanaka Maravanyika")

# ==============================================================================
# STEP 1: LOAD THE DATA
# ==============================================================================

# Read the CSV file (it is now clean, so we don't need to skip rows)
rail_data <- read_csv("IJC437-Introduction-to-Data-Science/data/7182_Change_by_ticket_type.csv")

# Look at the data
head(rail_data)

# ==============================================================================
# STEP 2: CLEAN COLUMN NAMES
# ==============================================================================

# Remove [note 1], [note 2] etc. from column names
colnames(rail_data) <- gsub("\\s*\\[note \\d+\\]", "", colnames(rail_data))

# ==============================================================================
# STEP 3: SELECT ONLY THE COLUMNS WE NEED
# ==============================================================================

# Select: Sector, Ticket type, and years 2004-2025
rail_clean <- rail_data %>%
  select(Sector, `Ticket type`, `2004`, `2005`, `2006`, `2007`, `2008`, `2009`, 
         `2010`, `2011`, `2012`, `2013`, `2014`, `2015`, `2016`, `2017`, `2018`, 
         `2019`, `2020`, `2021`, `2022`, `2023`, `2024`, `2025`)

# ==============================================================================
# STEP 4: REMOVE ROWS WE DON'T NEED
# ==============================================================================

# Remove "Revenue per journey" rows
rail_clean <- rail_clean %>%
  filter(!grepl("Revenue per journey", `Ticket type`))

# Save RPI data separately
rpi_data <- rail_clean %>%
  filter(grepl("Retail Prices Index", Sector))

# Remove RPI from main data
rail_clean <- rail_clean %>%
  filter(!grepl("Retail Prices Index", Sector))

# ==============================================================================
# STEP 5: CONVERT TO LONG FORMAT
# ==============================================================================

# First, convert all year columns to numeric (some are character due to [note] markers)
rail_clean <- rail_clean %>%
  mutate(across(`2004`:`2025`, as.numeric))

# Convert from wide to long format
rail_long <- rail_clean %>%
  pivot_longer(
    cols = `2004`:`2025`,
    names_to = "Year",
    values_to = "Fare_Index"
  )

# Convert Year to number
rail_long$Year <- as.numeric(rail_long$Year)

# Sort the data
rail_long <- rail_long %>%
  arrange(Sector, `Ticket type`, Year)

# Convert Fare_Index to numeric (this handles [x] and [z] by turning them into NA)
# This is essential for the summary and charts to work correctly!
rail_long$Fare_Index <- as.numeric(rail_long$Fare_Index)

# ==============================================================================
# STEP 6: SAVE THE CLEANED DATA
# ==============================================================================

# Save long format
write_csv(rail_long, "IJC437-Introduction-to-Data-Science/data/rail_fares_long.csv")

# Save wide format
write_csv(rail_clean, "IJC437-Introduction-to-Data-Science/data/rail_fares_clean.csv")

# Save RPI data
write_csv(rpi_data, "IJC437-Introduction-to-Data-Science/data/rpi_data.csv")

# ==============================================================================
# STEP 7: QUICK DATA SUMMARY
# ==============================================================================

# Show sectors
unique(rail_long$Sector)

# Show ticket types
unique(rail_long$`Ticket type`)

# Show year range
range(rail_long$Year)

# Basic statistics
summary(rail_long$Fare_Index)

# Check 2004 baseline (should all be 100)
rail_long %>% filter(Year == 2004) %>% pull(Fare_Index) %>% unique()

# ==============================================================================
# END OF SCRIPT 1
# ==============================================================================


# ==============================================================================
# SCRIPT 2: EXPLORATORY DATA ANALYSIS
# ==============================================================================
# Explore the data and create basic visualizations
# ==============================================================================

# Load tidyverse
library(tidyverse)

# Set working directory
setwd("c:/Tanaka Maravanyika")

# ==============================================================================
# STEP 1: LOAD THE CLEANED DATA
# ==============================================================================

rail_data <- read_csv("IJC437-Introduction-to-Data-Science/data/rail_fares_long.csv")

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



# ==============================================================================
# STEP 3: SUMMARY STATISTICS BY SECTOR
# ==============================================================================



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

ggsave("IJC437-Introduction-to-Data-Science/visualizations/01_overall_trend.png", width = 10, height = 6)

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

ggsave("IJC437-Introduction-to-Data-Science/visualizations/02_trends_by_ticket_type.png", width = 12, height = 7)

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

ggsave("IJC437-Introduction-to-Data-Science/visualizations/03_trends_by_sector.png", width = 12, height = 7)

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


# ==============================================================================
# SCRIPT 3: TIME-SERIES ANALYSIS
# ==============================================================================
# Calculate inflation rates and answer research questions
# ==============================================================================

# Load tidyverse
library(tidyverse)

# Set working directory
setwd("c:/Tanaka Maravanyika")

# ==============================================================================
# STEP 1: LOAD THE DATA
# ==============================================================================

rail_data <- read_csv("IJC437-Introduction-to-Data-Science/data/rail_fares_long.csv")
rpi_data <- read_csv("IJC437-Introduction-to-Data-Science/data/rpi_data.csv")

# ==============================================================================
# STEP 2: CALCULATE YEAR-OVER-YEAR CHANGES
# ==============================================================================

# Sort data
rail_data <- rail_data %>%
  arrange(Sector, `Ticket type`, Year)

# Create empty column
rail_data$YoY_Change <- NA

# Calculate percentage change from previous year
for (i in 2:nrow(rail_data)) {
  same_group <- (rail_data$Sector[i] == rail_data$Sector[i-1]) & 
                (rail_data$`Ticket type`[i] == rail_data$`Ticket type`[i-1])
  
  if (same_group & !is.na(rail_data$Fare_Index[i]) & !is.na(rail_data$Fare_Index[i-1])) {
    previous <- rail_data$Fare_Index[i-1]
    current <- rail_data$Fare_Index[i]
    rail_data$YoY_Change[i] <- ((current - previous) / previous) * 100
  }
}

# Sample of changes
rail_data %>%
  filter(!is.na(YoY_Change)) %>%
  select(Sector, `Ticket type`, Year, Fare_Index, YoY_Change) %>%
  head(10)

# ==============================================================================
# STEP 3: CALCULATE CUMULATIVE INFLATION
# ==============================================================================

rail_data$Cumulative_Inflation <- rail_data$Fare_Index - 100

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

write_csv(rail_data, "IJC437-Introduction-to-Data-Science/data/analysis_with_calculations.csv")
write_csv(sector_comparison, "IJC437-Introduction-to-Data-Science/data/sector_comparison.csv")
write_csv(comparison, "IJC437-Introduction-to-Data-Science/data/rpi_comparison.csv")

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
# ==============================================================================


# ==============================================================================
# SCRIPT 4: CREATE VISUALIZATIONS
# ==============================================================================
# Create charts for the report
# ==============================================================================

# Load tidyverse
library(tidyverse)

# Set working directory
setwd("c:/Tanaka Maravanyika")

# ==============================================================================
# STEP 1: LOAD THE DATA
# ==============================================================================

rail_data <- read_csv("IJC437-Introduction-to-Data-Science/data/analysis_with_calculations.csv")
rpi_comparison <- read_csv("IJC437-Introduction-to-Data-Science/data/rpi_comparison.csv")

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

ggsave("IJC437-Introduction-to-Data-Science/visualizations/chart1_ticket_trends.png", width = 12, height = 7, dpi = 300)

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

ggsave("IJC437-Introduction-to-Data-Science/visualizations/chart2_sector_inflation.png", width = 10, height = 6, dpi = 300)

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

ggsave("IJC437-Introduction-to-Data-Science/visualizations/chart3_sector_faceted.png", width = 10, height = 10, dpi = 300)

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

ggsave("IJC437-Introduction-to-Data-Science/visualizations/chart4_fares_vs_rpi.png", width = 12, height = 7, dpi = 300)

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

ggsave("IJC437-Introduction-to-Data-Science/visualizations/chart5_boxplot_distribution.png", width = 10, height = 6, dpi = 300)

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

ggsave("IJC437-Introduction-to-Data-Science/visualizations/chart6_cumulative_inflation.png", width = 10, height = 6, dpi = 300)

# ==============================================================================
# END OF SCRIPT 4
# ==============================================================================

# ==============================================================================
# END OF COMBINED SCRIPT - INTRODUCTION TO DATA SCIENCE
# ==============================================================================



