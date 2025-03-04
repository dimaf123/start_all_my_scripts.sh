-- mysql   --defaults-extra-file=~/mylogin.cnf --line-numbers  --table TESTEEE < "/Users/supervisor/Google Drive/development/SQL editor/Perfomance_of_myIndex_and_FNZ.sql"
--                    3.4 По датам из tickers_stats  выводим  FNZ + FNZ cost
--                        !!!!!!! ---------------- Это работает
                        -- ---------------------- Результат какпильных прибылей-убытков
 --                        SET   @NZ50C_start="4704.28";
--                         SET   @NZ50C_start="4177.47";
                            SET   @NZ50C_start="5233.31";
                            SET @StartDate=SUBDATE(curdate(),235);
                            SELECT `dds`.`u_date` as `u_date`,
                              --   ROUND(sum(if(`dds`.`ticker` = "NZE:FNZ",`dds`.`holding`*`dds`.`price`,0)),0) as `FNZ_market`,
                                  ROUND(sum(if(`dds`.`ticker` = "NZE:FNZ",`dds`.`cost`,0)),0) as `FNZ_cost`,
                                  ROUND(sum(if(`dds`.`ticker` = "NZE:FNZ",`dds`.`holding`*`dds`.`price`,0))- sum(if(`dds`.`ticker` = "NZE:FNZ",`dds`.`cost`,0)),0)  as `FNZ_diff`,
                                  ROUND((sum(if(`dds`.`ticker` = "NZE:FNZ",`dds`.`holding`*`dds`.`price`,0))- sum(if(`dds`.`ticker` = "NZE:FNZ",`dds`.`cost`,0))) / sum(if(`dds`.`ticker` = "NZE:FNZ",`dds`.`cost`,0))*100,2) as `FNZ_pst`,
                                  COALESCE(ROUND((sum(if(`dds`.`ticker` = "NZE:FNZ",`dds`.`holding`*`dds`.`price`,0)) - sum(if(`dds`.`ticker` = "NZE:FNZ",`dds`.`cost`,0))) / sum(if(`dds`.`ticker` = "NZE:FNZ",`dds`.`cost`,0))*100 - (`nz50c`.`index` - @NZ50C_start)/@NZ50C_start*100,2)) as `FNZ_NZ50C`,
                              --   ROUND(sum(if(`dds`.`ticker` <> "NZE:FNZ",`dds`.`holding`*`dds`.`price`,0)),0) as `My_market`,
                                 ROUND(sum(if(`dds`.`ticker` <> "NZE:FNZ",`dds`.`cost`,0)),0) as `My_cost`,
                                 ROUND(sum(if(`dds`.`ticker` <> "NZE:FNZ",`dds`.`holding`*`dds`.`price`,0))- sum(if(`dds`.`ticker` <> "NZE:FNZ",`dds`.`cost`,0)),0)  as `My_diff`,
                                 ROUND((sum(if(`dds`.`ticker` <> "NZE:FNZ",`dds`.`holding`*`dds`.`price`,0))- sum(if(`dds`.`ticker` <> "NZE:FNZ",`dds`.`cost`,0))) / sum(if(`dds`.`ticker` <> "NZE:FNZ",`dds`.`cost`,0))*100,2) as `Mypst`,
                                 COALESCE(ROUND((sum(if(`dds`.`ticker` <> "NZE:FNZ",`dds`.`holding`*`dds`.`price`,0)) - sum(if(`dds`.`ticker` <> "NZE:FNZ",`dds`.`cost`,0))) / sum(if(`dds`.`ticker` <> "NZE:FNZ",`dds`.`cost`,0))*100 - (`nz50c`.`index` - @NZ50C_start)/@NZ50C_start*100,2)) as `My_NZ50C`,
                                 LPAD(COALESCE(`nz50c`.`index`,"---" ),7,"   ") as `nz50c`,
                                 COALESCE(ROUND((`nz50c`.`index` - @NZ50C_start)/@NZ50C_start*100,2),"---" ) as `pst50`,
                                 COALESCE(    ROUND((sum(if(`dds`.`ticker` <> "NZE:FNZ",`dds`.`holding`*`dds`.`price`,0))
                                                   - sum(if(`dds`.`ticker` <> "NZE:FNZ",`dds`.`cost`,0)))
                                                   / sum(if(`dds`.`ticker` <> "NZE:FNZ",`dds`.`cost`,0))*100
                                                   - (sum(if(`dds`.`ticker` = "NZE:FNZ",`dds`.`holding`*`dds`.`price`,0))
                                                   - sum(if(`dds`.`ticker` = "NZE:FNZ",`dds`.`cost`,0)))
                                                   / sum(if(`dds`.`ticker` = "NZE:FNZ",`dds`.`cost`,0))*100,2)) as `My_FNZ_pst`,
                                 ROUND(sum(`dds`.`holding`*`dds`.`price`),0 ) as `Total_Capital`

                                 -- COALESCE(ROUND((sum(`dds`.`holding`*`dds`.`price`) - sum(`dds`.`cost`)) / sum(`dds`.`cost`)*100 - (`nz50c`.`index` - @NZ50C_start)/@NZ50C_start*100,2)) as `diff`

                                   from  (
                                          SELECT `stat1`.`u_date` as `u_date`,
                                                 `stat1`.`ticker` as `ticker`,
                                                  coalesce((select sum(`transactions`.`quantity`)
                                                  from `transactions`
                                                  where `transactions`.`t_date` <= `stat1`.`u_date`
                                                      and
                                                      `transactions`.`ticker` = `stat1`.`ticker`),0) as `holding`,
                                                      `stat1`.`price` as `price` ,
                                                   coalesce((select sum(`transactions`.`quantity` * `transactions`.`price`+`transactions`.`brokerage`)
                                                      from `transactions`
                                                      where `transactions`.`t_date` <= `stat1`.`u_date`
                                                      and `transactions`.`ticker` = `stat1`.`ticker`),0) as `cost`
                                          from `tickers_stats` as stat1
                                          where stat1.u_date > @StartDate
                                          GROUP BY `stat1`.`u_date`, `stat1`.`ticker`
                                          ORDER BY `stat1`.`u_date`
                                      ) dds
                                  LEFT Join `nz50c` ON `dds`.`u_date` = `nz50c`.`u_date`
                                  where `dds`.`ticker` LIKE "NZE:%"   --  <> "NZE:FNZ"  -- and  holding > 0
                                  group by `dds`.`u_date`;
