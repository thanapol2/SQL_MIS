--- core
 select 
 TO_CHAR(d.month_year, 'yyyy') + 543 AS caldr_year,
            trunc(add_months(d.month_year, 6516), 'yyyy') AS start_date,
            trunc(add_months(d.month_year, 6528), 'yyyy') - 1 AS end_date,
            trunc(SYSDATE) update_date,
            TO_CHAR(d.month_year, 'Q') AS quater_id,
            'ไตรมาสที่ '
            || TO_CHAR(d.month_year, 'Q') AS quater_short_name,
            'ปี '
            || TO_CHAR(TO_CHAR(d.month_year, 'yyyy') + 543)
            || ' ไตรมาสที่ '
            || TO_CHAR(d.month_year, 'Q') AS quater_long_name,
            TO_CHAR(d.month_year, 'MM') AS month_id,
            TO_CHAR(d.month_year, 'MON') AS month_short_name,
            TO_CHAR(d.month_year, 'MONTH') AS month_long_name,;
  d.region_no,
  d.region_name,
  3 MANAGE_TYPE_CD,
  'คัดค้นเอกสารสำคัญ' MANAGE_TYPE_DESC,
  idt.IMP_DOC_TYPE_CD,
  dc.doc_type AS IMP_DOC_TYPE_DESC,
  dc.IMP_DOC_CUR_YEAR_CNT,
  '0' IMP_DOC_CUR_YEAR_PERT,
  NVL(do.IMP_DOC_PRIOR_YEAR_CNT,0) IMP_DOC_PRIOR_YEAR_CNT,
  '0' IMP_DOC_PRIOR_YEAR_PERT,
  sysdate CREATE_DTM,
  'RAW' CREATE_USER_ID       
FROM
  (SELECT dc.month_year,
    ap.dept_id,
    dc.doc_type,
    COUNT(*) IMP_DOC_CUR_YEAR_CNT
  FROM
    (SELECT TRUNC(created_date, 'mon') month_year,
      USERNAME,
      DOC_TYPE
    FROM doc_hist
    WHERE TRUNC(created_date, 'year') = to_date('01/01/2018','dd/mm/yyyy')
    AND PRINT_STATUS                  = '1'
    ) dc
  INNER JOIN app_user ap
  ON dc.USERNAME = ap.USERNAME
  GROUP BY dc.month_year,
    ap.dept_id,
    dc.doc_type
  ) d
INNER JOIN Imp_doc_type idt
ON idt.IMP_DOC_TYPE_DESC = dc.DOC_TYPE
LEFT JOIN
  (SELECT dc.month_year,
    ap.dept_id,
    dc.doc_type,
    COUNT(*) IMP_DOC_PRIOR_YEAR_CNT
  FROM
    (SELECT TRUNC(created_date, 'mon') month_year,
      USERNAME,
      DOC_TYPE
    FROM doc_hist
    WHERE TRUNC(created_date, 'year') = to_date('01/01/2017','dd/mm/yyyy')
    AND PRINT_STATUS                  = '1'
    ) dc
  INNER JOIN app_user ap
  ON dc.USERNAME = ap.USERNAME
  GROUP BY dc.month_year,
    ap.dept_id,
    dc.doc_type
  ) DO ON dc.dept_id=do.dept_id
AND dc.doc_type     =do.doc_type;

-- 99
--- core
SELECT dc.month_year,
  99 region_no,
  'ทั่วประเทศ' region_name,
  3 MANAGE_TYPE_CD,
  'คัดค้นเอกสารสำคัญ' MANAGE_TYPE_DESC,
  idt.IMP_DOC_TYPE_CD,
  dc.doc_type AS IMP_DOC_TYPE_DESC,
  dc.IMP_DOC_CUR_YEAR_CNT,
  '0' IMP_DOC_CUR_YEAR_PERT,
  NVL(do.IMP_DOC_PRIOR_YEAR_CNT,0) IMP_DOC_PRIOR_YEAR_CNT,
  '0' IMP_DOC_PRIOR_YEAR_PERT,
  sysdate CREATE_DTM,
  'ETL Batch' CREATE_USER_ID
FROM
  (SELECT dc.month_year,
    dc.doc_type,
    COUNT(*) IMP_DOC_CUR_YEAR_CNT
  FROM
    (SELECT TRUNC(created_date, 'mon') month_year,
      USERNAME,
      DOC_TYPE
    FROM doc_hist
    WHERE TRUNC(created_date, 'year') = to_date('01/01/2018','dd/mm/yyyy')
    AND PRINT_STATUS                  = '1'
    ) dc
  GROUP BY dc.month_year,
    dc.doc_type
  ) dc
INNER JOIN Imp_doc_type idt
ON idt.IMP_DOC_TYPE_DESC = dc.DOC_TYPE
LEFT JOIN
  (SELECT dc.month_year,
    dc.doc_type,
    COUNT(*) IMP_DOC_PRIOR_YEAR_CNT
  FROM
    (SELECT TRUNC(created_date, 'mon') month_year,
      USERNAME,
      DOC_TYPE
    FROM doc_hist
    WHERE TRUNC(created_date, 'year') = to_date('01/01/2017','dd/mm/yyyy')
    AND PRINT_STATUS                  = '1'
    ) dc
  GROUP BY dc.month_year,
    dc.doc_type
  ) DO ON  dc.doc_type     =do.doc_type;