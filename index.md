# Two Cities in One County: Mapping Where Income Concentrates in Cook County, Illinois

## The question and why it matters

When economists talk about inequality, we usually reach for a single number: a Gini coefficient, or the ratio of the 90th to the 10th percentile of income. These numbers are useful, but they hide a question that matters just as much: *where* do rich and poor households live relative to each other? Two regions can have identical Gini coefficients, yet in one, high- and low-income families share streets, schools, and parks, while in the other they are sorted into entirely separate neighborhoods.

That distinction matters because neighborhoods are not neutral backdrops. Research by Chetty and Hendren (2018) shows that the neighborhood a child grows up in causally affects their adult earnings, and that these effects accumulate with each additional year of childhood exposure. If income is spatially segregated, then inequality in parents' incomes can turn into inequality in children's opportunities.

I study Cook County, Illinois, which contains Chicago and its inner suburbs, because it is large, diverse, and famously segregated by many accounts. My question is: **where are high- and low-income areas concentrated in Cook County, and is income clustered in space more than we would expect by chance?** Answering the second part requires a statistical test, not just eyeballing a map, so the analysis combines a descriptive map with a measure of spatial autocorrelation.

## Data and methods

**Data.** I use median household income (ACS table B19013) from the American Community Survey 5-year estimates for 2018-2022, downloaded from the U.S. Census Bureau API, and census tract boundaries from the Census Bureau's TIGER/Line files. A census tract holds about 4,000 people on average, so it is a reasonable stand-in for a "neighborhood." The analysis covers 1,316 tracts with valid income data. Water-only tracts (Lake Michigan) are excluded from the analysis.

**Methods.** The analysis has three steps, all implemented in R (`sf`, `ggplot2`, `spdep`) and reproducible from the scripts in this repository.

1. *Choropleth map.* I shade each tract by its income quintile, so each color holds about 20% of tracts. Quintiles make the map comparable across the county and avoid one extreme tract dominating the color scale.
2. *Global Moran's I.* This is, roughly speaking, the correlation between a tract's income and the average income of its neighbors (tracts that share a border). A value near 0 means incomes are scattered randomly across space; a value near 1 means similar incomes are strongly clustered. I compute it on log income, since income is right-skewed, and assess significance with 999 random permutations of the data.
3. *Local Moran's I (LISA).* The global number tells us *whether* there is clustering, but not *where*. LISA classifies each tract as part of a High-High cluster (a high-income tract surrounded by high-income tracts), Low-Low cluster, or a spatial outlier (High-Low or Low-High), keeping only tracts that are statistically significant at the 5% level.

## Result 1: Income is spread widely, and the map shows it is not spread randomly

Before looking at geography, it helps to know how much income actually varies across tracts. The typical tract has a median household income of about $74,300, but the range is enormous: from roughly $13,400 at the bottom to $250,001 at the top. The $250,001 figure is not a coincidence. The ACS top-codes income at that value, so the richest tracts are truncated, and the real top of the distribution is probably higher. The 90th percentile tract earns about 3.8 times the 10th percentile tract.

![Distribution of tract incomes](../results/figures/fig3_income_hist.png)

*Figure 1. Distribution of tract-level median household income. The dashed line marks the median tract. The pile-up at the far right is the ACS top-code.*

The histogram is right-skewed: most tracts sit between $40,000 and $100,000, with a long tail of affluent tracts. This tells us there is substantial inequality *between* neighborhoods, but it says nothing about where those neighborhoods are. The map does.

![Income map](../results/figures/fig1_income_map.png)

*Figure 2. Median household income by census tract, Cook County, ACS 2018-2022. Colors are quintiles: the bottom quintile earns below about $48,900 and the top quintile above about $112,700.*

Three things stand out. First, the lowest-income tracts (dark purple) form two large, contiguous blocks: one on the West Side of Chicago and a much larger one across the South Side, continuing into the southern suburbs. These are not scattered low-income tracts; they are whole regions. Second, the highest-income tracts (yellow) appear in three distinct places: the lakefront on the north side of the city, including the area around the downtown core, the affluent suburbs of the northern part of the county, and parts of the southwest and northwest edges. Third, the transition between the two is often sharp. In several places, a tract in the top quintile sits directly beside one in the bottom quintile, which suggests that boundaries such as highways, rail lines, and municipal limits may be doing real work.

A map like this is persuasive, but color choices can mislead, so I do not stop here.

## Result 2: Income is strongly clustered, far beyond chance

Global Moran's I for log income is **0.68** (permutation p-value of 0.001, the smallest value possible with 999 permutations). That is a strong positive spatial autocorrelation. To put it in everyday terms: knowing the income of a tract's neighbors explains a very large share of what its own income will be. If rich and poor tracts were randomly shuffled across the county, we would expect a value close to zero.

The local version tells us where this clustering lives.

![LISA clusters](../results/figures/fig2_lisa_clusters.png)

*Figure 3. Local Moran's I clusters (p < 0.05). Red = High-High, dark blue = Low-Low, pale colors = spatial outliers, grey = no significant local clustering.*

| Cluster type | Tracts | Share of 1,316 |
|---|---|---|
| High-High | 220 | 16.7% |
| Low-Low | 234 | 17.8% |
| High-Low (outlier) | 13 | 1.0% |
| Low-High (outlier) | 3 | 0.2% |
| Not significant | 846 | 64.3% |

Roughly a third of all tracts (454 of 1,316) belong to a significant High-High or Low-Low cluster, and these two types are almost exactly balanced, with 220 and 234 tracts. Spatial outliers are very rare: only 16 tracts, about 1%, look markedly different from their surroundings. In other words, a tract that is rich or poor *and* sits in a neighborhood that is the opposite is the exception, not the rule.

The geography of the clusters mirrors the quintile map but sharpens it. The High-High clusters are located in the north lakefront, the northern and northwestern suburbs, and smaller pockets in the west and southwest. The Low-Low clusters form two compact blocks, one on the West Side and one on the South Side that stretches south toward the county's southern edge. Notice also what is *not* colored: the large grey areas, including much of the area between the two groups, are tracts with mixed or middling incomes surrounded by similar tracts, where there is no statistically distinct local pattern.

The few outliers are informative too. Small High-Low tracts appear inside the South Side Low-Low zone, and a handful of Low-High tracts show up in the north. I did not investigate them individually, but outliers like these often reflect institutions (a university campus, an airport, a large park) or the early stages of neighborhood change. They would be natural candidates for follow-up research.

## What these patterns reveal

**Inequality here is a geographic fact, not just a statistical one.** The Moran's I of 0.68 means that the 3.8x gap between rich and poor tracts is not a gap between neighbors but between regions. A family on the South Side is not only poorer than a family on the north lakefront; they are likely surrounded by poorer neighbors, attend schools drawn from poorer areas, and face a different set of local employers, services, and amenities. This is exactly the setting where neighborhood effects on children can accumulate.

**The pattern does not look like the product of individual market choices alone.** Chicago's racial and economic geography has been shaped for a century by policy: restrictive covenants, discriminatory mortgage lending, highway and public housing siting, and school district boundaries (see Rothstein, 2017, and Sampson, 2012, for detailed accounts). I did not test any of these channels, and this analysis cannot prove them. But the sharpness of boundaries between clusters, and the persistence of the South and West Side low-income blocks, is consistent with a history of institutional sorting rather than a smooth gradient of preferences and prices.

**Concentration cuts both ways.** It is tempting to focus only on concentrated disadvantage, but the map shows concentrated advantage too: the High-High clusters are nearly as large as the Low-Low ones. Wealthy tracts being clustered means that high-income households also benefit from shared local resources, such as tax bases that fund schools, which helps preserve the gap. Policy that targets only the low-income side of the map misses half of the mechanism.

## Limitations

I want to be honest about what this analysis cannot do. First, the ACS is a survey, so each tract's median has a margin of error, and these margins are larger in small tracts; some of the "noise" in the map is sampling error. Second, median household income ignores wealth, which is far more unequal than income, and ignores differences in cost of living and household size. Third, the top-coding at $250,001 compresses differences among the richest tracts, so if anything I understate inequality at the top. Fourth, results depend on analytical choices: how I define "neighbors" (Queen contiguity), the use of log income, and the tract as the unit of analysis. Different boundaries could change the picture, a problem known as the modifiable areal unit problem. Finally, this is a descriptive snapshot. It cannot tell us about *causes* or about how these patterns have changed over time.

## Takeaway

The main finding is simple to state: in Cook County, income is strongly and significantly clustered in space. A global Moran's I of 0.68 means that where a household lives is closely tied to the income level of its surroundings, and the local analysis shows that this takes the form of two large, nearly equal-sized blocks. About 17% of tracts belong to a High-High cluster and about 18% to a Low-Low cluster, while almost no tracts are rich islands in a poor area or the reverse. The county does not have a smooth gradient from rich to poor; it has distinct regions with relatively sharp edges.

This matters for how we think about inequality. A statistic like the 90/10 ratio treats a county of mixed neighborhoods and a county of segregated ones as the same. The map shows that Cook County is much closer to the second. If neighborhoods causally affect children's outcomes, as the evidence from Chetty and Hendren suggests, then the spatial structure of income may amplify inequality across generations in a way that cross-sectional income numbers cannot capture.

For policy, this suggests that place matters in at least two ways. Place-based policies, such as investment in schools, transit, and local employment in the Low-Low clusters, can improve conditions where disadvantage is concentrated. At the same time, policies that open up High-High areas to a wider range of households, such as zoning reform that allows more housing types or housing vouchers that support moves to higher-opportunity neighborhoods, address the other side of the segregation. Neither approach is a complete answer, and this analysis cannot say which is more cost-effective. What it does show is that any serious answer should start from the geography.

Finally, the analysis suggests several next steps: repeating the analysis for other years to see whether the clusters are growing or shrinking, overlaying data on race, school quality, or transit access to study *why* the clusters have the shape they do, and using a spatial regression to test which neighborhood characteristics are associated with income beyond what their neighbors predict. Those questions are beyond the scope of this post, but the maps here suggest they are worth asking.

## Replication

All code, data download instructions, and figures are in this repository. See `README.md` for step-by-step instructions. Running `source("R/run_all.R")` regenerates every figure and table in this post.

## References

- Anselin, L. (1995). Local Indicators of Spatial Association: LISA. *Geographical Analysis*, 27(2), 93-115.
- Chetty, R., and Hendren, N. (2018). The Impacts of Neighborhoods on Intergenerational Mobility I: Childhood Exposure Effects. *Quarterly Journal of Economics*, 133(3), 1107-1162.
- Rothstein, R. (2017). *The Color of Law: A Forgotten History of How Our Government Segregated America*. Liveright.
- Sampson, R. J. (2012). *Great American City: Chicago and the Enduring Neighborhood Effect*. University of Chicago Press.
- U.S. Census Bureau. American Community Survey 5-Year Estimates, 2018-2022, Table B19013; TIGER/Line Shapefiles (2022).
