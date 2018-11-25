SELECT
    region_no,
    off_id,
    status_desc,
    'A' reqt_cnt_status,
    SUM(reqt_cnt) reqt_cnt,
    NULL reqt_pert
FROM
    rept_req_cert_status tr
WHERE
    caldr_year = 
--                        AND tr.status_desc = 'request'
    AND tr.reqt_cnt_status = 'N'
GROUP BY
    region_no,
    off_id,
    status_code
                