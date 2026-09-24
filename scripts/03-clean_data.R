#### Preamble ####
# Purpose: Cleans the Toronto tennis facilities data downloaded from the
# Toronto Open Data Portal and creates an analysis-ready dataset.
# Author: Jingwen Zhong
# Date: 22 September 2026
# Contact: lisazjw.zhong@mail.utoronto.ca
# License: MIT
# Pre-requisites:
#   - The `tidyverse` package must be installed
#   - The `jsonlite` package must be installed
#   - 02-download_data.R must have been run
# Any other information needed? Run this script from the
# `toronto-tennis-access` R project.


#### Workspace setup ####
library(tidyverse)


#### Load raw data ####
raw_data <- read_csv(
  "data/01-raw_data/raw_data.csv",
  show_col_types = FALSE
)


#### Helper functions ####

get_longitude <- function(x) {
  jsonlite::fromJSON(x)$coordinates[1, 1]
}

get_latitude <- function(x) {
  jsonlite::fromJSON(x)$coordinates[1, 2]
}


#### Clean data ####
cleaned_data <-
  raw_data |>
  rename(
    record_id = X_id,
    location_id = ID,
    name = Name,
    type = Type,
    lights = Lights,
    courts = Courts,
    club_name = ClubName,
    club_website = ClubWebsite,
    location_address = LocationAddress,
    winter_play = WinterPlay
  ) |>
  mutate(
    across(
      where(is.character),
      str_squish
    )
  ) |>
  mutate(
    # Stanley Greene Park is recorded as Type = "None" in the raw data.
    # External evidence identifies the courts as public.
    type = case_when(
      name == "Stanley Greene Park" & type == "None" ~ "Public",
      TRUE ~ type
    ),
    
    # Blank WinterPlay entries are not interpreted as confirmed "No".
    winter_play = case_when(
      winter_play == "Yes" ~ "Yes",
      winter_play == "" ~ "Not indicated",
      TRUE ~ "Not indicated"
    ),
    
    club_name = na_if(club_name, ""),
    club_website = na_if(club_website, ""),
    
    longitude = map_dbl(geometry, get_longitude),
    latitude = map_dbl(geometry, get_latitude)
  ) |>
  select(
    record_id,
    location_id,
    name,
    location_address,
    type,
    lights,
    courts,
    winter_play,
    club_name,
    club_website,
    longitude,
    latitude
  )


#### Save data ####
write_csv(
  cleaned_data,
  "data/02-analysis_data/cleaned_data.csv"
)

#### Clean neighbourhood population data ####

# Load raw 2021 Neighbourhood Profiles
neighbourhood_profiles_raw <- readRDS(
  "data/01-raw_data/neighbourhood_profiles_2021_raw.rds"
)


# The XLSX may contain either one sheet or multiple sheets.
# Find the sheet containing the neighbourhood census profile.
if (inherits(neighbourhood_profiles_raw, "data.frame")) {
  
  neighbourhood_profile <- neighbourhood_profiles_raw
  
} else {
  
  profile_sheet <- which(
    map_lgl(
      neighbourhood_profiles_raw,
      ~ any(
        .x[[1]] == "Neighbourhood Number",
        na.rm = TRUE
      )
    )
  )[1]
  
  neighbourhood_profile <-
    neighbourhood_profiles_raw[[profile_sheet]]
}


# Give the first column a simple name.
names(neighbourhood_profile)[1] <- "indicator"


# Extract neighbourhood number and population.
neighbourhood_population <- neighbourhood_profile |>
  filter(
    indicator %in% c(
      "Neighbourhood Number",
      "Total - Age groups of the population - 25% sample data"
    )
  ) |>
  
  pivot_longer(
    cols = -indicator,
    names_to = "neighbourhood",
    values_to = "value"
  ) |>
  
  pivot_wider(
    names_from = indicator,
    values_from = value
  ) |>
  
  transmute(
    neighbourhood_id = as.integer(`Neighbourhood Number`),
    neighbourhood = neighbourhood,
    population = as.numeric(
      `Total - Age groups of the population - 25% sample data`
    )
  )


# Check that all 158 neighbourhoods are represented
if (nrow(neighbourhood_population) == 158) {
  message("Population data contains 158 Toronto neighbourhoods.")
} else {
  stop("Population data does not contain 158 neighbourhoods.")
}


# Save analysis-ready population data
write_csv(
  neighbourhood_population,
  "data/02-analysis_data/neighbourhood_population.csv"
)