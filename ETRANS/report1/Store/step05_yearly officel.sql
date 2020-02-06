INSERT INTO rept_req_cert_status (
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
SELECT
--    d.month_year,
    m.caldr_year,
    TO_DATE('01/01/' || m.caldr_year, 'dd/mm/YYYY') AS start_date,
    TO_DATE('31/12/' || m.caldr_year, 'dd/mm/YYYY') AS end_date,
    trunc(SYSDATE) update_date,
    9 AS quater_id,
    'รวม ทุกไตรมาส' AS quater_short_name,
    'ปี '
    || m.caldr_year
    || ' รวม ทุกไตรมาส' AS quater_long_name,
    13 AS month_id,
    'รวมทั้งหมด' AS month_short_name,
    'รวมทั้งหมด' AS month_long_name,
    m.region_no,
    ro.region_name,
    m.off_id || 99 AS off_id,
    'รวม ' || ro.off_name AS off_name,
    s.status_code,
    s.status_desc,
    'N' reqt_cnt_status,
    reqt_cnt   reqt_cnt,
    100 reqt_pert,
    SYSDATE    create_dtm,
    'CAL5' create_user_id
FROM
    (
        SELECT
            off_id,
            region_no,
            status_code,
            caldr_year,
            SUM(reqt_cnt) reqt_cnt
        FROM
            rept_req_cert_status
        WHERE
            create_user_id = 'RAW'
            AND caldr_year = TO_CHAR(SYSDATE, 'yyyy') + 543
        GROUP BY
            off_id,
            region_no,
            status_code,
            caldr_year
-- call status 99                
        UNION
        SELECT
            off_id,
            region_no,
            99 status_code,
            caldr_year,
            SUM(reqt_cnt) reqt_cnt
        FROM
            rept_req_cert_status
        WHERE
            create_user_id = 'RAW'
            AND status_code = 1
            AND caldr_year = TO_CHAR(SYSDATE, 'yyyy') + 543
        GROUP BY
            off_id,
            region_no,
            status_code,
            caldr_year
    ) m
    INNER JOIN status s ON m.status_code = s.status_code
    INNER JOIN region_off ro ON m.off_id = ro.off_id;
--