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

Script `make_data_regular_timestamp_full.R` will convert the raw data and output a summarized dataset of turnstile numbers by day and by station along with the amount of turnstiles that were available in the raw dataset. The turnstile numbers are calculated between the *standard intervals* (assumed to be the regular reading time) The output will be available in the [processed_data](https://github.com/sho-ohata-ischool/NYC-MTA-Ridership/tree/master/data/processed) folder. Example output below. 

UNIT|DATE|INTERVAL|ENTRIES|EXITS|METER_COUNT
----|----|--------|-------|-----|-----------
R001|2017-06-17|21:00:00-01:00:00|1774|2388|40
R001|2017-06-17|01:00:00-05:00:00|288|522|40

Script `process_new.R` will find all the unprocessed raw data files and produce a processed file.
