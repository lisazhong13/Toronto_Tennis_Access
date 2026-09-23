#### Preamble ####
# Purpose: Tests the structure, validity, and internal consistency of the
# cleaned Toronto tennis facilities analysis dataset.
# Author: Jingwen Zhong
# Date: 23 September 2026
# Contact: lisazjw.zhong@mail.utoronto.ca
# License: MIT
# Pre-requisites:
#   - The `tidyverse` package must be installed
#   - The `testthat` package must be installed
#   - 03-clean_data.R must have been run
# Any other information needed? Run this script from the
# `toronto-tennis-access` R project.


#### Workspace setup ####
library(tidyverse)
library(testthat)

analysis_data <- read_csv(
  "data/02-analysis_data/cleaned_data.csv",
  show_col_types = FALSE
)


#### Test data structure ####

# Test that the dataset has 173 rows
test_that("dataset has 173 rows", {
  expect_equal(nrow(analysis_data), 173)
})

# Test that the dataset has 12 columns
test_that("dataset has 12 columns", {
  expect_equal(ncol(analysis_data), 12)
})

# Test that all expected columns are present
expected_columns <- c(
  "record_id",
  "location_id",
  "name",
  "location_address",
  "type",
  "lights",
  "courts",
  "winter_play",
  "club_name",
  "club_website",
  "longitude",
  "latitude"
)

test_that("dataset contains all expected columns", {
  expect_setequal(names(analysis_data), expected_columns)
})


#### Test variable types ####

test_that("'record_id' is numeric", {
  expect_type(analysis_data$record_id, "double")
})

test_that("'location_id' is numeric", {
  expect_type(analysis_data$location_id, "double")
})

test_that("'name' is character", {
  expect_type(analysis_data$name, "character")
})

test_that("'location_address' is character", {
  expect_type(analysis_data$location_address, "character")
})

test_that("'type' is character", {
  expect_type(analysis_data$type, "character")
})

test_that("'lights' is character", {
  expect_type(analysis_data$lights, "character")
})

test_that("'courts' is numeric", {
  expect_type(analysis_data$courts, "double")
})

test_that("'winter_play' is character", {
  expect_type(analysis_data$winter_play, "character")
})

test_that("'longitude' is numeric", {
  expect_type(analysis_data$longitude, "double")
})

test_that("'latitude' is numeric", {
  expect_type(analysis_data$latitude, "double")
})


#### Test identifiers ####

# Each row should have a unique record ID
test_that("'record_id' contains unique values", {
  expect_equal(
    n_distinct(analysis_data$record_id),
    nrow(analysis_data)
  )
})

# Location IDs are not expected to be unique because some parks contain
# separate public and club tennis records.
test_that("'location_id' contains 170 unique locations", {
  expect_equal(
    n_distinct(analysis_data$location_id),
    170
  )
})

# IDs should never be missing
test_that("identifiers contain no missing values", {
  expect_false(any(is.na(analysis_data$record_id)))
  expect_false(any(is.na(analysis_data$location_id)))
})


#### Test facility information ####

# Facility names and addresses should be present
test_that("facility names and addresses contain no missing values", {
  expect_false(any(is.na(analysis_data$name)))
  expect_false(any(is.na(analysis_data$location_address)))
})

# Facility names and addresses should not contain empty strings
test_that("facility names and addresses contain no empty strings", {
  expect_false(any(analysis_data$name == ""))
  expect_false(any(analysis_data$location_address == ""))
})


#### Test facility type ####

valid_types <- c("Public", "Club")

test_that("'type' contains only Public or Club", {
  expect_true(all(analysis_data$type %in% valid_types))
})

# Stanley Greene Park was recoded from None to Public during cleaning,
# so no unclassified records should remain.
test_that("no unclassified facility types remain", {
  expect_false(any(analysis_data$type == "None"))
})

test_that("both Public and Club facilities are represented", {
  expect_true(all(valid_types %in% analysis_data$type))
})


#### Test lighting ####

valid_lights <- c("Yes", "No")

test_that("'lights' contains only Yes or No", {
  expect_true(all(analysis_data$lights %in% valid_lights))
})

test_that("both lighting categories are represented", {
  expect_true(all(valid_lights %in% analysis_data$lights))
})

test_that("'lights' contains no missing values", {
  expect_false(any(is.na(analysis_data$lights)))
})


#### Test court counts ####

test_that("'courts' contains no missing values", {
  expect_false(any(is.na(analysis_data$courts)))
})

test_that("all court counts are positive", {
  expect_true(all(analysis_data$courts > 0))
})

test_that("all court counts are whole numbers", {
  expect_true(all(analysis_data$courts %% 1 == 0))
})

test_that("'courts' contains variation", {
  expect_true(n_distinct(analysis_data$courts) >= 2)
})


#### Test winter play ####

valid_winter_play <- c("Yes", "Not indicated")

test_that("'winter_play' contains only expected values", {
  expect_true(
    all(analysis_data$winter_play %in% valid_winter_play)
  )
})

test_that("both winter play categories are represented", {
  expect_true(
    all(valid_winter_play %in% analysis_data$winter_play)
  )
})

test_that("'winter_play' contains no missing values after cleaning", {
  expect_false(any(is.na(analysis_data$winter_play)))
})


#### Test club information ####

# Public facilities should not have club names
test_that("Public facilities do not have club names", {
  expect_true(
    all(
      is.na(
        analysis_data$club_name[
          analysis_data$type == "Public"
        ]
      )
    )
  )
})

# Public facilities should not have club websites
test_that("Public facilities do not have club websites", {
  expect_true(
    all(
      is.na(
        analysis_data$club_website[
          analysis_data$type == "Public"
        ]
      )
    )
  )
})

# At least some Club facilities should have club names
test_that("Club facilities contain club-name information", {
  expect_true(
    any(
      !is.na(
        analysis_data$club_name[
          analysis_data$type == "Club"
        ]
      )
    )
  )
})


#### Test geographic coordinates ####

test_that("coordinates contain no missing values", {
  expect_false(any(is.na(analysis_data$longitude)))
  expect_false(any(is.na(analysis_data$latitude)))
})

# Check that longitude falls within plausible Toronto bounds
test_that("longitude values fall within plausible Toronto bounds", {
  expect_true(
    all(
      analysis_data$longitude >= -79.65 &
        analysis_data$longitude <= -79.10
    )
  )
})

# Check that latitude falls within plausible Toronto bounds
test_that("latitude values fall within plausible Toronto bounds", {
  expect_true(
    all(
      analysis_data$latitude >= 43.58 &
        analysis_data$latitude <= 43.86
    )
  )
})


#### Test known totals ####

# The cleaned data should preserve the total number of court records
test_that("reported court counts sum to 581", {
  expect_equal(sum(analysis_data$courts), 581)
})

# After recoding Stanley Greene Park, there should be 107 Public records
# and 66 Club records.
test_that("facility-type counts match the cleaned data", {
  expect_equal(
    sum(analysis_data$type == "Public"),
    107
  )
  
  expect_equal(
    sum(analysis_data$type == "Club"),
    66
  )
})