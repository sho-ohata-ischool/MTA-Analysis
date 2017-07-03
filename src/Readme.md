# Data Processing Scripts

Script `get_raw_data.py` will download files from the [MTA website](http://web.mta.info/developers/turnstile.html). The output will be available in the folder [raw_data](https://github.com/sho-ohata-ischool/NYC-MTA-Ridership/tree/master/data/raw_data).

`usage: get_raw_data.py [-h] [--start START] [--end END]`

Downloads MTA raw text file from http://web.mta.info/developers/turnstile.html
No arguments passed will download everything.
Argument with only Start Date argument will download everything from the start date.
Argument with only End Date argument will download everything up to the end date.
Arguments with both start and end date will download everything in between.

`optional arguments:
  -h, --help     show this help message and exit
  --start START  start date in format mmddYYYY
  --end END      end date in format mmddYYYY
`

Script `make_data.R` will convert the raw data and output a summarized dataset of *morning hours* turnstile numbers by day and by station along with the amount of turnstiles that were available in the raw dataset. The output will be available in the [processed_data](https://github.com/sho-ohata-ischool/NYC-MTA-Ridership/tree/master/data/processed) folder.

Update below line to select interested stations in the `make_data.R` script.

`station_names <- c("R249", "R250", "R265", "R377")`
