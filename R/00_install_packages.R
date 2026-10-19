# Run once: installs the packages needed for this project
pkgs <- c("sf", "dplyr", "ggplot2", "jsonlite", "spdep", "here", "scales")
to_install <- setdiff(pkgs, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install)
