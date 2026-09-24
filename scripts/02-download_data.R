#### Preamble ####
# Purpose: Downloads and saves City of Toronto tennis court facilities data
# from the Toronto Open Data Portal.
# Author: Jingwen Zhong
# Date: 20 September 2026
# Contact: lisazjw.zhong@mail.utoronto.ca
# License: MIT
# Pre-requisites:
#   - The `opendatatoronto` package must be installed
#   - The `tidyverse` package must be installed
# Any other information needed? Run this script from the project root.


#### Workspace setup ####
library(opendatatoronto)
library(tidyverse)
library(sf)


#### Download data ####

# Toronto Open Data package ID for Tennis Courts Facilities
package_id <- "409119c3-65d7-4688-bcb7-5f74f6fb8415"

# Get all available resources for the package
resources <- list_package_resources(package_id)

# Select the CSV resource using WGS 84 / EPSG:4326 coordinates.
# This coordinate system provides longitude and latitude, which will be useful
# for mapping the locations later in the analysis.
tennis_resource <- resources |>
  filter(
    tolower(format) == "csv",
    str_detect(name, "4326")
  )

# Check that exactly one matching resource was found
if (nrow(tennis_resource) == 1) {
  message("Resource successfully identified.")
} else {
  stop("Expected exactly one 4326 CSV resource.")
}

# Download the resource
raw_data <- get_resource(tennis_resource)


#### Save data ####

write_csv(
  raw_data,
  "data/01-raw_data/raw_data.csv"
)

#### Download Toronto neighbourhood boundaries ####

# Get all resources for the City of Toronto Neighbourhoods dataset.
# This dataset uses the current 158-neighbourhood model.
neighbourhood_resources <- list_package_resources(
  "https://open.toronto.ca/dataset/neighbourhoods/"
)

# Select the current 158-neighbourhood GeoJSON in WGS84 / EPSG:4326.
# Use the exact resource name so that the historical 140-neighbourhood
# boundary file is not selected.
neighbourhood_resource <- neighbourhood_resources |>
  filter(
    name == "Neighbourhoods - 4326.geojson"
  )

# Check that exactly one matching resource was found
if (nrow(neighbourhood_resource) == 1) {
  message("Toronto neighbourhood boundary resource successfully identified.")
} else {
  stop("Expected exactly one current 158-neighbourhood GeoJSON resource.")
}

# Download neighbourhood polygons
toronto_neighbourhoods <- get_resource(
  neighbourhood_resource
)

# Check that the current neighbourhood model contains 158 polygons
if (nrow(toronto_neighbourhoods) == 158) {
  message("Toronto neighbourhood data contains 158 neighbourhoods.")
} else {
  stop("Neighbourhood boundary data does not contain the expected 158 neighbourhoods.")
}

# Save locally for reproducible use in figures
sf::st_write(
  toronto_neighbourhoods,
  "data/01-raw_data/toronto_neighbourhoods.geojson",
  delete_dsn = TRUE,
  quiet = TRUE
)

#### Download 2021 Toronto neighbourhood population data ####

# Get all resources for the Toronto Neighbourhood Profiles dataset
profile_resources <- list_package_resources(
  "https://open.toronto.ca/dataset/neighbourhood-profiles/"
)

# Select the 2021 Census resource using the current 158-neighbourhood model
profile_resource <- profile_resources |>
  filter(
    tolower(format) == "xlsx",
    str_detect(
      str_to_lower(name),
      "2021"
    ),
    str_detect(
      str_to_lower(name),
      "158"
    )
  )

# Check that exactly one resource is identified
if (nrow(profile_resource) == 1) {
  message("2021 neighbourhood profile resource successfully identified.")
} else {
  print(
    profile_resources |>
      select(name, format)
  )
  
  stop(
    "Expected exactly one 2021 158-neighbourhood XLSX resource."
  )
}

# Download the Excel resource.
# XLSX files may be returned as either one tibble or a named list of sheets.
neighbourhood_profiles_raw <- get_resource(
  profile_resource
)

# Preserve the downloaded object without altering its structure.
saveRDS(
  neighbourhood_profiles_raw,
  "data/01-raw_data/neighbourhood_profiles_2021_raw.rds"
)