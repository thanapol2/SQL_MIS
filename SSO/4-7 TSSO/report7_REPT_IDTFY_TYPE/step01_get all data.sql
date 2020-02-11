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
  SIGNING_STATUS_IND,
  SIGNING_STATUS_IND,
  DIGIT_SIGN_TYPE,
  USERID_CUS_CNT,
  USERID_CUS_CNT_PERT,
  SYSDATE AS create_dtm,
  'RAW'   AS create_user_id
FROM
  (SELECT t.month_year,
    SIGNING_STATUS_IND,
    '' AS DIGIT_SIGN_TYPE,
    USERID_CUS_CNT,
    USERID_CUS_CNT/DECODE(SUM(USERID_CUS_CNT) OVER(PARTITION BY t.month_year),'0',100,SUM(USERID_CUS_CNT) OVER(PARTITION BY t.month_year))*100 AS USERID_CUS_CNT_PERT
  FROM
    ( WITH t AS
    (SELECT DATE '2018-08-01' start_date,
      --                        add_months(trunc(SYSDATE),-4) start_date,
      DATE '2018-10-01' end_date
    FROM dual
    )
  SELECT add_months(TRUNC(start_date, 'mm'), level - 1) month_year
  FROM t
    CONNECT BY TRUNC(end_date, 'mm') >= add_months(TRUNC(start_date, 'mm'), level - 1)
    ) t
    --  cross join mst_DIGIT_SIGN_TYPE
  LEFT JOIN
    (SELECT month_year,
      SIGNING_STATUS_IND,
      COUNT(*) AS USERID_CUS_CNT
    FROM
      (SELECT TRUNC(to_date(SUBMIT_DTM,'yyyymmdd'),'mon') month_year,
        SIGNING_STATUS_IND
      FROM TSSO_FORM01
      )
    GROUP BY month_year,
      SIGNING_STATUS_IND
    ) cal
  ON t.month_year = cal.month_year
  )