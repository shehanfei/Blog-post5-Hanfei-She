# Merge ACS income with tract geometry and clean missing-value codes
library(here); library(sf); library(dplyr)
source(here("R", "config.R"))

tracts <- st_read(file.path(RAW, "tracts", sprintf("tl_%d_%s_tract.shp", TIGER_YEAR, STATE_FIPS)),
                  quiet = TRUE) |>
  filter(COUNTYFP == COUNTY_FIPS) |>
  select(GEOID)

acs <- read.csv(file.path(RAW, sprintf("acs_income_%s%s.csv", STATE_FIPS, COUNTY_FIPS)),
                colClasses = "character") |>
  mutate(GEOID = paste0(state, county, tract),
         median_income = suppressWarnings(as.numeric(B19013_001E)),
         population    = suppressWarnings(as.numeric(B01003_001E)),
         # Census uses large negative sentinel values (e.g., -666666666) for suppressed data
         median_income = ifelse(median_income < 0, NA, median_income)) |>
  select(GEOID, median_income, population)

gdf <- tracts |> left_join(acs, by = "GEOID") |> st_transform(CRS_PLOT)
message(nrow(gdf), " tracts; ", sum(is.na(gdf$median_income)), " without income data")
saveRDS(gdf, file.path(PROCESSED, "tracts_income.rds"))
