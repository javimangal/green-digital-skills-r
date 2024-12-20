#### INVERSE PROBABILITY WEIGHTING: npCBPS #### 

if (!require("reticulate", quietly = TRUE)) {
  install.packages("reticulate")
}

# Load the CodeCarbon module using the reticulate `import` function
codecarbon <- import("codecarbon")

# Import the OfflineEmissionsTracker class
OfflineEmissionsTracker <- codecarbon$OfflineEmissionsTracker

# Set the emision trackers parameter and initialize.
# See the CodeCarbon documentation for more details: 
# https://mlco2.github.io/codecarbon/parameters.html#id6

tracker <- OfflineEmissionsTracker(
  country_iso_code = "NLD",
  measure_power_secs = 5,
  project_name = "ChickWeight_Simulation",
  output_file = "emissions/ipw_CBPS.csv"
)

# Start tracking the emissions
tracker$start()

#### START OF YOUR R CODE #### 

# This will overwrite the original weights generated with logistic regression 
# because it is not the objective of this analysis to compare the two methods, 
# but to demonstrate how they differ in terms of energy consumption and emissions.

# Calculate weights using npCBPS

weights_npCBPS <- weightit(
  Diet ~ lag_disease_1 + disease_1 + 
    lag_disease_2 + disease_2 + 
    lag_weight + Time,
  data = analysis_data,
  method = "npcbps", 
  estimand = "ATE"
)

# Add weights to dataset
analysis_data$weights_npCBPS <- weights_npCBPS$weights


#### END OF YOUR R CODE ####

# Stop tracking the emissions. This will terminate the report and save it 
# in your default working directory if you did not specify the path to save it.
tracker$stop()

# Note that CodeCarbon will continue to track until you explicitly stop it. 
# You may want to run all lines of code from start -> code -> stop in one go 
# to measure the consumption of your specific code. 