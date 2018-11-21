SELECT de.month_year,    
  de.dept_id   AS region_no,
  md.dept_name AS region_name, 
  de.off_id, 
  'none'    AS off_name,
  de.ca_status AS cert_status_cd,
  cs.cert_status, 
  cr.CERT_REASON_STATUS_CD,
  de.cancel_cause AS CERT_REASON_STATUS, 
  'N' CERT_CNT_STATUS,                   
  de.CERT_CNT,                           
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
ON de.dept_id = md.dept_id
inner join cert_status cs
on de.ca_status = cs.CERT_STATUS_CD
inner join CErt_reason_status cr
on de.cancel_cause = cr.CERT_REASON_STATUS;