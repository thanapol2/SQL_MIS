--insert
--    INTO rept_extend_cert_status
--( caldr_year,
--  start_date,
--  end_date,
--  update_date,
--  quater_id,
--  quater_short_name,
--  quater_long_name,
--  month_id,
--  month_short_name,
--  month_long_name,
--  region_no,
--  region_name,
--  cert_extend_cd,
--  cert_extend_status,
--  cert_cnt,
--  cert_pert,
--  create_dtm,
--  create_user_id) 
SELECT
    TO_CHAR(core.month_year, 'yyyy') + 543 AS caldr_year,
    trunc(add_months(core.month_year, 6516), 'yyyy') AS start_date,
    trunc(add_months(core.month_year, 6528), 'yyyy') - 1 AS end_date,
    trunc(SYSDATE) update_date,
    TO_CHAR(core.month_year, 'Q') AS quater_id,
    'ไตรมาสที่ '
    || TO_CHAR(core.month_year, 'Q') AS quater_short_name,
    'ปี '
    || TO_CHAR(TO_CHAR(core.month_year, 'yyyy') + 543)
    || ' ไตรมาสที่ '
    || TO_CHAR(core.month_year, 'Q') AS quater_long_name,
    TO_CHAR(core.month_year, 'MM') AS month_id,
    TO_CHAR(core.month_year, 'MON') AS month_short_name,
    TO_CHAR(core.month_year, 'MONTH') AS month_long_name,
    core.region_no,
    core.region_name,
    core.cert_extend_cd,
    core.cert_extend_status,
    nvl(cal.cert_cnt,0) as cert_cnt,
    100 AS cert_pert,
    SYSDATE   create_dtm,
    'RAW' create_user_id
FROM
    (
        SELECT
            r.region_no,
            r.region_name,
            t.month_year,
            ce.cert_extend_cd,
            ce.cert_extend_status
        FROM
            region_mas r
            CROSS JOIN (
                SELECT
                    trunc(TO_DATE('01/01/2016', 'dd/mm/yyyy'), 'mm') month_year
                FROM
                    dual
            ) t
            CROSS JOIN cert_extend ce
        WHERE
            ce.cert_extend_cd = 0
    ) core
    LEFT JOIN (
        SELECT
            region_no,
            month_year,
            '0' AS cert_extend_cd,
            COUNT(cert_extend_cd) cert_cnt
        FROM
            (
--    raw
                SELECT
                    md.region_no,
                    trunc(TO_DATE('01/01/2016', 'dd/mm/yyyy')) AS month_year,
                    nvl2(new.token_request_id, 1, 2) cert_extend_cd
                FROM
                    (
                        SELECT
                            *
                        FROM
                            token_request
                        WHERE
                            status = 'APPROVE'
-- check expire date
                            AND months_between(trunc(TO_DATE('01/01/2016', 'dd/mm/yyyy')), trunc(updated_date)) BETWEEN 10 AND 12  
--and MONTHS_BETWEEN(trunc(sysdate),updated_Date) between 10 and 12
                    ) old
                    LEFT JOIN token_request new ON old.username = new.username
-- check rew new date
                                                   AND new.created_date BETWEEN add_months(trunc(old.updated_date), 10) AND add_months
                                                   (trunc(old.updated_date), 12)
                    INNER JOIN region_off md ON old.off_id = md.off_id
            ) cal
        GROUP BY
            region_no,
            month_year
    ) cal ON core.region_no = cal.region_no
             AND core.month_year = cal.month_year
             AND core.cert_extend_cd = cal.cert_extend_cd