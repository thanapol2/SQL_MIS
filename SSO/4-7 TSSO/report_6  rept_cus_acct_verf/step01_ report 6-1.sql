SELECT ''                                         AS id,
    TO_CHAR(month_year, 'yyyy') + 543               AS caldr_year,
  TRUNC(add_months(month_year, 6516), 'yyyy')     AS start_date,
  TRUNC(add_months(month_year, 6528), 'yyyy') - 1 AS end_date,
  TRUNC(SYSDATE) update_date,
  TO_CHAR(month_year, 'Q') AS quater_id,
  'ไตรมาสที่ '
  || TO_CHAR(month_year, 'Q') AS quater_short_name,
  'ปี '
  || TO_CHAR(TO_CHAR(month_year, 'yyyy') + 543)
  || ' ไตรมาสที่ '
  || TO_CHAR(month_year, 'Q')  AS quater_long_name,
  TO_CHAR(month_year, 'MM')    AS month_id,
  TO_CHAR(month_year, 'MON')   AS month_short_name,
  TO_CHAR(month_year, 'MONTH') AS month_long_name,
  ACCT_VERF_STATUS_ID,
  '' as ACCT_VERF_STATUS,
  USERID_CUS_CNT,
  USERID_CUS_CNT_PERT,
  SYSDATE create_dtm,
  'RAW' create_user_id
FROM(
SELECT month_year,
  ACCT_VERF_STATUS_ID,
  USERID_CUS_CNT,
  USERID_CUS_CNT/DECODE(SUM(USERID_CUS_CNT) OVER(PARTITION BY month_year),'0',100,SUM(USERID_CUS_CNT) OVER(PARTITION BY month_year))*100 as USERID_CUS_CNT_PERT
FROM
  ( WITH t AS
  (SELECT sysdate start_date,
    --                        add_months(trunc(SYSDATE),-4) start_date,
    sysdate end_date
  FROM dual
  ) -- current month
SELECT add_months(TRUNC(start_date, 'mm'), level - 1) month_year
FROM t
  CONNECT BY TRUNC(end_date, 'mm') >= add_months(TRUNC(start_date, 'mm'), level - 1)
  ) monthly
CROSS JOIN
-- MST_ACCT_VERF_STATUS cross join
  (SELECT ACTIVATE_STATUS_CODE AS ACCT_VERF_STATUS_ID,
    COUNT(*)                   AS USERID_CUS_CNT
  FROM tsso_user
  GROUP BY ACTIVATE_STATUS_CODE
  ) cal);