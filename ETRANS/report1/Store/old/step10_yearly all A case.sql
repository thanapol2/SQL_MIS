INSERT
INTO rept_req_cert_status
  (
    caldr_year,
    start_date,
    end_date,
    update_date,
    quater_id,
    quater_short_name,
    quater_long_name,
    month_id,
    month_short_name,
    month_long_name,
    region_no,
    region_name,
    off_id,
    off_name,
    status_code,
    status_desc,
    reqt_cnt_status,
    reqt_cnt,
    reqt_pert,
    create_dtm,
    create_user_id
  )
SELECT caldr_year,
    start_date,
    end_date,
    update_date,
    quater_id,
    quater_short_name,
    quater_long_name,
    month_id,
    month_short_name,
    month_long_name,
    region_no,
    region_name,
    off_id,
    off_name,
    status_code,
    status_desc,
    'A' as reqt_cnt_status,
    reqt_cnt,
    reqt_pert,
    sysdate create_dtm,
    'CAL10'create_user_id
FROM rept_req_cert_status
WHERE caldr_year = TO_CHAR(SYSDATE, 'yyyy') + 543
AND month_id     = '13';