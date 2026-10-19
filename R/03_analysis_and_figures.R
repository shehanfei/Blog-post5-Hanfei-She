# Maps, histogram, and spatial-autocorrelation statistics
library(here); library(sf); library(dplyr); library(ggplot2); library(spdep); library(scales)
source(here("R", "config.R"))
set.seed(42)

gdf   <- readRDS(file.path(PROCESSED, "tracts_income.rds"))
valid <- gdf |> filter(!is.na(median_income))

# ---- Figure 1: choropleth, income quintiles ----
valid <- valid |> mutate(
  quintile = cut(median_income,
                 breaks = quantile(median_income, 0:5 / 5),
                 include.lowest = TRUE, dig.lab = 6) |> factor())
p1 <- ggplot() +
  geom_sf(data = gdf, fill = "grey85", color = NA) +                 # no-data tracts
  geom_sf(data = valid, aes(fill = quintile), color = "white", linewidth = 0.05) +
  scale_fill_viridis_d(name = "Median HH income ($)") +
  labs(title = "Median Household Income by Census Tract",
       subtitle = sprintf("%s, ACS %d-%d", AREA_NAME, ACS_YEAR - 4, ACS_YEAR),
       caption = "Source: U.S. Census Bureau ACS 5-year (B19013), TIGER/Line. Grey = no data.") +
  theme_void() + theme(legend.position = "bottom", legend.title.position = "top")
ggsave(file.path(FIGS, "fig1_income_map.png"), p1, width = 8, height = 9, dpi = 200, bg = "white")

# ---- Global and local Moran's I (Queen contiguity, row-standardized) ----
nb <- poly2nb(valid, queen = TRUE)
lw <- nb2listw(nb, style = "W", zero.policy = TRUE)
y  <- log(valid$median_income)
mi <- moran.mc(y, lw, nsim = 999, zero.policy = TRUE)
message(sprintf("Moran's I = %.3f, pseudo p = %.4f", mi$statistic, mi$p.value))

lisa  <- localmoran_perm(y, lw, nsim = 999, zero.policy = TRUE)
p_col <- grep("^Pr\\(z.*Sim", colnames(lisa))[1]
z   <- as.numeric(scale(y)); lagz <- lag.listw(lw, z, zero.policy = TRUE)
valid$cluster <- case_when(
  lisa[, p_col] >= 0.05 ~ "Not significant",
  z > 0 & lagz > 0 ~ "High-High",
  z < 0 & lagz < 0 ~ "Low-Low",
  z < 0 & lagz > 0 ~ "Low-High",
  TRUE             ~ "High-Low")
cols <- c("Not significant" = "#e0e0e0", "High-High" = "#b2182b", "Low-Low" = "#2166ac",
          "Low-High" = "#92c5de", "High-Low" = "#f4a582")
p2 <- ggplot(valid) +
  geom_sf(aes(fill = cluster), color = "white", linewidth = 0.05) +
  scale_fill_manual(values = cols, name = "Local Moran's I (p<0.05)") +
  labs(title = sprintf("Income Clusters (LISA) - %s", AREA_NAME),
       subtitle = sprintf("Global Moran's I = %.2f", mi$statistic)) +
  theme_void() + theme(legend.position = "bottom")
ggsave(file.path(FIGS, "fig2_lisa_clusters.png"), p2, width = 8, height = 9, dpi = 200, bg = "white")

# ---- Figure 3: distribution of tract incomes ----
p3 <- ggplot(st_drop_geometry(valid), aes(median_income / 1000)) +
  geom_histogram(bins = 40, fill = "steelblue", color = "white") +
  geom_vline(xintercept = median(valid$median_income) / 1000, linetype = "dashed") +
  labs(x = "Median household income ($ thousands)", y = "Number of tracts",
       title = "Distribution of Tract-Level Median Income") +
  theme_minimal()
ggsave(file.path(FIGS, "fig3_income_hist.png"), p3, width = 7, height = 4, dpi = 200, bg = "white")

# ---- Tables ----
inc <- valid$median_income
summary_tbl <- data.frame(
  statistic = c("Tracts with data", "Median of tract medians ($)", "Min ($)", "Max ($)",
                "90th/10th percentile ratio", "Moran's I", "Moran pseudo p-value"),
  value = round(c(length(inc), median(inc), min(inc), max(inc),
                  unname(quantile(inc, .9) / quantile(inc, .1)),
                  unname(mi$statistic), mi$p.value), 3))
write.csv(summary_tbl, file.path(TABLES, "summary_stats.csv"), row.names = FALSE)
cl <- as.data.frame(table(cluster = valid$cluster), responseName = "tracts")
write.csv(cl, file.path(TABLES, "cluster_counts.csv"), row.names = FALSE)
print(summary_tbl); print(cl)
