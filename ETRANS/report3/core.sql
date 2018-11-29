SELECT
    core.month_year,
    core.region_no,
    core.region_name,
    cal.cert_extend_cd,
    ce.cert_extend,
    cal.cert_cnt,
    0 AS cert_pert,
    SYSDATE   create_dtm,
    'RAW' create_user_id
FROM
    (
        SELECT
            r.region_no,
            r.region_name,
            t.month_year
        FROM
            region_mas r
            CROSS JOIN (
                SELECT
                    trunc(TO_DATE('01/02/2019', 'dd/mm/yyyy'), 'mm') month_year
                FROM
                    dual
            ) t
    ) core
    INNER JOIN (
        SELECT
            region_no,
            month_year,
            cert_extend_cd,
            COUNT(cert_extend_cd) cert_cnt
        FROM
            (
--    raw
                SELECT
                    md.region_no,
                    trunc(TO_DATE('01/02/2019', 'dd/mm/yyyy')) AS month_year,
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
                            AND months_between(trunc(TO_DATE('01/02/2019', 'dd/mm/yyyy')), trunc(updated_date)) BETWEEN 10 AND 12  
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
            month_year,
            cert_extend_cd
    ) cal ON core.region_no = cal.region_no
             AND core.month_year = cal.month_year
    INNER JOIN cert_extend ce ON ce.cert_extend_cd = cal.cert_extend_cd