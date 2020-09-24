# reddit-viz
Subreddit visualization tool using R Shiny

Hello, thanks for your interest in my visualization tool. To use this tool, please make sure you have installed the following packages in R:
1) shiny
2) ggplot2
3) dplyr
4) tidyr
5) lubridate
6) reticulate

The R file (app.R) will be used to download a virtual Python environment (using python3) and create an R Shiny app for the user to specify inputs and return charts of aggregated user activity from a desired subreddit.
The Python file (pull_data_generic.py) will be used to interface with the reddit and pushshift APIs to download data from a user-specified subreddit over a user-specified period of time (both specified using the R Shiny app).
* Please note that the app works best for small to medium-sized subreddits due to Reddit API request limits. The app will work for larger subreddits but it might take awhile to download the data.
* Please keep the two files (app.R and pull_data_generic.py in the same folder and set this folder as the directory for the app in R.
* Please note that the user will need to edit the Python file to input their own credentials for scraping from the reddit API. I would recommend following the information from this blog on how to get started: https://www.storybench.org/how-to-scrape-reddit-with-python/
* Also please note that the package reticulate is not currently supported for published R Shiny apps so the app will only work in a local environment.
