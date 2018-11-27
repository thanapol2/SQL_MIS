INSERT INTO rept_manage_cert_status (
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
    cert_status_cd,
    cert_status,
    cert_reason_status_cd,
    cert_reason_status,
    cert_cnt_status,
    cert_cnt,
    cert_pert,
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
    999999 AS off_id,
    'รวมสรรพสามิตพื้นที่  ' || ro.region_name AS off_name,
    s.cert_status_cd,
    s.cert_status,
    null as CERT_REASON_STATUS_CD,
    null as CERT_REASON_STATUS,
    'N' as cert_cnt_status,
    reqt_cnt as  cert_cnt,
    null as cert_pert,
    SYSDATE    create_dtm,
    'CAL4' create_user_id
from (SELECT
            region_no,
            cert_status_cd,
            caldr_year,
            SUM(cert_cnt) reqt_cnt
        FROM
            rept_manage_cert_status
        WHERE
            create_user_id = 'RAW'
            AND caldr_year = TO_CHAR(SYSDATE, 'yyyy') + 543
        GROUP BY
            region_no,
            cert_status_cd,
            caldr_year) m
    INNER JOIN cert_status s ON m.cert_status_cd = s.cert_status_cd
    INNER JOIN region_mas ro ON m.region_no = ro.region_no;