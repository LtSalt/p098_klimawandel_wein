# README

## Before you start

- All data was added to the `.gitignore` and uploaded to OneDrive. Copy all folders from the [OneDrive data directory](https://suedwestrundfunk.sharepoint.com/:f:/r/sites/SWRDATA/Freigegebene%20Dokumente/p098_klimawandel_wein/data?csf=1&web=1&e=TBMJ5B) to `src/data/raw`.
- Run `src/analysis/00_setup.R` to preprocess data and recreate all reports.


## Getting familiar with the data

- Have a look at the presentation under `src/analysis/01_pitch`.
- Under `src/analysis/02_tutorial`, you'll find a small tutorial on how to work with and analyse the data.
- Under `src/analysis/03_dashboard/03_dashboard.R`, you'll find a simple shiny dashboard. Just click the `Run App` button in the top right corner of your IDE.


## File structure & reproducibility

This repo was designed to host data, data analysis reports and frontend code. 
- Dotfiles (like `.git`, `.RProj`) and setup files (`package.json`) should live in the root folder. 
- Everything else is in `src`.
- If you need to create a processed dataset before starting your own analysis, put it into `src/data/processed` (preferably in it's own subdirectory). It's good practice to do this in a dedicated script `00_setup.R`. This way, it will be called whenever somebody runs the main startup script under `src/analysis/00_setup.R`.
- Don't name a script `00_setup.R` unless you want it to be run by the main setup script.


## Working with NETCDF files

Raw data comes in the `NETCDF` file format which provides a lightweight, multidimensional data structure. The downside is you'll need to get used to it, especially when you're more used to working with two-dimensional csvs or traditional geojson/vector data.

Wihtin the `R` ecosystem, there are a couple packages that deal with `NETCDF` data. In my expericence, the `stars` package provides the most intuitive and powerful API. It was written by Edzer Pebesma, a spatial statistician based in Münster who also authored the ubiquitious `sf` package. A good introduction can be found in the book ["Spatial Data Science"](https://r-spatial.org/book/07-Introsf.html#package-stars). 




