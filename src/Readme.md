Script `get_raw_data.py` will download files from the [MTA website](http://web.mta.info/developers/turnstile.html).

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
