# Download census-tract boundaries (TIGER/Line) and ACS median household income
library(here); library(jsonlite); library(utils)
source(here("R", "config.R"))

# Optional: free API key from https://api.census.gov/data/key_signup.html
# Set it once with: Sys.setenv(CENSUS_API_KEY = "your_key")  (or in ~/.Renviron)
api_key <- Sys.getenv("CENSUS_API_KEY", unset = "")

# 1. Tract boundaries (state-level zip, filtered to the county later)
shp_url <- sprintf("https://www2.census.gov/geo/tiger/TIGER%d/TRACT/tl_%d_%s_tract.zip",
                   TIGER_YEAR, TIGER_YEAR, STATE_FIPS)
shp_zip <- file.path(RAW, basename(shp_url))
if (!file.exists(shp_zip)) {
  message("Downloading ", shp_url)
  options(timeout = 300)
  download.file(shp_url, shp_zip, mode = "wb")
}
unzip(shp_zip, exdir = file.path(RAW, "tracts"))

# 2. ACS 5-year: B19013_001E = median household income, B01003_001E = total population
api_url <- sprintf(
  "https://api.census.gov/data/%d/acs/acs5?get=NAME,B19013_001E,B01003_001E&for=tract:*&in=state:%s&in=county:%s",
  ACS_YEAR, STATE_FIPS, COUNTY_FIPS)
if (nzchar(api_key)) api_url <- paste0(api_url, "&key=", api_key)

message("Downloading ACS data")
tmp <- tempfile(fileext = ".json")
download.file(api_url, tmp, mode = "wb", quiet = TRUE)
txt <- paste(readLines(tmp, warn = FALSE), collapse = "\n")

# The API returns an HTML/text error page (not JSON) when a request is rejected
if (!startsWith(trimws(txt), "[")) {
  stop("Census API did not return JSON. First 300 characters of the response:\n",
       substr(txt, 1, 300), "\nURL: ", api_url, call. = FALSE)
}
m  <- fromJSON(txt)
df <- as.data.frame(m[-1, , drop = FALSE], stringsAsFactors = FALSE)
names(df) <- m[1, ]
write.csv(df, file.path(RAW, sprintf("acs_income_%s%s.csv", STATE_FIPS, COUNTY_FIPS)),
          row.names = FALSE)
message("Saved ", nrow(df), " tracts")
