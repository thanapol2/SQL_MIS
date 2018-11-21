-- Sum request only
SELECT de.month_year,
  de.dept_id,
  md.dept_name region_no,
  de.off_id region_name,
  'none' off_name,
  'none' status_code,
  'request' AS status_desc,
  'N' reqt_cnt_status,
  reqt_all REQT_CNT, 
  reqt_all * 100 / reqt_all reqt_pert
FROM
  (SELECT month_year,
    tr.dept_id,
    tr.off_id,
    COUNT(*) reqt_all
  FROM
    (SELECT TRUNC(created_date, 'mon') month_year,
      dept_id,
      off_id
    FROM token_request
      --                    where  trunc(created_date, 'mon') =
    ) tr
  GROUP BY month_year,
    dept_id,
    off_id
  ) de
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
  'request' AS status_desc,
  'N' reqt_cnt_status,
  reqt_all,
  reqt_all * 100 / reqt_all reqt_pert
FROM
  (SELECT month_year,
    tr.dept_id,
    tr.off_id,
    COUNT(*) reqt_all
  FROM
    (SELECT TRUNC(created_date, 'year') month_year,
      dept_id,
      off_id
    FROM token_request
      --                    where  trunc(created_date, 'mon') =
    ) tr
  GROUP BY month_year,
    dept_id,
    off_id
  ) de
INNER JOIN mst_dept md
ON de.dept_id = md.dept_id;

-- depart sum office 999999 monthly and yearly
SELECT
    de.month_year,
    de.dept_id as region_no,
    md.dept_name as region_name,
    '999999' off_id,
    'รวมสรรพสามิตพื้นที่ ภาคที่ '|| de.dept_id off_name,
    'none' status_code,
    'request' AS status_desc,
    'N' reqt_cnt_status,
    reqt_all,
    reqt_all * 100 / reqt_all reqt_pert
FROM
    (SELECT month_year,
    tr.dept_id,
    COUNT(*) reqt_all
  FROM
    (SELECT TRUNC(created_date, 'mon') month_year,
      dept_id
    FROM token_request
      --                    where  trunc(created_date, 'mon') =
    ) tr
  GROUP BY month_year,
    dept_id
    )de
    INNER JOIN mst_dept md ON de.dept_id = md.dept_id;
    
-- sum all
SELECT
    de.month_year,
    '99' region_no,
    'ทั่วประเทศ' region_name,
    '999999' off_id,
    'ทั่วประเทศ' off_name,
    'none' status_code,
    'request'   AS status_desc,
    'N' reqt_cnt_status,
    reqt_all,
    reqt_all * 100 / reqt_all reqt_pert
FROM
    (SELECT month_year,
    COUNT(*) reqt_all
  FROM
    (SELECT TRUNC(created_date, 'year') month_year,
      dept_id
    FROM token_request
      --                    where  trunc(created_date, 'mon') =
    ) tr
  GROUP BY month_year) de;
    