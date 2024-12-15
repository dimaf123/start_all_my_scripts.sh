#!/bin/bash
# Import upcoming dividends from https://www.nzx.com/markets/NZSX/dividends VIA
# https://docs.google.com/spreadsheets/d/12dGQzRdKFJwAIVcM9fl3jxkKcUPyouoKkRErQlC8oAM/edit#gid=1646170397
#

echo ": -- import_from_nzx_dvd.sh"
echo ": -- python /Users/supervisor/Google Drive/development/python/NZXUpDvD/NZX_dvd.py"
Back_Up_Folder='/Users/supervisor/Downloads/arh'


python3 "/Users/supervisor/Google Drive/development/python/NZXUpDvD/NZX_dvd_new_2024.py" > $Back_Up_Folder/ex_dvd.txt



header="Code,Ex Dividend,Amount,Payable,Period,Supp.,Imputation,Currency,NewRecord"

#if grep -q "$header" ~/ex_dvd.txt   # check if we've got the same header
#then
    mysqlimport --defaults-extra-file=~/mylogin.cnf --local --fields-terminated-by=, --fields-enclosed-by='"' --lines-terminated-by="\n"  --ignore TESTEEE $Back_Up_Folder/ex_dvd.txt  # > $Back_Up_Folder/mysqlimport.log
   echo '<html> <head><style>table, td, th {border: 1px solid #ddd; text-align: left;} table {border-collapse: collapse; width: 80%;} th {text-align: center; padding: 6px;} '\
        ' td {padding: 6px; } td.column_0 { text-align: right; width: 10%;} td.column_1 { text-align: right; width: 10%;} td.column_4 { text-align: right;width: 14%;} td.column_5 { text-align: right; width: 14%;} </style></head><body><pre style="font: monospace">' > $Back_Up_Folder/~tmp.tmp   # html header
   echo script:  $0 $'\n'csv file:   $Back_Up_Folder/ex_dvd.txt $'\n' >> $Back_Up_Folder/~tmp.tmp
   mysql   --defaults-extra-file=~/mylogin.cnf  TESTEEE -t --html  -e 'SELECT pay_date as `Pay  Date`,ex_date as `Ex dividend`,RIGHT(ticker,6) as `ticker` ,c_name,total_dvd,amount from v_ex_dvd where holding > 0;' | ~/columnHTML >> $Back_Up_Folder/~tmp.tmp

   echo '<br> <br>' >> $Back_Up_Folder/~tmp.tmp
   mysql   --defaults-extra-file=~/mylogin.cnf  TESTEEE -t --html -e 'SELECT sum(total_dvd) as total  from v_ex_dvd where holding > 0;' >> $Back_Up_Folder/~tmp.tmp
   if ! grep -q "<TD>NULL</TD>" $Back_Up_Folder/~tmp.tmp; then
             # Next two lines because max line in SMTP is 900 symbols or something like that 
             sed  's/<TR>/\'$'\n/g' $Back_Up_Folder/~tmp.tmp > $Back_Up_Folder/~tmptr.tmp
              mv $Back_Up_Folder/~tmptr.tmp $Back_Up_Folder/~tmp.tmp
       cat  $Back_Up_Folder/~tmp.tmp | mail -s "$(echo -e "Upcuming Dividends ( from NZX.com )\nContent-Type: text/html")"  filimonchik@gmail.com
    fi


#else
#   echo "header of csv file does not fit"
#    # header of csv file does not fit
#    # sending error message to filimonchik
#    echo '<html><body><pre style="font: monospace">' > ~/~tmp.tmp   # html header
#    echo Error during import upcoming dividends from NZX $'\n'The header $'\n'$header  $'\n'does not fit $'\n'script:  $0 $'\n'csv file:   ~/ex_dvd.txt $'\n' >> ~/~tmp.tmp
#    column -s, -t < ~/ex_dvd.txt >> ~/~tmp.tmp         # Add source file
#    cat  ~/~tmp.tmp | mail -s "$(echo -e "Error during import upcoming divdends from nzx.com\nContent-Type: text/html")"  filimonchik@gmail.com
#rm ~/~tmp.tmp
#  fi
#rm ~/~tmp.tmp
