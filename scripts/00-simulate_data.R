#### Preamble ####
# Purpose: Simulates a dataset of City-owned tennis facilities in Toronto,
# including facility type, number of courts, lighting, winter play,
# club information, and geographic coordinates.
# Author: Jingwen Zhong
# Date: 20 September 2026
# Contact: lisazjw.zhong@mail.utoronto.ca
# License: MIT
# Pre-requisites: The `tidyverse` package must be installed.
# Any other information needed? Run this script from the project root.


#### Workspace setup ####
library(tidyverse)

set.seed(853)


#### Simulation parameters ####
# Simulate approximately the expected number of City-owned tennis facilities.
# This is deliberately a rounded planning value rather than an attempt to
# reproduce the observed dataset exactly.
n_facilities <- 175


#### Simulate facility type ####
# Most facilities are expected to be public, while a smaller share are
# operated as community tennis clubs.
facility_type <- sample(
  c("Public", "Club"),
  size = n_facilities,
  replace = TRUE,
  prob = c(0.70, 0.30)
)


#### Simulate number of courts ####
# Court counts depend on facility type.
# Public facilities are assumed to usually contain fewer courts, while club
# facilities are assumed to be somewhat larger on average.
courts <- map_int(
  facility_type,
  \(type) {
    if (type == "Public") {
      sample(
        1:6,
        size = 1,
        prob = c(0.25, 0.40, 0.20, 0.10, 0.04, 0.01)
      )
    } else {
      sample(
        1:8,
        size = 1,
        prob = c(0.05, 0.15, 0.20, 0.25, 0.15, 0.10, 0.06, 0.04)
      )
    }
  }
)


#### Simulate lighting ####
# Larger facilities are assumed to be more likely to have lights.
# Club-operated facilities are also given a moderately higher probability
# of having lights.
light_probability <- plogis(
  -1.8 +
    0.45 * courts +
    0.55 * (facility_type == "Club")
)

lights <- if_else(
  rbinom(n_facilities, size = 1, prob = light_probability) == 1,
  "Yes",
  "No"
)


#### Simulate winter play ####
# Winter play is expected to be uncommon. Larger and lit facilities are
# assumed to have a slightly greater probability of supporting winter play.
winter_probability <- plogis(
  -4.5 +
    0.25 * courts +
    0.60 * (lights == "Yes")
)

winter_play <- if_else(
  rbinom(n_facilities, size = 1, prob = winter_probability) == 1,
  "Yes",
  NA_character_
)


#### Simulate geographic coordinates ####
# Rather than placing facilities uniformly inside a rectangle, locations are
# simulated around several broad centres across Toronto. This produces a more
# realistic spatial pattern while remaining entirely synthetic.

location_centres <- tibble(
  longitude = c(-79.54, -79.44, -79.38, -79.32, -79.24, -79.18),
  latitude = c(43.66, 43.70, 43.66, 43.72, 43.76, 43.78),
  probability = c(0.14, 0.18, 0.24, 0.16, 0.16, 0.12)
)

centre_id <- sample(
  1:nrow(location_centres),
  size = n_facilities,
  replace = TRUE,
  prob = location_centres$probability
)

longitude <- rnorm(
  n_facilities,
  mean = location_centres$longitude[centre_id],
  sd = 0.025
)

latitude <- rnorm(
  n_facilities,
  mean = location_centres$latitude[centre_id],
  sd = 0.018
)

# Keep simulated coordinates within plausible Toronto bounds.
longitude <- pmax(pmin(longitude, -79.10), -79.65)
latitude <- pmax(pmin(latitude, 43.86), 43.58)


#### Simulate facility and club information ####
facility_id <- seq_len(n_facilities)

facility_name <- paste(
  "Simulated Tennis Facility",
  str_pad(facility_id, width = 3, pad = "0")
)

location_address <- paste(
  sample(1:999, n_facilities, replace = TRUE),
  sample(
    c(
      "Park Road",
      "Greenwood Avenue",
      "Lakeshore Drive",
      "Valley Road",
      "Ravine Avenue"
    ),
    n_facilities,
    replace = TRUE
  )
)

# Club-specific variables are only meaningful for facilities classified
# as clubs. Some club contact information is deliberately missing to mimic
# realistic administrative data.
club_name <- if_else(
  facility_type == "Club",
  paste(
    "Community Tennis Club",
    str_pad(facility_id, width = 3, pad = "0")
  ),
  NA_character_
)

phone <- if_else(
  facility_type == "Club" & runif(n_facilities) < 0.85,
  paste0(
    "416-555-",
    str_pad(
      sample(0:9999, n_facilities, replace = TRUE),
      width = 4,
      pad = "0"
    )
  ),
  NA_character_
)

club_website <- if_else(
  facility_type == "Club" & runif(n_facilities) < 0.75,
  paste0(
    "https://example.com/tennis-club-",
    facility_id
  ),
  NA_character_
)

club_info <- if_else(
  facility_type == "Club" & runif(n_facilities) < 0.80,
  "Community tennis club with membership and public access hours.",
  NA_character_
)


#### Assemble simulated dataset ####
analysis_data <- tibble(
  ID = facility_id,
  Name = facility_name,
  Type = facility_type,
  Lights = lights,
  Courts = courts,
  Phone = phone,
  ClubName = club_name,
  ClubWebsite = club_website,
  ClubInfo = club_info,
  LocationAddress = location_address,
  WinterPlay = winter_play,
  Longitude = longitude,
  Latitude = latitude
)


#### Save data ####
write_csv(
  analysis_data,
  "data/00-simulated_data/simulated_data.csv"
)

