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
  measure_power_secs = 1,
  project_name = "ChickWeight_Simulation",
  output_file = "emissions/mixed_model_lme4.csv"
)

# Start tracking the emissions
tracker$start()

#### START OF YOUR R CODE #### 

model_lme4 <- lmer(
  weight ~ Diet + Time + (1 + Time | Chick),
  data = analysis_data,
  weights = weights_glm
)

#### END OF YOUR R CODE ####

# Stop tracking the emissions. This will terminate the report and save it 
# in your default working directory if you did not specify the path to save it.
tracker$stop()

# Note that CodeCarbon will continue to track until you explicitly stop it. 
# You may want to run all lines of code from start -> code -> stop in one go 
# to measure the consumption of your specific code. 