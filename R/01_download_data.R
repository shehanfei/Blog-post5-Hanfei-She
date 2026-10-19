# Download census-tract boundaries (TIGER/Line) and ACS median household income
library(here); library(jsonlite)
source(here("R", "config.R"))

# 1. Tract boundaries (state-level zip, filtered to the county later)
shp_url  <- sprintf("https://www2.census.gov/geo/tiger/TIGER%d/TRACT/tl_%d_%s_tract.zip",
                    TIGER_YEAR, TIGER_YEAR, STATE_FIPS)
shp_zip  <- file.path(RAW, basename(shp_url))
if (!file.exists(shp_zip)) {
  message("Downloading ", shp_url)
  download.file(shp_url, shp_zip, mode = "wb")
}
unzip(shp_zip, exdir = file.path(RAW, "tracts"))

# 2. ACS 5-year: B19013_001E = median household income, B01003_001E = total population
api_url <- sprintf(
  "https://api.census.gov/data/%d/acs/acs5?get=NAME,B19013_001E,B01003_001E&for=tract:*&in=state:%s%%20county:%s",
  ACS_YEAR, STATE_FIPS, COUNTY_FIPS)
message("Downloading ACS data")
m  <- fromJSON(api_url)
df <- as.data.frame(m[-1, , drop = FALSE], stringsAsFactors = FALSE)
names(df) <- m[1, ]
write.csv(df, file.path(RAW, sprintf("acs_income_%s%s.csv", STATE_FIPS, COUNTY_FIPS)), row.names = FALSE)
message("Saved ", nrow(df), " tracts")
