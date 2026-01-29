# Install required R packages for the ACCESS-2026 website

# Specify the user library path
user_lib <- Sys.getenv("R_LIBS_USER")

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# Core packages
install.packages(
  c("rmarkdown",
    "blogdown",
    "googlesheets4",
    "glue",
    "dplyr",
    "RefManageR",
    "kableExtra",
    "bibtex",
    "rjson",
    "data.table",
    "remotes"),  # Correctly formatted as a vector
  lib = user_lib
)

# Install slickR from GitHub
remotes::install_github("yonicd/slickR", lib = user_lib)

# Install Hugo via blogdown
blogdown::install_hugo("0.101.0")

# Optional: Install renv for package management
install.packages("renv", lib = user_lib)
renv::activate()  # Run renv::restore() if renv.lock exists