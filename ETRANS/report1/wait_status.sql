SELECT de.month_year,
  de.dept_id as region_no,
  md.dept_name as region_name,
  de.off_id,
  'none' off_name,
  'none' status_code,
  'WAIT' AS status_desc,
  'N' reqt_cnt_status,
  REQT_CNT,
  REQT_CNT * 100 / reqt_all reqt_pert
FROM
  (SELECT month_year,
    tr.dept_id,
    tr.off_id,
    COUNT(*) REQT_CNT
  FROM
    (SELECT TRUNC(created_date, 'mon') month_year,
      dept_id,
      off_id
    FROM token_request
        where  status in ('WAIT','REQUEST')
    ) tr
  GROUP BY month_year,
    dept_id,
    off_id
  ) de -- wait/request/approve/cancel
  inner join (SELECT month_year,
    tr.dept_id,
    tr.off_id,
    COUNT(*) REQT_ALL
  FROM
    (SELECT TRUNC(created_date, 'mon') month_year,
      dept_id,
      off_id
    FROM token_request
    ) tr
  GROUP BY month_year,
    dept_id,
    off_id -- all doc
  )al 
  on de.month_year = al.month_year
  and de.dept_id = al.dept_id
  and de.off_id = al.off_id
INNER JOIN mst_dept md
ON de.dept_id = md.dept_id;

-- sum offid 99 with yearly
SELECT de.month_year,
  de.dept_id as region_no,
  md.dept_name as region_name,
  de.off_id
  || 99 off_id,
  'รวม '
  ||'สท. พื้นที่' off_name,
  'none' status_code,
  'WAIT' AS status_desc,
  'N' reqt_cnt_status,
  REQT_CNT,
  REQT_CNT * 100 / reqt_all reqt_pert
FROM
  (SELECT month_year,
    tr.dept_id,
    tr.off_id,
    COUNT(*) REQT_CNT
  FROM
    (SELECT TRUNC(created_date, 'year') month_year,
      dept_id,
      off_id
    FROM token_request
        where  status in ('WAIT','REQUEST')
    ) tr
  GROUP BY month_year,
    dept_id,
    off_id
  ) de -- wait/request/approve/cancel
  inner join (SELECT month_year,
    tr.dept_id,
    tr.off_id,
    COUNT(*) REQT_ALL
  FROM
    (SELECT TRUNC(created_date, 'year') month_year,
      dept_id,
      off_id
    FROM token_request
    ) tr
  GROUP BY month_year,
    dept_id,
    off_id -- all doc
  )al 
  on de.month_year = al.month_year
  and de.dept_id = al.dept_id
  and de.off_id = al.off_id
INNER JOIN mst_dept md
ON de.dept_id = md.dept_id;

-- depart sum office 999999 by month
SELECT
    de.month_year,
    de.dept_id as region_no,
    md.dept_name as region_name,
    '999999' off_id,
    'รวมสรรพสามิตพื้นที่ ภาคที่ '|| de.dept_id off_name,
    'none' status_code,
    'WAIT' AS status_desc,
    'N' reqt_cnt_status,
    reqt_CNT,
    reqt_CNT * 100 / reqt_all reqt_pert
FROM
  (SELECT month_year,
    tr.dept_id,
    COUNT(*) REQT_CNT
  FROM
    (SELECT TRUNC(created_date, 'mon') month_year,
      dept_id
    FROM token_request
        where  status in ('WAIT','REQUEST')
    ) tr
  GROUP BY month_year,
    dept_id
  ) de -- wait/request/approve/cancel
  inner join (SELECT month_year,
    tr.dept_id,
    COUNT(*) REQT_ALL
  FROM
    (SELECT TRUNC(created_date, 'mon') month_year,
      dept_id
    FROM token_request
    ) tr
  GROUP BY month_year,
    dept_id-- all doc
  )al 
  on de.month_year = al.month_year
  and de.dept_id = al.dept_id
    INNER JOIN mst_dept md ON de.dept_id = md.dept_id;
    
-- sum all
SELECT
    de.month_year,
    '99' region_no,
    'ทั่วประเทศ' region_name,
    '999999' off_id,
    'ทั่วประเทศ' off_name,
    'none' status_code,
    'WAIT'   AS status_desc,
    'N' reqt_cnt_status,
    reqt_CNT,
    reqt_CNT * 100 / reqt_all reqt_pert
FROM
  (SELECT month_year,
    tr.dept_id,
    COUNT(*) REQT_CNT
  FROM
    (SELECT TRUNC(created_date, 'year') month_year,
      dept_id
    FROM token_request
        where  status in ('WAIT','REQUEST')
    ) tr
  GROUP BY month_year,
    dept_id
  ) de -- wait/request/approve/cancel
  inner join (SELECT month_year,
    tr.dept_id,
    COUNT(*) REQT_ALL
  FROM
    (SELECT TRUNC(created_date, 'year') month_year,
      dept_id
    FROM token_request
    ) tr
  GROUP BY month_year,
    dept_id-- all doc
  )al 
  on de.month_year = al.month_year
  and de.dept_id = al.dept_id;