# start_all_my_scripts.sh
собственно все мои скрипты for my investments arhive and dividends history 
### MySQL login
Current: main database on 235 synology server 




<strong>/Users/supervisor/Google Drive/development/python/NZXUpDvDjson_read_from_file.py</strong> - experiments with <strong><i>json & jmespath</strong></i> <br>
Knowledge derived from https://scrapfly.io/blog/parse-json-jmespath-python/ and https://python.land/data-processing/working-with-json/jmespath  <br>
It is good to remember: <strong><i>json.load()</strong></i> - loads json from file and <strong><i>json.loads()</strong></i> loads json from string. 
In scripts I use absolute path to files. <br> 

In both <strong><i>https://www.nzx.com/markets/NZSX/dividends</i></strong> and  <strong><i>https://www.nzx.com/markets/NZSX</strong></i> json data starts with a <strong><i><script id="__NEXT_DATA__" ..... > </strong></i> and consists of several blocks. In <strong><i>.../dividends</i></strong> they are <strong><i>{"marketInstruments":[{ ... }]</i></strong> is a dictionary for tickers ( name, ticker etc ) with <strong><i>isin</strong></i> as a key and <strong><i>"marketDividends":[{ ... {]</strong></i>  with the same  <strong><i>isin</strong></i> key. 


<h3> Dividends</h4>
Call: from <strong><i>start_all_my_scripts.sh</i></strong> -> <strong><i>import_from_nzx_dvd.sh</i></strong> -> <strong><i>NZX_dvd_new_2024.py</i></strong><br>
<strong><i>import_from_nzx_dvd.sh</i></strong> most likely for making calling DVD out of <strong><i>start_all_my_scripts.sh</i></strong>
 <h4>NZX_dvd_new_2024.py</h4> 
 
<strong><i>/Users/supervisor/Google Drive/development/python/NZX_dvd_new_2024.py</strong></i> - reads <i>https://www.nzx.com/markets/NZSX/dividends</i>, parses json data and print result as a comma separated text to a standard output. <br>

Bata block in <i>https://www.nzx.com/markets/NZSX/dividends</i> statrs with <strong><i><script id="__NEXT_DATA__" ..... > </strong></i> So, I get source from  <strong><i>[BeautifulSoup](https://www.nzx.com/markets/NZSX/dividends)</strong></i> ,using <strong><i>BeautifulSoup</strong></i> parses to  find <strong><i><script id="__NEXT_DATA__" ..... > </strong></i> , loads data via <strong><i>json.loads</strong></i> and print all data sometimes using <strong><i>jmespath.search</strong></i> do find shares ticker in  <strong><i>marketInstruments</strong></i> block of json data. 
Starting fro DVD 
