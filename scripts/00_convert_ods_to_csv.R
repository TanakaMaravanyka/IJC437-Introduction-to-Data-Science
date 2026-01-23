# ==============================================================================
# INTRODUCTION TO DATA SCIENCE
# UK RAIL FARES ANALYSIS - COMPLETE WORKFLOW
# ==============================================================================
# Combined Script: All steps from data conversion to final visualization
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

