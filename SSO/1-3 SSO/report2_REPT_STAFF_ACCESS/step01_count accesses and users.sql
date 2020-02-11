SELECT ''                                        AS id,
    TO_CHAR(tran_date, 'yyyy') + 543               AS caldr_year,
  TRUNC(add_months(tran_date, 6516), 'yyyy')     AS start_date,
  TRUNC(add_months(tran_date, 6528), 'yyyy') - 1 AS end_date,
  TRUNC(SYSDATE) update_date,
  TO_CHAR(tran_date, 'Q') AS quater_id,
  'ไตรมาสที่ '
  || TO_CHAR(tran_date, 'Q') AS quater_short_name,
  'ปี '
  || TO_CHAR(TO_CHAR(tran_date, 'yyyy') + 543)
  || ' ไตรมาสที่ '
  || TO_CHAR(tran_date, 'Q')  AS quater_long_name,
  TO_CHAR(tran_date, 'MM')    AS month_id,
  TO_CHAR(tran_date, 'MON')   AS month_short_name,
  TO_CHAR(tran_date, 'MONTH') AS month_long_name,
  userid_cus_cnt,
  access_cus_cnt,
  SYSDATE AS create_dtm,
  'RAW'   AS create_user_id
FROM
  (SELECT weekly.tran_date,
    NVL(userid_cus_cnt, 0) AS userid_cus_cnt,
    NVL(access_cus_cnt, 0) AS access_cus_cnt
  FROM
    ( WITH t AS
    (SELECT TO_DATE('22/02/2015', 'dd/mm/yyyy') start_date,            -- start sunday
      NEXT_DAY(TO_DATE('22/02/2015', 'dd/mm/yyyy'),'SATURDAY')end_date -- to saturday
    FROM dual
    )
  SELECT TRUNC(start_date) + level - 1 AS tran_date
  FROM t
    CONNECT BY TRUNC(end_date) >= TRUNC(start_date) + level - 1
    ) weekly
  LEFT JOIN
    (SELECT user_a.tran_date,
      COUNT(userid) AS userid_cus_cnt
    FROM
      ( SELECT DISTINCT TRUNC(to_date(TRAN_DATE,'mm/dd/yyyy')) tran_date,
        userid
      FROM sso_tran_log
      WHERE TRUNC(to_date(TRAN_DATE,'mm/dd/yyyy'), 'dd') BETWEEN TO_DATE('22/02/2015', 'dd/mm/yyyy') AND NEXT_DAY(TO_DATE('22/02/2015', 'dd/mm/yyyy'),'SATURDAY' )
      ) user_a
    GROUP BY user_a.tran_date
    ) userid
  ON weekly.tran_date = userid.tran_date
  LEFT JOIN
    (SELECT TRUNC(to_date(TRAN_DATE,'mm/dd/yyyy')) tran_date,
      COUNT(*) AS access_cus_cnt
    FROM sso_tran_log
    WHERE TRUNC(to_date(TRAN_DATE,'mm/dd/yyyy'), 'dd') BETWEEN TO_DATE('22/02/2015', 'dd/mm/yyyy') AND NEXT_DAY(TO_DATE('22/02/2015', 'dd/mm/yyyy'),'SATURDAY' )
    GROUP BY tran_date
    ) access_a
  ON weekly.tran_date = access_a.tran_date
  );