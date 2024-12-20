---
author:
- Javier Mancilla Galindo
authors:
- affiliations:
  - name: Utrecht University
  - department: Institute for Risk Assessment Sciences
  - group: Occupational Health
  - city: Utrecht
  - country: Netherlands
  email: j.mancillagalindo@uu.nl
  name:
    family: Mancilla Galindo
    given: Javier
    literal: Javier Mancilla Galindo
  orcid: "https://orcid.org/0000-0002-0718-467X"
bibliography: references.bib
date: 2024-12-21
editor: source
execute:
  echo: true
  eval: false
  warning: false
subtitle: Demonstration of R Workflows incorporation the Python Code
  Carbon Footprint
title: Measure your code's Energy Consumption in R
toc-title: Table of contents
---

# Introduction

There is growing awareness about the impact that our coding practices
have in terms of energy consumption, but also its carbon footprint. You
can read more about this in the [Green Digital Skills
Lesson](https://esciencecenter-digital-skills.github.io/green-digital-skills/).
If you are mainly using R, you may want to learn more about the impact
of your R code in terms of energy consumption and carbon footprint.
However, there aren't yet as of now R packages that allow to do this in
a reliable and user-friendly way. One promising tool is the [***RJoules
package***](https://rishalab.github.io/RJoules/); however, it is still
in development and restricted to certain operating systems more
frequently used by developers (i.e., linux).

**CarbonCode** is a Python package that estimates the carbon footprint
of code. You can read more about it at
https://mlco2.github.io/codecarbon/. This Python module is well
documented and easy to use. How sad that it is only available for
python... But there is a way to use it in R! In fact, it is possible and
relatively easy to run Python in RStudio. This can be done through the
[`reticulate`](https://rstudio.github.io/reticulate/) package, which
allows you to run Python code from R directly into your R script. For
more complex workflows,
[**Quarto**](https://quarto.org/docs/computations/python.html) can be
used to combine R and Python code in the same document. In fact, Quarto
markdown files (.qmd) are exceptionally good at calling R and Python
code in the same document, whilst also making it explicit what code
belongs to R and what code belongs to Python.

This tutorial shows how to implement CodeCarbon in R by using Quarto
tools in RStudio. An example workflow is provided by measuring the
carbon footprint of different packages and modelling strategies
accounting for induced time-varying confounding in the built-in R
`ChickWeight` dataset.

# Instalation

The detailed instructions for installation of Python and CodeCarbon are
found in the [Green Digital Skills dedicated
lesson](https://esciencecenter-digital-skills.github.io/green-digital-skills/modules/software-development-handson/exercises_codecarbon).
It is assumed that you have already followed these steps.

## Calling CodeCarbon in an R script

The following workflow is available in this [R
script](https://github.com/javimangal/green-digital-skills-r/blob/main/R/code-carbon-script.R),
which you can reuse and adapt to test your code.

First, you will need to install the `reticulate` package and load it
into your session:

    install.packages("reticulate")
    library(reticulate)

Load the CodeCarbon module using the reticulate
[`import`](https://rstudio.github.io/reticulate/reference/import.html)
function.

    codecarbon <- import("codecarbon")

Import the OfflineEmissionsTracker class

    OfflineEmissionsTracker <- codecarbon$OfflineEmissionsTracker

Set the emission trackers parameter and initialize. This will
automatically detect your system's characteristics and open a file to
save the report later on. You can also specify the country code, timing
of measurements, among others. See the [CodeCarbon
documentation](https://mlco2.github.io/codecarbon/parameters.html#id6)
for more details:

    tracker <- OfflineEmissionsTracker(
      country_iso_code = "NLD",
      measure_power_secs = 5
    )

Start tracking the emissions, run your code, and finish tracking once
your code ran.

    tracker$start()

    # Your R code here

    tracker$stop()

This will terminate the report and save it in your default working
directory, unless you specified earlier the path to save it according to
the provided documentation.

Note that CodeCarbon will continue to track until you explicitly stop it
with `tracker$stop()`. Thus, you may want to run all lines of code from
start -\> code -\> stop in one go to measure the consumption of that
specific code.

## Calling CodeCarbon in an Quarto markdown (qmd) file in RStudio

If you use Quarto, you can call Python and R code in the same document,
using their native syntax. For this, you can specify the language of the
code block using the `python` or `r` tags:

```` markdown
```{python}

# Your python code here

```
````

```` markdown
```{r}

# Your R code here

```
````

RStudio automatically processes the programming language. R is the
default language in Quarto when introducing code blocks. If you want to
run Python code, you need to change `r` for the the `python` tag.

The advantage of using quarto is that you don't need to rewrite python
code into the `reticulate` syntax. You can simply copy and paste the
python code into the `python` code block. This is a great advantage when
you are not familiar with Python, when you want to reuse well-documented
native python code, or simply to efficiently communicate with python
programmers.

Because Rstudio loads the reticulate package once it reads the `python`
tag, you don't need to load the `reticulate` package in the code block.
Thus, we will start by calling the CodeCarbon module in Python.

::: cell
``` {.python .cell-code}
# Load the CodeCarbon module
from codecarbon import EmissionsTracker
```
:::

Then, we will initialize the tracker and start tracking the emissions.

::: cell
``` {.python .cell-code}
# Initialize the tracker
tracker = OfflineEmissionsTracker(country_iso_code="NLD",
                                 measure_power_secs=5)

# Start tracking the emissions
tracker.start()
```
:::

You can now change to R language by using the `r` tag.

::: cell
``` {.r .cell-code}
# Introduce your R code here. For example, a fictitious computationally 
# intensive function for which you would like to test it's energy consumption. 
intense_computation(large_dataset)
```
:::

Finally, you can stop tracking the emissions and print the results. You
will again find the report as a csv file in your default working
directory.

::: cell
``` {.python .cell-code}
emissions: float = tracker.stop()
print(emissions)
```
:::

Combining R and Python code in a .qmd file will work best if (1) you
have a good understanding of both languages, and (2) when rendering your
document to any of the output report files implemented in Quarto (i.e.,
PDF, docx, slides, etc). This is because code blocks are executed in the
order they are found in the document. However, if you mainly work with R
scripts, running CodeCarbon with the `reticulate` package in R will be
the best approach.

# Demonstration

We will compare two R packages commonly used to fit mixed-effects models
that are often compared due to their computational speed. `lme4` is
suitable for generalized linear mixed models, runs in C++, and is
optimized for speed [@bates2015], whereas `nlme` can additionally fit
non-linear models, but is written in R language (before: S and S-Plus)
which makes computations slower and with a potentially higher carbon
footprint [@pinheiro2000].

However, there are often preliminary modelling steps needed when trying
to elucidate the main effects with these two packages. One example is
time varying confounding, for which different modelling approaches have
been proposed. Inverse probability weighting (IPW) is a powerful tool
for such analyses, but many different models can be used to obtain
inverse probability weights to be used in the main mixed-effects models.
Generalized linear models can be used as a fast an computationally
efficient option to obtain IPW through the built-in `stats` R package,
which is written in R and C language, but is highly susceptible to
incorrect model specification. Novel non-parametric methods are robust
to model misspecification [@fong2018], and are implemented in the `CBPS`
package, which despite running in C++ for computational efficiency, uses
intensive and lengthy calculations. These two methods will be compared
using Python `CodeCarbon`. We will use the `WeightIt` package written in
R language [@greifer2017], which has implemented these two methods and
many others which can be similarly tested and compared in terms of
energy consumption and carbon footprint.

We will use the built-in R `ChickWeight` dataset to simulate new data
with time-varying treatment-outcome confounding to study the effect of 4
different diets on weight, by accounting for the confounding effect of a
time-varying binary disease 1, and an ordinal disease 2, which disease
status may also vary in time.

First, install and load all the necessary R packages to avoid these
one-time installations being tracked by CodeCarbon. The `pacman` package
nicely handles installation and loading:

::: cell
``` {.r .cell-code}
if (!require("pacman", quietly = TRUE)) {
  install.packages("pacman")
}

pacman::p_load(
  tidyverse,        # Used for basic data handling and visualization.
  conflicted,       # Used to handle conflicts between packages.
  reticulate,       # Used to call Python code in R.
  lme4,             # Used to fit linear mixed-effects models.
  nlme,             # Used to fit non-linear mixed-effects models.
  WeightIt,         # Used to obtain inverse probability weights (IPW).
  CBPS             # Used to obtain non-parametric CBPS IPW.
)

conflicts_prefer(dplyr::select, dplyr::lag, dplyr::filter)
```
:::

We now simulate the data and measure the time required to complete and
it's carbon footprint. The input and output parameters have been adapted
in the R script to save the output file in the `emissions` folder. By
running this chunk of code, you will also see the live emissions
tracking as R console output.

> Important! If you interrupt the code before it finishes, emissions
> will keep to be tracked and shown until you stop it by running the
> last line in the scripts. This is important to keep in mind when
> running new code chunks and start a new tracker.

Tip: If any of the scripts take too long to run, you can try modifying
the `sample_size` parameter in the *data_simulation.R* script. This can
also be changed to explore emissions with different sample sizes.

::: cell
``` {.r .cell-code}
source("data-simulation.R")
```
:::

Let's now measure the energy consumption of obtaining inverse
probability weights with a generalized linear model in the built-in
`stats` R package.

::: cell
``` {.r .cell-code}
source("ipw_glm.R")
```
:::

And compare against the novel non-parametric method implemented in the
`CBPS` package. This will take longer to run than the prior steps, so we
will track emissions every 5 seconds.

::: cell
``` {.r .cell-code}
source("ipw_CBPS.R")
```
:::

Finally, we will fit the mixed-effects models with the `lme4` and `nlme`
packages, and compare their energy consumption.

::: cell
``` {.r .cell-code}
source("mixed_model_lme4.R")
```
:::

::: cell
``` {.r .cell-code}
source("mixed_model_nlme.R")
```
:::

## Simulation with a larger dataset

The original tests used 550 observations in a total of 50 chicks. This
was sufficient to demonstrate the differences in emissions with the two
IPW methods, but not with the different mixed-effects packages. We will
next simulate a much larger dataset with 5000 chicks to be able to
compare `lme4` and `nlme`.

::: cell
``` {.r .cell-code}
# Simulate new data and prepare the dataset for analysis 

simulated_data <- simulate_chickweight(n_chicks = 5000)

analysis_data <- simulated_data %>%
  arrange(Chick, Time) %>%
  group_by(Chick) %>%
  mutate(
    lag_disease_1 = lag(disease_1),
    lag_disease_2 = lag(disease_2),
    lag_weight = lag(weight)
  ) %>%
  ungroup()

analysis_data <- analysis_data %>%
  filter(!is.na(lag_disease_1))
```
:::

We will use the IPW obtained with glm.

::: cell
``` {.r .cell-code}
source("ipw_glm.R")
```
:::

And now we can compare the energy consumption of fitting the exact same
model with the two packages.

::: cell
``` {.r .cell-code}
source("mixed_model_lme4.R")
```
:::

::: cell
``` {.r .cell-code}
source("mixed_model_nlme.R")
```
:::

# License

> This work is the result of a contribution to the pilot [Green Digital
> Skills
> lesson](https://esciencecenter-digital-skills.github.io/green-digital-skills/)
> of the Netherlands eScience Center. All contents are licensed by
> Utrecht University under the terms of the [MIT license](../LICENSE).
