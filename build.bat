@echo off
REM Load environment variables from .secret file
for /f "usebackq delims=" %%A in (".secret") do set "%%A"

REM Run the build and serve commands
Rscript _preprocess.R && Rscript -e "blogdown::build_site(build_rmd = TRUE)" && Rscript -e "blogdown::serve_site()"