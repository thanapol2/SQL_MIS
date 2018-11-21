SELECT de.month_year,     --
  de.dept_id   AS region_no,--
  md.dept_name AS region_name, --
  de.off_id, --
  'none'    AS off_name,
  'none'    AS status_code,
  ca_status AS cert_status_cd,
  de.ca_status, --
  CERT_REASON_STATUS_CD,
  de.cancel_cause AS CERT_REASON_STATUS, --
  'N' CERT_CNT_STATUS,                   --
  de.CERT_CNT,                           --
  0       AS CERT_PERT,
  sysdate AS CREATE_DTM,
  'ETL'   AS CREATE_USER_ID
FROM
  (SELECT TRUNC(th.created_date, 'mon') month_year,
    th.ca_status,
    th.cancel_cause,
    au.dept_id,
    au.off_id,
    COUNT(*) CERT_CNT
  FROM token_hist th
  INNER JOIN app_user au
  ON th.username = au.username
  GROUP BY th.ca_status,
    th.cancel_cause,
    TRUNC(th.created_date, 'mon'),
    au.dept_id,
    au.off_id
  ) de
INNER JOIN mst_dept md
ON de.dept_id = md.dept_id;