# Study-area settings. Change these to analyze a different county.
library(here)

AREA_NAME   <- "Cook County, IL"   # default: Chicago area
STATE_FIPS  <- "17"
COUNTY_FIPS <- "031"               # FIPS codes: https://www.census.gov/library/reference/code-lists/ansi.html
ACS_YEAR    <- 2022                # ACS 5-year estimates (2018-2022)
TIGER_YEAR  <- 2022
CRS_PLOT    <- 3857

RAW <- here("data", "raw"); PROCESSED <- here("data", "processed")
FIGS <- here("results", "figures"); TABLES <- here("results", "tables")
for (d in c(RAW, PROCESSED, FIGS, TABLES)) dir.create(d, showWarnings = FALSE, recursive = TRUE)
