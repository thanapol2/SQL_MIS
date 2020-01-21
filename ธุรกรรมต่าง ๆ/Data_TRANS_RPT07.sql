SELECT cur_core.caldr_year,
  cur_core.caldr_year-1                         AS CALDR_YEAR_PREVIOUS,
  TO_CHAR(to_date(cur_core.month_id,'mm'), 'Q') AS quater_id,
  'ไตรมาสที่ '
  || TO_CHAR(to_date(cur_core.month_id,'mm'), 'Q')AS quater_short_name,
  'ปี '
  || cur_core.caldr_year
  || ' ไตรมาสที่ '
  || TO_CHAR(to_date(cur_core.month_id,'mm'), 'Q')                  AS quater_long_name,
  TO_CHAR(to_date(cur_core.month_id,'mm'), 'MM')                    AS month_id,
  TO_CHAR(to_date(cur_core.month_id,'mm'), 'MON')                   AS month_short_name,
  TO_CHAR(to_date(cur_core.month_id,'mm'), 'MONTH')                 AS month_long_name,
  ''                                                                AS REGION_NO,
  ''                                                                AS REGION_NAME,
  cur_core.off_id                                                   AS off_id,
  ''                                                                AS off_name,
  cur_core.SERV_FORMAT_CODE                                            AS SERV_FORMAT_CODE,
  ''      AS SERV_FORMAT_DESC,
    cur_core.AMOUNT_TRANS_CNT                                         AS AMOUNT_TRANS_CNT,
    cur_core.AMOUNT_TRANS_CNT/cur_sum.SUM_AMOUNT_TRANS_CNT*100        AS AMOUNT_TRANS_CNT_PERT
  
FROM
  (SELECT caldr_year,
    month_id,
    off_id,
    SERV_FORMAT_CODE,
    COUNT(*) AMOUNT_TRANS_CNT
  FROM
    (SELECT 25
      ||SUBSTR(docctl_no,25,2) AS caldr_year,
      SUBSTR(docctl_no,27,2)   AS month_id,
      SUBSTR(docctl_no,18,6)   AS off_id,
      SUBSTR(docctl_no,31,1)   AS SERV_FORMAT_CODE,
      t.*
    FROM tcl_docctl t
    ) t
  GROUP BY caldr_year,
    month_id,
    off_id,
    SERV_FORMAT_CODE
  ) cur_core
INNER JOIN
  (SELECT caldr_year,
    month_id,
    off_id,
    COUNT(*) SUM_AMOUNT_TRANS_CNT
  FROM
    (SELECT 25
      ||SUBSTR(docctl_no,25,2) AS caldr_year,
      SUBSTR(docctl_no,27,2)   AS month_id,
      SUBSTR(docctl_no,18,6)   AS off_id,
      t.*
    FROM tcl_docctl t
    ) t
  GROUP BY caldr_year,
    month_id,
    off_id
  ) cur_sum
ON cur_core.caldr_year=cur_sum.caldr_year
AND cur_core.month_id =cur_sum.month_id
AND cur_core.off_id   =cur_sum.off_id;
