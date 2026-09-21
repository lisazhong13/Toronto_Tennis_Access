#### Preamble ####
# Purpose: Tests the structure and validity of the simulated Toronto tennis
#facilities dataset.
# Author: Jingwen Zhong
# Date: 20 September 2026
# Contact: lisazjw.zhong@mail.utoronto.ca
# License: MIT
# Pre-requisites:
# - The `tidyverse` package must be installed and loaded
# - 00-simulate_data.R must have been run
# Any other information needed? Make sure you are in the
#`toronto-tennis-access` rproj


#### Workspace setup ####
library(tidyverse)

analysis_data <- read_csv(
  "data/00-simulated_data/simulated_data.csv",
  show_col_types = FALSE
)


#### Test if data loaded ####

if (exists("analysis_data")) {
  message("Test Passed: The dataset was successfully loaded.")
} else {
  stop("Test Failed: The dataset could not be loaded.")
}


#### Test data structure ####

# Check if the dataset has 175 rows
if (nrow(analysis_data) == 175) {
  message("Test Passed: The dataset has 175 rows.")
} else {
  stop("Test Failed: The dataset does not have 175 rows.")
}


# Check if the dataset has the expected columns
expected_columns <- c(
  "ID",
  "Name",
  "Type",
  "Lights",
  "Courts",
  "Phone",
  "ClubName",
  "ClubWebsite",
  "ClubInfo",
  "LocationAddress",
  "WinterPlay",
  "Longitude",
  "Latitude"
)

if (setequal(names(analysis_data), expected_columns)) {
  message("Test Passed: The dataset contains all expected columns.")
} else {
  stop("Test Failed: The dataset does not contain the expected columns.")
}


#### Test identifiers ####

# Check if all facility IDs are unique
if (n_distinct(analysis_data$ID) == nrow(analysis_data)) {
  message("Test Passed: All facility IDs are unique.")
} else {
  stop("Test Failed: The ID column contains duplicate values.")
}


# Check if IDs contain no missing values
if (all(!is.na(analysis_data$ID))) {
  message("Test Passed: The ID column contains no missing values.")
} else {
  stop("Test Failed: The ID column contains missing values.")
}


# Check if facility names are complete
if (all(!is.na(analysis_data$Name)) & all(analysis_data$Name != "")) {
  message("Test Passed: All facilities have names.")
} else {
  stop("Test Failed: Some facilities have missing or empty names.")
}


#### Test facility type ####

valid_types <- c("Public", "Club")

if (all(analysis_data$Type %in% valid_types)) {
  message("Test Passed: The Type column contains only valid facility types.")
} else {
  stop("Test Failed: The Type column contains invalid facility types.")
}


# Check if both facility types appear
if (n_distinct(analysis_data$Type) >= 2) {
  message("Test Passed: Both public and club facilities are represented.")
} else {
  stop("Test Failed: There is insufficient variation in facility type.")
}


#### Test number of courts ####

# Check if court counts are complete
if (all(!is.na(analysis_data$Courts))) {
  message("Test Passed: The Courts column contains no missing values.")
} else {
  stop("Test Failed: The Courts column contains missing values.")
}


# Check if all court counts are positive whole numbers
if (
  all(analysis_data$Courts >= 1) &
  all(analysis_data$Courts %% 1 == 0)
) {
  message("Test Passed: All court counts are positive whole numbers.")
} else {
  stop("Test Failed: Some court counts are invalid.")
}


# Check if court counts fall within the simulated range
if (all(analysis_data$Courts <= 8)) {
  message("Test Passed: Court counts fall within the expected range.")
} else {
  stop("Test Failed: Some court counts exceed the expected range.")
}


# Check if there is variation in court counts
if (n_distinct(analysis_data$Courts) >= 2) {
  message("Test Passed: The Courts column contains variation.")
} else {
  stop("Test Failed: The Courts column contains insufficient variation.")
}


#### Test lighting ####

valid_lighting <- c("Yes", "No")

if (all(analysis_data$Lights %in% valid_lighting)) {
  message("Test Passed: The Lights column contains only valid values.")
} else {
  stop("Test Failed: The Lights column contains invalid values.")
}


# Check if both lit and unlit facilities are represented
if (n_distinct(analysis_data$Lights) >= 2) {
  message("Test Passed: Both lit and unlit facilities are represented.")
} else {
  stop("Test Failed: There is insufficient variation in lighting.")
}


#### Test winter play ####

# WinterPlay is coded as "Yes" when available and blank otherwise
if (
  all(
    is.na(analysis_data$WinterPlay) |
    analysis_data$WinterPlay == "Yes"
  )
) {
  message("Test Passed: WinterPlay contains only expected values.")
} else {
  stop("Test Failed: WinterPlay contains invalid values.")
}


# Check if at least one facility permits winter play
if (any(analysis_data$WinterPlay == "Yes", na.rm = TRUE)) {
  message("Test Passed: At least one facility permits winter play.")
} else {
  stop("Test Failed: No facility permits winter play.")
}


#### Test club information ####

# Public facilities should not have club names
public_club_names <- analysis_data |>
  filter(Type == "Public") |>
  pull(ClubName)

if (all(is.na(public_club_names))) {
  message("Test Passed: Public facilities do not have club names.")
} else {
  stop("Test Failed: Some public facilities have club names.")
}


# Club facilities should have club names
club_names <- analysis_data |>
  filter(Type == "Club") |>
  pull(ClubName)

if (all(!is.na(club_names)) & all(club_names != "")) {
  message("Test Passed: All club facilities have club names.")
} else {
  stop("Test Failed: Some club facilities do not have club names.")
}


# Club websites should only appear for club facilities
public_websites <- analysis_data |>
  filter(Type == "Public") |>
  pull(ClubWebsite)

if (all(is.na(public_websites))) {
  message("Test Passed: Public facilities do not have club websites.")
} else {
  stop("Test Failed: Some public facilities have club websites.")
}


#### Test geographic coordinates ####

# Check if coordinates are complete
if (
  all(!is.na(analysis_data$Longitude)) &
  all(!is.na(analysis_data$Latitude))
) {
  message("Test Passed: Geographic coordinates contain no missing values.")
} else {
  stop("Test Failed: Geographic coordinates contain missing values.")
}


# Check longitude bounds
if (
  all(
    analysis_data$Longitude >= -79.65 &
    analysis_data$Longitude <= -79.10
  )
) {
  message("Test Passed: Longitude values fall within plausible Toronto bounds.")
} else {
  stop("Test Failed: Some longitude values fall outside plausible Toronto bounds.")
}


# Check latitude bounds
if (
  all(
    analysis_data$Latitude >= 43.58 &
    analysis_data$Latitude <= 43.86
  )
) {
  message("Test Passed: Latitude values fall within plausible Toronto bounds.")
} else {
  stop("Test Failed: Some latitude values fall outside plausible Toronto bounds.")
}


#### Test key missingness ####

# Variables that should always be present
required_variables <- analysis_data |>
  select(ID, Name, Type, Courts, LocationAddress, Longitude, Latitude)

if (all(!is.na(required_variables))) {
  message("Test Passed: Required variables contain no missing values.")
} else {
  stop("Test Failed: One or more required variables contain missing values.")
}


message("All simulated data tests passed successfully.")