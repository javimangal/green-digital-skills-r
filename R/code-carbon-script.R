# Your can use this R script to measure carbon emissions of your R code with 
# the python module CodeCarbon. It is assumed that you have already installed
# CodeCarbon and Python in your system. Instructions available at: 
# https://esciencecenter-digital-skills.github.io/green-digital-skills/modules/software-development-handson/exercises_codecarbon

# Install the `reticulate` package and load it into your session: 
install.packages("reticulate")
library(reticulate)

# Load the CodeCarbon module using the reticulate `import` function
codecarbon <- import("codecarbon")

# Import the OfflineEmissionsTracker class
OfflineEmissionsTracker <- codecarbon$OfflineEmissionsTracker

# Set the emision trackers parameter and initialize. This will automatically
# detect your systems characteristics and open a file to save the report 
# later on. You can also specify the country code, timing of measurements, 
# among others. See the CodeCarbon documentation for more details: 
# https://mlco2.github.io/codecarbon/parameters.html#id6

tracker <- OfflineEmissionsTracker(
  country_iso_code = "NLD",
  measure_power_secs = 5
)

# Start tracking the emissions
tracker$start()

#### START OF YOUR R CODE #### 

# Your R code here

#### END OF YOUR R CODE ####

# Stop tracking the emissions. This will terminate the report and save it 
# in your default working directory if you did not specify the path to save it.
tracker$stop()

# Note that CodaCarbon will continue to track until you explicitly stop it. 
# You may want to run all lines of code from start -> code -> stop in one go 
# to measure the consumption of your specific code. 