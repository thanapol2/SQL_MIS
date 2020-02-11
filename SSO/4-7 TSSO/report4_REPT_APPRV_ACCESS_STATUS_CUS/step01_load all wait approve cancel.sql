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
  region_id                    AS region_no,
  region_name,
  offcode AS off_id,
  offname AS off_name,
  APPV_CODE,
  APPV_DESC,
  'N' CUS_CNT_STATUS,
  CUS_CNT CUS_CNT,
  CUS_CNT/DECODE(SUM(CUS_CNT) OVER(PARTITION BY offcode),'0',100,SUM(CUS_CNT) OVER(PARTITION BY offcode))*100 AS CUS_STATUS_PERT,
  SYSDATE create_dtm,
  'RAW' create_user_id
FROM
  (SELECT all_region.offcode,
    all_region.offname,
    all_region.region_id,
    all_region.region_name,
    all_region.month_year,
    all_region.APPV_CODE,
    all_region.APPV_DESC,
    NVL(CUS_CNT,0) AS CUS_CNT
  FROM
    (SELECT r.offcode,
      r.offname,
      r.region_id,
      r.region_name,
      t.month_year,
      sc.id             AS APPV_CODE,
      sc.status_name_en AS APPV_DESC
    FROM mst_office r
    CROSS JOIN
      ( WITH t AS
      (SELECT DATE '2018-01-01' start_date,
        --                        add_months(trunc(SYSDATE),-4) start_date,
        SYSDATE end_date
      FROM dual
      )
    SELECT add_months(TRUNC(start_date, 'mm'), level - 1) month_year
    FROM t
      CONNECT BY TRUNC(end_date, 'mm') >= add_months(TRUNC(start_date, 'mm'), level - 1)
      ) t
    CROSS JOIN
      (SELECT * FROM mst_status_code
      ) sc
    ) all_region
  LEFT JOIN
    (SELECT '0'
      ||SUBSTR(COMPANY_DIST_CODE,1,5) offcode,
      REGISTER_STATUS_CODE,
      COUNT(*)CUS_CNT
    FROM TSSO_REGISTER
    GROUP BY COMPANY_DIST_CODE,
      REGISTER_STATUS_CODE
    )cal
  ON all_region.offcode             = cal.offcode
  AND TO_CHAR(all_region.APPV_CODE) = cal.REGISTER_STATUS_CODE
  )