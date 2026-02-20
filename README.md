# ACCESS-2026 Website

This repository contains the source for the static ACCESS-2026 website, built with Hugo and blogdown.

## Github CI workflow
Commits to the `source` branch automatically trigger rebuilding, and a Github Action is triggered upon completion that publishes the website on the specified subdomain. 

`.github/workflows/deploy.yaml` contains info on how to build the website from this repo. 

Secrets (i.e. Google service JSON key) is injected via Github's account management system system (Settings > Secrets and variables > Actions). 

## Local Installation and Build

You can also build the website locally, to test features before pushing to the remote. 

### Prerequisites
- Install R (latest stable version from [cran.r-project.org](https://cran.r-project.org/)).
- Install Hugo (version 0.101.0; run `Rscript -e 'blogdown::install_hugo("0.101.0")'` after R setup).
- Install system dependencies (see below for OS-specific instructions).
- Set up environment variables (see explanation below).

### Install Dependencies
1. Run the provided R script to install packages: `Rscript install_packages.R`
2. Install system dependencies using the CLI instructions below.

#### Linux (Ubuntu/Debian)
Run these commands in a terminal:
```sh
sudo apt-get update
sudo apt-get install -y libcurl4-openssl-dev libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev pandoc golang-go
```

#### Windows
-  Install pandoc: Download the installer from pandoc.org/installing.html and add it to your PATH.
- Install GO: https://go.dev/dl/
- For system libraries: These are typically handled by R during package installation. Ensure Rtools is installed (download from cran.r-project.org/bin/windows/Rtools) for compilation support. 

#### Secrets management
 - `GOOGLE_SERVICE_JSON_KEY`: This is the JSON content of a Google Cloud service account key. To get it:
    - Go to the Google Cloud Console.
    - Create or select a project. 
    - Enable the Google Sheets API. 
    - Create a service account (IAM & Admin > Service Accounts).
    - Generate a JSON key for the service account.- - Copy the JSON content and set it as the env var (e.g., in a .secret file or system env).
- `PEOPLE_GOOGLE_SHEET_ID`: The ID of the Google Sheet containing people data. To get it:
    - Open the Google Sheet in your browser.
    - The ID is the long string in the URL (e.g., after /d/ and before /edit).
    - Share the sheet with the service account email (from the key above) with read access.
    - Set the ID as the env var.

Store these in a `.secret` file (sourced via `source .secret`) to avoid committing sensitive data. Ensure the service account has read-only access to the sheet.

Ensure your .secret file is formatted as:
``` json
GOOGLE_SERVICE_JSON_KEY=path_to_your_private_JSON_key_here
PEOPLE_GOOGLE_SHEET_ID=your_google_sheet_id_here
```

Trying to paste the content of the JSON private key file into the `.secret` file and parse it as an environmental variable creates all sorts of issues; better to serve it this way and keep the R script aligned with the CI workflow. 

The correct Google Sheet is under ACCESS-2026 > 01_website > Contributors_for_people_pages. 

Make sure the spreadsheet is shared with the service account email, with at least Viewer permissions. 

### Build and Serve Locally
#### Linux (Ubuntu/Debian)
``` shell
source .secret && Rscript _preprocess.R && Rscript -e 'blogdown::build_site(build_rmd = TRUE)' && Rscript -e 'blogdown::serve_site()'
``` 
##### Windows
``` cmd
build.bat
``` 

If successful, Hugo should serve the website on `localhost` address that you can open in your browser. 

# Minimal notes on Blogdown / Hugo
Everything that is in `static/` will be copied to a dir named `public/` during website building. Specifically, new media should be added under `static/img/` or `static/video/`. 

To modify the website pages, you should only need to edit the `.md` files contained in `content/`. In addition to the markdown files, there is an `.Rmd` file that generate the HTML picture gallery with [slickR](https://github.com/yonicd/slickR). 

Finally, the script `_preprocess.R` reads in a spreadsheet with contributors info using googlesheets4, and creates teh respective profiles under `content/people/`; 