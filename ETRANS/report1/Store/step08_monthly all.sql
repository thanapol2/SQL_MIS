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
    TO_CHAR(TO_DATE('01/'
                    || m.month_id
                    || '/'
                    || m.caldr_year, 'dd/mm/yyyy'), 'Q') AS quater_id,
    'ไตรมาสที่ '
    || TO_CHAR(
        TO_DATE('01/'
                    || m.month_id
                    || '/'
                    || m.caldr_year, 'dd/mm/yyyy'), 'Q') AS quater_short_name,
    'ปี '
    || m.caldr_year
    || ' ไตรมาสที่ '
    || TO_CHAR(
        TO_DATE('01/'
                    || m.month_id
                    || '/'
                    || m.caldr_year, 'dd/mm/yyyy'), 'Q') AS quater_long_name,
    m.month_id   AS month_id,
    TO_CHAR(
        TO_DATE('01/'
                    || m.month_id
                    || '/'
                    || m.caldr_year, 'dd/mm/yyyy'), 'MON') AS month_short_name,
    TO_CHAR(
        TO_DATE('01/'
                    || m.month_id
                    || '/'
                    || m.caldr_year, 'dd/mm/yyyy'), 'MONTH') AS month_long_name,
    99 as region_no,
    'ทั่วประเทศ' as region_name,
    999999 AS off_id,
    'ทั่วประเทศ' AS off_name,
    s.status_code,
    s.status_desc,
    'N' reqt_cnt_status,
    reqt_cnt   reqt_cnt,
    100 reqt_pert,
    SYSDATE    create_dtm,
    'CAL8' create_user_id
FROM
    (
        SELECT
            status_code,
            caldr_year,
            month_id,
            SUM(reqt_cnt) reqt_cnt
        FROM
            rept_req_cert_status
        WHERE
            create_user_id = 'RAW'
            AND caldr_year = TO_CHAR(SYSDATE, 'yyyy') + 543
            AND month_id <= TO_CHAR(trunc(SYSDATE), 'mm')
--            and month_id between to_char(add_months(trunc(SYSDATE),-4),'mm')and to_char(trunc(SYSDATE),'mm')
        GROUP BY
            status_code,
            caldr_year,
            month_id
    ) m
    INNER JOIN status s ON m.status_code = s.status_code;
--

