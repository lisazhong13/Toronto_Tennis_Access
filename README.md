# Toronto Tennis Access

## Overview

This repository contains the data, code, and paper for an analysis of City of Toronto tennis facilities. The paper combines the City's tennis facility records with neighbourhood boundaries and 2021 Census population data to describe how courts differ by operation type (Public or Club), lighting, and winter-play designation, and how reported court supply varies across Toronto's neighbourhoods.

The main findings are that nearly all Club records have lights (63 of 66), compared with just over half of Public records (62 of 107); Public records hold most winter-play designations; and 57 of Toronto's 158 neighbourhoods contain no City tennis court.

The paper is available at [paper/paper.pdf](paper/paper.pdf).

## Data sources

The core analysis uses three datasets from Open Data Toronto, downloaded using the `opendatatoronto` R package:

- [Tennis Courts – Facilities](https://open.toronto.ca/dataset/tennis-courts-facilities/), published by Parks, Forestry and Recreation.
- [Neighbourhoods](https://open.toronto.ca/dataset/neighbourhoods/), containing the boundaries of Toronto's 158 neighbourhoods.
- [Neighbourhood Profiles](https://open.toronto.ca/dataset/neighbourhood-profiles/), used for 2021 Census neighbourhood population.

Surrounding municipal boundaries are downloaded from OpenStreetMap by `scripts/02-download_data.R` and used only as a background layer in the map.

## File structure

The repository is structured as follows:

- `data/00-simulated_data` contains the simulated tennis facility dataset used to test the expected data structure.
- `data/01-raw_data` contains the raw tennis facilities data, Toronto neighbourhood boundaries, 2021 neighbourhood population data, and geographic boundary files used for mapping.
- `data/02-analysis_data` contains the cleaned tennis facility dataset and analysis-ready neighbourhood population data.
- `other/llm_usage` contains the complete LLM chat history.
- `other/sketches` contains sketches used when planning the dataset, figures, and paper.
- `paper` contains the Quarto source document (`paper.qmd`), bibliography (`references.bib`), and rendered PDF (`paper.pdf`).
- `scripts` contains the R scripts used to simulate, test, download, and clean the data.

## Reproducing the analysis

1. Open `Toronto_Tennis_Access.Rproj` in RStudio.

2. Install the required R packages:

   `tidyverse`, `opendatatoronto`, `sf`, `jsonlite`, `here`, `testthat`, and `tinytable`.

3. Run the scripts in order:

   - `scripts/00-simulate_data.R` simulates a synthetic tennis facility dataset.
   - `scripts/01-test_simulated_data.R` checks the structure and validity of the simulated data.
   - `scripts/02-download_data.R` downloads the raw tennis facilities, neighbourhood boundaries, and 2021 neighbourhood population data from Open Data Toronto.
   - `scripts/03-clean_data.R` cleans the tennis facility records and prepares the neighbourhood population data for analysis.
   - `scripts/04-test_clean_data.R` tests the structure, validity, and internal consistency of the cleaned tennis facility dataset.

4. Render `paper/paper.qmd` to PDF.

The Quarto document reads the saved files from `data/01-raw_data` and `data/02-analysis_data`. It does not download the Open Data Toronto datasets during rendering. The neighbourhood spatial matching and calculation of reported courts per 10,000 residents are performed within the Quarto analysis.

The analysis was run using R version 4.4.2.

## Statement on LLM usage

ChatGPT was used during this project to assist with project planning, debugging code, interpreting error messages, discussing visualisation choices, preparing references, and editing written sections of the paper. All code was run and checked by the author, and all numerical results were verified against the underlying data.

The complete relevant chat histories are available in `other/llm_usage`.