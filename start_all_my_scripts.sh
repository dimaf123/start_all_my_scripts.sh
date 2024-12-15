#!/bin/bash
# python "/Users/supervisor/Google Drive/development/python/Smartshares/NZX_Market_info/nzx_market_info.py"
#  bash '/Users/supervisor/dev/scripts/start_all_my_scripts.sh'
# Check if Mysql Server is up and running

      echo $PATH

ServerIP=192.168.1.235                            # 235 Synology
ServerMAC=00:11:32:D4:BA:79                       # Lan 1
Back_Up_Folder='/Users/supervisor/Downloads/arh'
eval "$(pyenv init --path)"
who

echo ":--------------------"

w 

echo ":--------------------"


echo ": -- Checking Server $ServerIP "
if ping -c 1 $ServerIP &> /dev/null               # ping 1 time
then
  echo ": -- Server UP and Running"
                                                  # Server is on and running
                                                  # Nothing  to do
else   # no the server is Not OnLine
    echo ": -- Need to wake up the server"
    wakeonlan  $ServerMAC                          # Trying to wake up
    sleep 160                                      # wait some time to load
    if ping -c 1 $ServerIP &> /dev/null           # Trying againg
    then
        echo ": -- Server IP: $ServerIP Has been woke up"
    else                                          # Server did not wake up
                                                  # It has to be switch on
        echo -e "|\n|\n|\n|\n+-->  Could not wake up Server $ServerIP "
        echo $PATH
        echo "|\n+--> It has to be switch on manualy"
        exit 1                                   # terminate programm
                                                  # there is no reason to start any modules
    fi

fi
#  -------------   End of checking server ---------------------------------
echo ": -- Tickets Stats"
#  -------------   Information from NZX Main Board
python3 "/Users/supervisor/Google Drive/development/python/NZXmainBoard/nzx_main_board_2024.py" > $Back_Up_Folder/tickers_stats.txt
mysqlimport --defaults-extra-file=~/mylogin.cnf --replace --local --fields-terminated-by=, --fields-enclosed-by='"' TESTEEE $Back_Up_Folder/tickers_stats.txt > $Back_Up_Folder/temp.tmp

# +++ Refresh all Constant Tables like SmartShares, Dead Tickers, IRD exchange rates etc
# +++      !!!!!!!!!!!!!!!!!!            mysql   --defaults-extra-file=~/mylogin.cnf -s -r TESTEEE < "/Users/supervisor/Google Drive/development/SQL editor/sql_constants.sql"

# +++ Delete unnecessary records from tickers_stats
# +++ List of tickers in '/Users/supervisor/Google Drive/development/SQL editor/sql_constants.sql'
# mysql   --defaults-extra-file=~/mylogin.cnf  -B TESTEEE -e 'DELETE FROM `tickers_stats` WHERE `ticker` IN (SELECT `ticker` FROM `dead_tickers`);'
#
# UPD 2020-11-25
#
# Delete all tickers not in my list 
# Очень опасно !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# UPD 2023-04-21 и я попался!!!! если, вдруг, импорт tikers поломался, то удаляется все !!!!!!!!!!!!!!!!!!!!!!!!!
# mysql   --defaults-extra-file=~/mylogin.cnf  -B TESTEEE -e 'DELETE FROM  `tickers_stats` where `ticker` not in (select `ticker` from `tickers`);'




#  -----------------                Import tables from google sheets        -----------------------------------------------
echo ": -- Import Tables from Google"
env bash '/Users/supervisor/dev/scripts/import_from_google_to_mysql.sh'
# #  -----------------                Import from NZ Smartshares FNZ, MDZ, TNZ ----------------------------------------------
# echo ": -- Import FNZ from import_from_nzx in googledoc "
# env bash '/Users/supervisor/dev/scripts/export_FNZ.sh'
#  -----------------                Import upcoming dividend from NZX        -----------------------------------------------
echo ": -- import Dividends"
env bash '/Users/supervisor/dev/scripts/import_from_nzx_dvd.sh'


# Update tickers with current prices
mysql   --defaults-extra-file=~/mylogin.cnf  -B TESTEEE -e 'UPDATE `tickers` INNER JOIN `tickers_stats` ON `tickers`.`ticker` = `tickers_stats`.`ticker` and `tickers_stats`.`u_date` =  (Select max(u_date) from tickers_stats)  SET `tickers`.`price` = `tickers_stats`.`price`  WHERE `tickers`.`ticker` like "NZE:%";'

# Update NZ50C index
echo ": -- Update nz50c index from import_from_nzx google sheets"
#wget -O $Back_Up_Folder/nz50c.txt -o $Back_Up_Folder/wget_log   "https://docs.google.com/spreadsheets/d/e/2PACX-1vQPjKsG2FxU_OtTm24bk0YTL_j-kR_028VDxJtfweQs5OfQ48yKWJdY8-dg1zQN6X4irvu2LVqO4nBw/pub?gid=14062762&single=true&output=csv"
wget -O $Back_Up_Folder/nz50c.txt -o ~/wget_log   "https://docs.google.com/spreadsheets/d/e/2PACX-1vQPjKsG2FxU_OtTm24bk0YTL_j-kR_028VDxJtfweQs5OfQ48yKWJdY8-dg1zQN6X4irvu2LVqO4nBw/pub?gid=14062762&single=true&output=csv"
# Remove 0x0d from file ( \r )  https://stackoverflow.com/questions/21621722/removing-carriage-return-on-mac-os-x-using-sed
tr -d '\r' < $Back_Up_Folder/nz50c.txt >$Back_Up_Folder/nz50c.trt
#                                                                 UPD 2021-05-06 По каким-то причинам txt файл очищался. Проще всего показалось импортировать из trt 
# UPD 2021-05-06      mv $Back_Up_Folder/nz50c.trt $Back_Up_Folder/nz50c.txt
mysqlimport --defaults-extra-file=~/mylogin.cnf --replace --local --fields-terminated-by=, --fields-enclosed-by='"' TESTEEE $Back_Up_Folder/nz50c.trt #UPD 2021-05-06 was txt file  
echo ": -- Finished nz50c"
# Reports to screen
mysql   --defaults-extra-file=~/mylogin.cnf --line-numbers  --table TESTEEE < "/Users/supervisor/Google Drive/development/SQL editor/portfolio_by_sectors.sql"
echo "Wait a minute"
mysql   --defaults-extra-file=~/mylogin.cnf --line-numbers  --table TESTEEE < "/Users/supervisor/Google Drive/development/SQL editor/Perfomance_of_myIndex_and_FNZ.sql"
# BackUp Database

# ---------------------   Copy of mysql 192.168.1.235 to local host  ----------------------------------
echo ": -- BackUp TESTEEE"
BACK_UP_DB_FILE=$Back_Up_Folder"/$(date +%F)-TESTEEE_bak.sql"
mysqldump   --defaults-extra-file=~/mylogin.cnf  --column-statistics=0  TESTEEE > $BACK_UP_DB_FILE
mysql   --defaults-extra-file=~/mysql_localhost.cnf -e "DROP DATABASE TESTEEE;"
mysql   --defaults-extra-file=~/mysql_localhost.cnf -e "CREATE DATABASE TESTEEE;"
mysql   --defaults-extra-file=~/mysql_localhost.cnf  TESTEEE < $BACK_UP_DB_FILE
date
