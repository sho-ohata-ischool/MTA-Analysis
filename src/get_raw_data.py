import requests
from bs4 import BeautifulSoup
import re
import shutil
import os
import argparse
from argparse import RawTextHelpFormatter
from datetime import datetime
import sys

dl_dir = (os.path.join(os.getcwd(), os.pardir, 'data' , 'raw_data'))
site_base = 'http://web.mta.info/developers/turnstile.html' #main website that lists all available files
site_base_dl = r"http://web.mta.info/developers/data/nyct/turnstile/" ## url to be appended to download the data

def MTA_file_list():
	page = requests.get(site_base)

	soup = BeautifulSoup(page.content, 'html.parser')
	files = soup.find_all('a', href=True) ## scrape all href
	r = re.compile("(?=.*data)(?=.*turnstile)(?=.*txt)") ## initialize regex to identify text file names
	download_list_full = [re.search('turnstile_(.*?)txt', str(x)).group(0) for x in files if r.match(str(x))] ## compile list
	file_list = os.listdir(dl_dir) ## check which files have already been downloaded
	download_list = [x for x in download_list_full if x not in file_list] ## remove file names that have already been downloaded
	return download_list

if __name__ == '__main__':
	## Command line inputs arguments
	description = 'Downloads MTA raw text file from http://web.mta.info/developers/turnstile.html\n\
	No arguments passed will download everything\n\
	Start Date = Optional. Script with only Start Date argument will download everything from the start date\n\
	End Date = Optional. Script with only End Date argument will download everything up to the end date'
	parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter, description=description)

	parser.add_argument('--start', required=False, help='start date in format mmddYYYY')
	parser.add_argument('--end', required=False, help='end date in format mmddYYYY')

	args = parser.parse_args()

	download_list = MTA_file_list()

	if args.start is not None and args.end is not None:
		download_list = [x for x in download_list if datetime.strptime(x[10:16], "%y%m%d") < datetime.strptime(args.end,'%m%d%Y')]
		download_list = [x for x in download_list if datetime.strptime(x[10:16], "%y%m%d") > datetime.strptime(args.start,'%m%d%Y')]
	elif args.start is not None and args.end is None:
		download_list = [x for x in download_list if datetime.strptime(x[10:16], "%y%m%d") > datetime.strptime(args.start,'%m%d%Y')]
	elif args.start is None and args.start is not None:
		download_list = [x for x in download_list if datetime.strptime(x[10:16], "%y%m%d") < datetime.strptime(args.end,'%m%d%Y')]
	else:
		next

	for file_name in download_list:

	    session = requests.Session()

	    url = site_base_dl + file_name
	    r = session.get(url,stream=True)

	    if r.status_code == 200:
	        with open(os.path.join(dl_dir,file_name), 'wb') as f:
	            r.raw.decode_content = True
	            shutil.copyfileobj(r.raw, f)
	            print('Downloaded file: %s' %file_name)
