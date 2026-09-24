#### Preamble ####
# Purpose: Explores Toronto tennis facilities and produces three figures
# and a neighbourhood-level tennis court supply table.
# Author: Jingwen Zhong
# Date: 23 September 2026
# Contact: lisazjw.zhong@mail.utoronto.ca
# License: MIT
# Pre-requisites:
#   - The `tidyverse` and `sf` packages must be installed
#   - 02-download_data.R and 03-clean_data.R must have been run
# Any other information needed? Run this script from the
# `Toronto_Tennis_Access` R project.


#### Workspace setup ####
library(tidyverse)
library(sf)

dir.create(
  "outputs/figures",
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  "outputs/tables",
  recursive = TRUE,
  showWarnings = FALSE
)


#### Load data ####

analysis_data <- read_csv(
  "data/02-analysis_data/cleaned_data.csv",
  show_col_types = FALSE
) |>
  mutate(
    type = factor(type, levels = c("Public", "Club")),
    lights = factor(lights, levels = c("No", "Yes")),
    winter_play = factor(
      winter_play,
      levels = c("Not indicated", "Yes")
    )
  )

neighbourhood_population <- read_csv(
  "data/02-analysis_data/neighbourhood_population.csv",
  show_col_types = FALSE
)

municipal_boundaries <- st_read(
  "data/01-raw_data/gta_municipal_boundaries.geojson",
  quiet = TRUE
) |>
  st_transform(4326)

toronto_neighbourhoods <- st_read(
  "data/01-raw_data/toronto_neighbourhoods.geojson",
  quiet = TRUE
) |>
  st_transform(4326)


#### Figure 1: Spatial distribution ####

tennis_sf <- analysis_data |>
  st_as_sf(
    coords = c("longitude", "latitude"),
    crs = 4326,
    remove = FALSE
  )

municipality_labels <- municipal_boundaries |>
  filter(municipality != "Toronto") |>
  st_transform(26917) |>
  st_point_on_surface() |>
  st_transform(4326)

neighbourhood_lines <- st_sf(
  geometry = st_boundary(
    st_geometry(toronto_neighbourhoods)
  )
)

figure_1 <- ggplot() +
  
  geom_sf(
    data = municipal_boundaries,
    fill = "grey97",
    color = "grey55",
    linewidth = 0.5
  ) +
  
  geom_sf(
    data = neighbourhood_lines,
    color = "grey65",
    linewidth = 0.30
  ) +
  
  geom_sf_text(
    data = municipality_labels,
    aes(label = municipality),
    color = "grey35",
    size = 3
  ) +
  
  geom_sf(
    data = tennis_sf,
    aes(
      color = type,
      size = courts
    ),
    alpha = 0.82
  ) +
  
  scale_size_continuous(
    range = c(1.5, 6),
    breaks = c(1, 3, 5, 8, 13)
  ) +
  
  coord_sf(
    xlim = c(-79.75, -79.00),
    ylim = c(43.55, 43.95),
    expand = FALSE
  ) +
  
  labs(
    title = "Toronto Tennis Facilities by Size and Operation Type",
    subtitle = "Each point represents one tennis record; larger points report more courts",
    x = "Longitude",
    y = "Latitude",
    color = "Type",
    size = "Reported courts",
    caption = paste(
      "Tennis records and neighbourhood boundaries:",
      "City of Toronto Open Data;",
      "municipal boundaries: OpenStreetMap"
    )
  ) +
  
  theme_minimal() +
  
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "right",
    plot.title = element_text(
      face = "bold",
      size = 13
    )
  )

figure_1

ggsave(
  "outputs/figures/figure_1_map.png",
  figure_1,
  width = 10,
  height = 7,
  dpi = 300
)


#### Figure 2: Lighting status and operation type ####

figure_2 <- ggplot(
  analysis_data,
  aes(
    x = lights,
    fill = type
  )
) +
  
  geom_bar() +
  
  labs(
    title = "Toronto Tennis Records by Lighting Status and Operation Type",
    x = "Lights",
    y = "Number of tennis records",
    fill = "Type"
  ) +
  
  theme_minimal() +
  
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "right",
    plot.title = element_text(
      face = "bold",
      size = 12
    )
  )

figure_2

ggsave(
  "outputs/figures/figure_2_lights_by_type.png",
  figure_2,
  width = 6,
  height = 6,
  dpi = 300
)


#### Figure 3: Winter play and operation type ####

figure_3 <- ggplot(
  analysis_data,
  aes(
    x = winter_play,
    fill = type
  )
) +
  
  geom_bar() +
  
  labs(
    title = "Toronto Tennis Records by Winter Play Status and Operation Type",
    x = "Winter play",
    y = "Number of tennis records",
    fill = "Type"
  ) +
  
  theme_minimal() +
  
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "right",
    plot.title = element_text(
      face = "bold",
      size = 12
    )
  )

figure_3

ggsave(
  "outputs/figures/figure_3_winter_play_by_type.png",
  figure_3,
  width = 6,
  height = 6,
  dpi = 300
)


#### Table 1: Courts per neighbourhood population ####

# Assign each tennis record to a Toronto neighbourhood
tennis_neighbourhood <- st_join(
  tennis_sf,
  toronto_neighbourhoods |>
    transmute(
      neighbourhood_id = as.integer(AREA_SHORT_CODE)
    ),
  join = st_within,
  left = TRUE
)

# Sum all reported courts in each neighbourhood,
# regardless of Public or Club status
neighbourhood_courts <- tennis_neighbourhood |>
  st_drop_geometry() |>
  filter(!is.na(neighbourhood_id)) |>
  group_by(neighbourhood_id) |>
  summarise(
    total_reported_courts = sum(courts),
    .groups = "drop"
  )

# Join court totals to population data
neighbourhood_tennis_table <- neighbourhood_population |>
  left_join(
    neighbourhood_courts,
    by = "neighbourhood_id"
  ) |>
  mutate(
    total_reported_courts = replace_na(
      total_reported_courts,
      0
    ),
    
    court_population_ratio =
      total_reported_courts / population,
    
    courts_per_10000 =
      total_reported_courts / population * 10000
  ) |>
  
  select(
    neighbourhood_id,
    neighbourhood,
    population,
    total_reported_courts,
    court_population_ratio,
    courts_per_10000
  ) |>
  
  arrange(
    desc(courts_per_10000)
  )


#### Save neighbourhood table ####

write_csv(
  neighbourhood_tennis_table,
  "outputs/tables/neighbourhood_tennis_per_capita.csv"
)


#### Display neighbourhood table ####

neighbourhood_tennis_table

#### Figure 4: Distribution of courts per 10,000 residents ####

figure_4 <- ggplot(
  neighbourhood_tennis_table,
  aes(x = courts_per_10000)
) +
  geom_histogram(
    bins = 20,
    color = "white"
  ) +
  labs(
    title = "Distribution of Reported Tennis Courts per 10,000 Residents",
    subtitle = "Across Toronto's 158 neighbourhoods",
    x = "Reported courts per 10,000 residents",
    y = "Number of neighbourhoods"
  ) +
  theme_minimal() +
  theme(
    panel.grid.minor = element_blank(),
    plot.title = element_text(
      face = "bold",
      size = 12
    )
  )

figure_4

ggsave(
  "outputs/figures/figure_4_courts_per_10000_histogram.png",
  figure_4,
  width = 7,
  height = 6,
  dpi = 300
)