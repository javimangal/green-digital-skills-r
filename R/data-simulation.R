#### SIMULATE DATA #### 

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
  output_file = "emissions/data_simulation.csv"
)

# Start tracking the emissions
tracker$start()

#### START OF YOUR R CODE #### 

# We will use the built-in `ChickWeight` dataset in R to demonstrate the
# use of CodeCarbon. This dataset contains the weight of chicks over time
# under different diets.

data("ChickWeight")
head(ChickWeight)

sample_size <- 50

simulate_chickweight <- function(n_chicks = 50, seed = 123) {
  # Set seed for reproducibility
  set.seed(seed)
  
  # Get unique time points from original data
  time_points <- sort(unique(ChickWeight$Time))
  
  # Simulate random effects for each chick
  random_effects <- data.frame(
    Chick = 1:n_chicks,
    # Random intercept for each chick
    intercept = rnorm(n_chicks, mean = 0, sd = 30),
    # Random slope for each chick
    slope = rnorm(n_chicks, mean = 0, sd = 2)
  )
  
  # Create base dataset structure
  chicks <- data.frame(
    Chick = rep(1:n_chicks, each = length(time_points)),
    Time = rep(time_points, n_chicks),
    Diet = factor(sample(1:4, n_chicks, replace = TRUE, 
                         prob = c(0.25, 0.25, 0.25, 0.25)) %>% 
                    rep(each = length(time_points)))
  )
  
  # Add random effects to the data
  chicks <- chicks %>%
    left_join(random_effects, by = "Chick")
  
  # Ensure Diet in original data is also a factor
  ChickWeight_mod <- ChickWeight %>%
    mutate(Diet = factor(Diet))
  
  # Fit a simple model to the original data to get fixed effects
  original_model <- lm(weight ~ Time * Diet, data = ChickWeight_mod)
  
  # Predict baseline weights including random effects
  chicks <- chicks %>%
    mutate(
      # Fixed effects from original model
      weight_true = predict(original_model, newdata = select(., Time, Diet)) +
        # Random effects
        intercept + slope * Time +
        # Residual error
        rnorm(n(), mean = 0, sd = 15)
    )
  
  # Simulate time-varying confounders
  chicks <- chicks %>%
    group_by(Chick) %>%
    mutate(
      # Binary disease with increasing probability over time
      disease_1_prob = plogis(-2 + 0.1 * Time + 0.001 * weight_true),
      disease_1 = rbinom(n(), size = 1, prob = disease_1_prob),
      
      # Ordinal disease (4 levels) with time-varying probability
      disease_2_base = rnorm(n(), 
                             mean = 0.5 * Time + 0.002 * weight_true, 
                             sd = 1),
      disease_2 = cut(disease_2_base, 
                      breaks = c(-Inf, -0.5, 0.5, 1.5, Inf),
                      labels = 1:4)
    ) %>%
    ungroup()
  
  # Simulate the effect of diseases on weight
  chicks <- chicks %>%
    mutate(
      # Effect of disease_1 (binary): reduction in weight
      disease_1_effect = -30 * disease_1 * (Time/max(Time)),
      
      # Effect of disease_2 (ordinal): varying impact based on level
      disease_2_effect = case_when(
        disease_2 == 1 ~ 0,
        disease_2 == 2 ~ -10,
        disease_2 == 3 ~ -25,
        disease_2 == 4 ~ -45
      ) * (Time/max(Time)),
      
      # Calculate final weight with disease effects
      weight = weight_true + disease_1_effect + disease_2_effect
    )
  
  # Clean up intermediate columns
  chicks <- chicks %>%
    select(Chick, Time, Diet, weight, disease_1, disease_2)
  
  return(chicks)
}

# Generate the simulated dataset
simulated_data <- simulate_chickweight(n_chicks = sample_size)

# First, let's prepare the data for time-varying treatment analysis
# We need to include both current and lagged values of confounders

analysis_data <- simulated_data %>%
  arrange(Chick, Time) %>%
  group_by(Chick) %>%
  mutate(
    # Lag the disease variables
    lag_disease_1 = lag(disease_1),
    lag_disease_2 = lag(disease_2),
    # Lag the weight
    lag_weight = lag(weight)
  ) %>%
  ungroup()

# Remove the first time point for each chick (since it has no lag values)
analysis_data <- analysis_data %>%
  filter(!is.na(lag_disease_1))

#### END OF YOUR R CODE ####

# Stop tracking the emissions. This will terminate the report and save it 
# in your default working directory if you did not specify the path to save it.
tracker$stop()

# Note that CodeCarbon will continue to track until you explicitly stop it. 
# You may want to run all lines of code from start -> code -> stop in one go 
# to measure the consumption of your specific code. 