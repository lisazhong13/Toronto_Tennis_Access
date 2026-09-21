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