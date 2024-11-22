---
editor_options: 
  markdown: 
    wrap: sentence
---

# Green Digital Skills with R

This is a demonstration of the implementation of Green Code (python) in R-based workflows to measure the energy consumption of individual snippets of code, scripts, and rendered documents (i.e., Rmd/qmd).
This work is an extension to the [pilot Green Digital Skills workshop](https://github.com/esciencecenter-digital-skills/green-digital-skills) by the Netherlands eScience center.

## Usage

The suggested use of this repository starts with making sure that R, RStudio, and python are installed in your computer:

### 1. Install R and RStudio

[Install R and RStudio](https://posit.co/download/rstudio-desktop/) on your computer if you haven't done so.
Note that these demonstrations were conducted under R version 4.4.0 and RStudio 2024.04.0.

### 2. Install Python and CodeCarbon

Detailed instructions are provided [here](https://esciencecenter-digital-skills.github.io/green-digital-skills/modules/software-development-handson/exercises_codecarbon).

### 3. Download the material

There are several ways to download the necessary material:

-  The simplest way is to [download the ZIP file](https://github.com/javimangal/green-digital-skills-r/archive/refs/heads/main.zip), unpack it, and place it in a familiar folder in your computer.

-  Or [clone this repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository).

-  GitHub desktop is also a good option to copy this repository [by following these instructions](https://docs.github.com/en/desktop/overview/getting-started-with-github-desktop).

You should now have all the necessary files in your computer with an identical folder structure (described in the following section).

### 4. Open the project in RStudio

In the main directory, open the file named ***green-digital-skills-r.Rproj*** in RStudio. This will open RStudio in the default working directory of the project. You can now navigate through the folders on the right-bottom panel of R Studio.

Open the **R** folder. You should now see a series of files ending with ***.qmd*** (markdown document with embedded R and python code) and ***.R*** (these are conventional R scripts). From here, there are three main ways of using [CodeCarbon](https://mlco2.github.io/codecarbon/) in your R workflow. 

### 5. Running CodeCarbon in R scripts

There is a sample R script you can reuse and adapt to test your code. Open the file ***code-carbon-script.R*** in the **R** folder.

> 🚧 **This section is under construction. Stay tuned!**

## Project Structure

The project structure distinguishes three kinds of folders: - read-only (RO): not edited by either code or researcher - human-writeable (HW): edited by the researcher only.
- project-generated (PG): folders generated when running the code; these folders can be deleted or emptied and will be completely reconstituted as the project is run.

```         
.
├── .gitignore
├── CITATION.cff
├── LICENSE
├── README.md
├── docs               <- Documentation notebook for users (HW)
├── results
│   ├── figures        <- Figures for the manuscript or reports (PG)
│   └── output         <- Other output for the manuscript or reports (PG)
└── R                  <- Source code for this project (HW)
```

## Contact 

You can [contact me](mailto:j.mancillagalindo@uu.nl) or post a request in this repository in case you encounter any issues.

## License

This project is licensed under the terms of the [MIT License](/LICENSE).

This project structure repository is adapted from the [Utrecht University simple R project template](https://github.com/UtrechtUniversity/simple-r-project), which builds upon the [Good Enough Project](https://github.com/bvreede/good-enough-project) Cookiecutter template by Barbara Vreede (2019).
