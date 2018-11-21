BEGIN
  FOR r IN
  ( WITH t AS
  ( SELECT DATE '2018-01-01' start_date, SYSDATE end_date FROM dual
  )
SELECT add_months(TRUNC(start_date, 'mm'), level - 1) month_year
FROM t
  CONNECT BY TRUNC(end_date, 'mm') >= add_months(TRUNC(start_date, 'mm'), level - 1)
  )
  LOOP
  INSERT INTO temp_r2 (
            month_year,
            region_no,
            region_name,
            off_id,
            off_name,
            CERT_STATUS_CD, 
	CERT_STATUS, 
	CERT_REASON_STATUS_CD, 
	CERT_REASON_STATUS, 
	CERT_CNT_STATUS, 
	CERT_CNT, 
	CERT_PERT, 
	CREATE_DTME)
  
  END LOOP;
END;

SELECT *
FROM
  (SELECT region_no,
    off_id,
    CERT_STATUS_CD,
    CERT_REASON_STATUS_CD,
    'A' reqt_cnt_status,
    SUM(CERT_CNT) CERT_CNT,
    NULL CERT_pert
  FROM temp_r2 tr
  WHERE tr.month_year   <= to_date('01/11/2018','dd/mm/yyyy')
  AND tr.CERT_CNT_STATUS = 'N'
  GROUP BY region_no,
    off_id,
    CERT_STATUS_CD,
    CERT_REASON_STATUS_CD
  ) cal
INNER JOIN mst_dept md
ON cal.region_no = md.dept_id
inner join cert_status cs
on cal.CERT_STATUS_CD = cs.CERT_STATUS_CD
inner join CErt_reason_status cr
on cal.CERT_REASON_STATUS_CD = cr.CERT_REASON_STATUS_CD
CROSS JOIN
  ( SELECT to_date('01/11/2018','dd/mm/yyyy') month_year FROM dual
  ) mn;