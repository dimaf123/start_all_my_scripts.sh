-- mysql   --defaults-extra-file=~/mylogin.cnf --line-numbers  --table TESTEEE < "/Users/supervisor/Google Drive/development/SQL editor/portfolio_by_sectors.sql"
--     *  Нахрена нам здесь holding ?
--     *  я вроде не собираюсь считать акции
--     *  Cost тоже абсолютно не зачем
--     *  Единственно, для чего я делаю эту форму, это посмотреть
--     *  распределение по отраслям
--     Last date in statistic
  SELECT  @ForDate := max(`tickers_stats`.`u_date`) as `For Date` from `tickers_stats`;

\! echo "I like to party...";

  --  * сначала находим общую цену портфолио в тенах на последнюю дату

  SELECT @TotalMarket :=  sum(`sec`.`market`) as `total_maket`
   from
   (   select sum(`transactions`.`quantity` * `tickers_stats`.`price`) as `market`
         from `transactions`
         LEFT JOIN `tickers_stats` on `tickers_stats`.`ticker` = `transactions`.`ticker`
         where `transactions`.`ticker` <> "NZE:FNZ" AND `transactions`.`ticker` LIKE "NZE:%"   AND `transactions`.`s_date` <= @ForDate AND `tickers_stats`.`u_date` = @ForDate
    ) `sec` ;

--    list of shares вместе с процентным содержанием
  SELECT
          `NZE_port`.`ticker` as ` ticker `,
          LPAD(FORMAT(`NZE_port`.`price`,2),7,"  ") as `price`,
          LEFT(`NZE_port`.`sector`,15) as `sector`,
          LPAD(FORMAT(`NZE_port`.`market`,0),10,"  ") as `market`,
          LPAD(FORMAT(`NZE_port`.`market`/ @TotalMarket * 100,2),8,"  ") as 'comp %'
  From
  (
  select `transactions`.`ticker` as `ticker`,
         `tickers_stats`.`price` as `price`,
         `tickers`.`sector`,
      sum(`transactions`.`quantity`) as `holding`,
      sum(`transactions`.`quantity` * `transactions`.`price` + `transactions`.`brokerage`) as `cost`,
      sum(`transactions`.`quantity` * `tickers_stats`.`price`) as `market`
      from `transactions`
      left JOIN `tickers` on `tickers`.`ticker` = `transactions`.`ticker`
      LEFT JOIN `tickers_stats` on `tickers_stats`.`ticker` = `transactions`.`ticker`
      where  `transactions`.`ticker` <> "NZE:FNZ" AND `transactions`.`ticker` LIKE "NZE:%"   AND `transactions`.`s_date` <= @ForDate AND `tickers_stats`.`u_date` = @ForDate
      group by `transactions`.`ticker`  HAVING holding > 0
    ) `NZE_port`
    ORDER by `NZE_port`.`sector`,`NZE_port`.`ticker`;


--      ORDER BY Size in Portfolio

SELECT @TotalMarket :=  sum(`sec`.`market`) as `total_maket`
 from
 (   select sum(`transactions`.`quantity` * `tickers_stats`.`price`) as `market`
       from `transactions`
       LEFT JOIN `tickers_stats` on `tickers_stats`.`ticker` = `transactions`.`ticker`
       where `transactions`.`ticker` <> "NZE:FNZ" AND `transactions`.`ticker` LIKE "NZE:%"   AND `transactions`.`s_date` <= @ForDate AND `tickers_stats`.`u_date` = @ForDate
  ) `sec` ;

--    list of shares вместе с процентным содержанием
SELECT
        `NZE_port`.`ticker` as ` ticker `,
        `NZE_port`.`holding` as 'holding',
        LPAD(FORMAT(`NZE_port`.`price`,2),7,"  ") as `price`,
        LEFT(`NZE_port`.`sector`,15) as `sector`,
        LPAD(FORMAT(`NZE_port`.`market`,0),10,"  ") as `market`,
        LPAD(FORMAT(`NZE_port`.`market`/ @TotalMarket * 100,2),8,"  ") as 'comp %',
        LPAD(FORMAT(`NZE_port`.`capital`,0),15,"  ") as `capital`,
        LPAD(FORMAT(`NZE_port`.`market`/ `NZE_port`.`capital` * 100000,6),8,"  ") as 'capital %/1000'

From
(
select `transactions`.`ticker` as `ticker`,
       `tickers_stats`.`price` as `price`,
       `tickers`.`sector`,
    sum(`transactions`.`quantity`) as `holding`,
    sum(`transactions`.`quantity` * `transactions`.`price` + `transactions`.`brokerage`) as `cost`,
    sum(`transactions`.`quantity` * `tickers_stats`.`price`) as `market`,
    `tickers_stats`.`capital` as `capital`

    from `transactions`
    left JOIN `tickers` on `tickers`.`ticker` = `transactions`.`ticker`
    LEFT JOIN `tickers_stats` on `tickers_stats`.`ticker` = `transactions`.`ticker`
    where  `transactions`.`ticker` <> "NZE:FNZ" AND `transactions`.`ticker` LIKE "NZE:%"   AND `transactions`.`s_date` <= @ForDate AND `tickers_stats`.`u_date` = @ForDate
    group by `transactions`.`ticker`  HAVING holding > 0
  ) `NZE_port`
  ORDER by `NZE_port`.`market` DESC;





--                          3.3.1   GROUP by sectors

--                        SET @ForDate=select max(`tickers_stats`.`u_date`) from `tickers_stats`;

      --  * Затем выводим список секторов с процентным содержанием в нашем портфолио
      --  *


       SELECT `sec`.`sector`,
              LPAD(FORMAT(`sec`.`market`,0),10,"  ") as `market`,
              LPAD(FORMAT(`sec`.`market`/@TotalMarket*100,2),8,"  ") as `comp %`
              from
               (   select
                     `tickers`.`sector`,
                     sum(`transactions`.`quantity` * `tickers_stats`.`price`) as `market`
                     from `transactions`
                     left JOIN `tickers` on `tickers`.`ticker` = `transactions`.`ticker`
                     LEFT JOIN `tickers_stats` on `tickers_stats`.`ticker` = `transactions`.`ticker`
                     where `transactions`.`ticker` <> "NZE:FNZ" AND `transactions`.`ticker` LIKE "NZE:%"   AND `transactions`.`s_date` <= @ForDate AND `tickers_stats`.`u_date` = @ForDate
                     GROUP BY `tickers`.`sector`
                ) `sec`
              WHERE `sec`.`market` > 0
              order by `sec`.`sector`
         ;
