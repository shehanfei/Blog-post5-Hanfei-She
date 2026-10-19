# Run the full pipeline from the project root: Rscript R/run_all.R
library(here)
for (s in c("01_download_data.R", "02_clean_merge.R", "03_analysis_and_figures.R")) {
  message("\n=== ", s, " ===")
  source(here("R", s), echo = FALSE)
}
