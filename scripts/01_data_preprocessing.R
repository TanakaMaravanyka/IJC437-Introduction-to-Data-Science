# ==============================================================================
# UK RAIL FARES ANALYSIS - DATA PREPROCESSING
# ==============================================================================
# Script 1: Load and clean the rail fares data
# Date: December 2025
# ==============================================================================

# Load the tidyverse package
library(tidyverse)

# Set working directory
setwd("c:/Tanaka Maravanyika/IJC437-Introduction-to-Data-Science")

# ==============================================================================
# STEP 1: LOAD THE DATA
# ==============================================================================

# Read the CSV file (it is now clean, so we don't need to skip rows)
rail_data <- read_csv("data/7182_Change_by_ticket_type.csv")

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
write_csv(rail_long, "data/rail_fares_long.csv")

# Save wide format
write_csv(rail_clean, "data/rail_fares_clean.csv")

# Save RPI data
write_csv(rpi_data, "data/rpi_data.csv")

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

