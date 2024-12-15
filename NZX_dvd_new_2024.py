# python3 "/Users/supervisor/Google Drive/development/python/NZXUpDvD/NZX_dvd_new_2024.py"
# To Replace  google doc import
# Get data from https://www.nzx.com/markets/NZSX/dividends
# Save as csv
# Table class "table-to-list"
# <thread> - no class
# <tr> no class
# <th>'s "Code","Ex Dividend","Period","Amount","Supp.","Imputation","Payable","Currency"
# <tbody> .....

# UPD 2024-04-15
# removed  new_record field from ex_dvd 
# Add upd_date to ex_dvd
# today to
#
# 2024-12-15 
# __NEXT_DATA__ - start of json data 
#
# Get data from https://www.nzx.com/markets/NZSX/dividends
#
# 

import sys
import os
import requests
import re             # regular expression   ^\$\d+\.\d+
import logging        #  Logs to the file
import time           # Time\date
from bs4 import BeautifulSoup
import json
import jmespath
from datetime import datetime

today = time.strftime("%Y-%m-%d")                                               # Today is today

dividends_URL = "https://www.nzx.com/markets/NZSX/dividends"                    #


my_log = "/Users/supervisor/log.txt"                                            # Log
logging.basicConfig(filename='/Users/supervisor/log.txt',level=logging.ERROR)  # No idea

r=requests.get(dividends_URL)       # Read the HTML page


print(r.status_code)
if r.status_code != 200 :            # Request was not succesful ( return code <> 200)
    logging.error(" : "+today+" : "+__file__+  ': \n     Error in HTML request. Code returned : '+str(r.status_code))
    raise Exception(" : "+today+" : "+__file__+': \n     Error in HTML request. Code returned : '+str(r.status_code))   # Finish the programm
pagetext=r.text
parsed = BeautifulSoup(pagetext, 'lxml')
try:
    script_data = parsed.find("script", {"id" : "__NEXT_DATA__"})                      # Looking for jason data
    if script_data is None :                                                           # Exeption if did not find data
        logging.error(" : "+today+" : "+__file__+  ': \n     Did not found Script id: __NEXT_DATA__ in '+table_URL)
        raise Exception(" : "+today+" : "+__file__+  ': \n     Did not found Script id: __NEXT_DATA__ in '+table_URL)   # Finish the programm
    # Starting to parse the table abs
    # Check Header
    data = json.loads(script_data.text)
#    print(data)
    for x in data['props']['pageProps']['data']['marketDividends']: #       ["marketDividends"]:    marketDividends
        print( "NZE:"+jmespath.search("props.pageProps.data.marketInstruments[?isin == '"+x['isin']+"'].code",data)[0],datetime.fromtimestamp(int(x['expectedDate'])).strftime('%Y-%m-%d'),round(float(x['amount'])/100,7)  , datetime.fromtimestamp(int(x['payableDate'])).strftime('%Y-%m-%d'), x['type'], x['supplementaryAmount'], x['imputationCreditAmount']  ,  x['currencyCode'], datetime.today().strftime('%Y-%m-%d'),sep=',')


except AttributeError as e:
    logging.error(" : "+today+" : "+__file__+  ': \n      Something happened in Try  ')
    raise Exception(" : "+today+" : "+__file__+  ': \n     Something happened in Try  ')   # Finish the programm

# from here we are going to python3 "/Users/supervisor/Google Drive/development/python/NZXUpDvD/json_read_from_file.py"
# just to minimize NZX requests 

