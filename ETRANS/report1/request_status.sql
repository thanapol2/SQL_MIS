-- Sum request only
SELECT de.month_year,
  de.dept_id,
  md.dept_name,
  de.off_id,
  'none' off_name,
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
-- sum year
SELECT de.month_year,
  de.dept_id,
  md.dept_name,
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

-- depart sum office 999999
SELECT
    de.month_year,
    de.dept_id,
    md.dept_name,
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
    '99' dept_id,
    'ทั่วประเทศ' dept_name,
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
    (SELECT TRUNC(created_date, 'mon') month_year,
      dept_id
    FROM token_request
      --                    where  trunc(created_date, 'mon') =
    ) tr
  GROUP BY month_year) de;
    