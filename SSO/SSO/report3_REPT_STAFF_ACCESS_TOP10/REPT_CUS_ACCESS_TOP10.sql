SELECT
--    d.month_year,
    TO_CHAR(d.tran_date, 'yyyy') + 543 AS caldr_year,
    trunc(add_months(d.tran_date, 6516), 'yyyy') AS start_date,
    trunc(add_months(d.tran_date, 6528), 'yyyy') - 1 AS end_date,
    trunc(SYSDATE) update_date,
    TO_CHAR(d.tran_date, 'Q') AS quater_id,
    'ไตรมาสที่ '
    || TO_CHAR(d.tran_date, 'Q') AS quater_short_name,
    'ปี '
    || TO_CHAR(TO_CHAR(d.tran_date, 'yyyy') + 543)
    || ' ไตรมาสที่ '
    || TO_CHAR(d.tran_date, 'Q') AS quater_long_name,
    TO_CHAR(d.tran_date, 'MM') AS month_id,
    TO_CHAR(d.tran_date, 'MON') AS month_short_name,
    TO_CHAR(d.tran_date, 'MONTH') AS month_long_name,
    access_user_id,
    dept_desc,
    '' AS region_no,
    '' AS region_name,
    '' AS access_user_type_id,
    access_user_type,
    access_cus_cnt,
    rank,
    SYSDATE   AS create_dtm,
    'RAW' AS create_user_id
FROM
    (
        SELECT
            core.rank,
            core.tran_date,
            core.access_user_id,
            core.access_cus_cnt,
            reg.dept            AS dept_desc,
            reg.position_work   AS access_user_type
        FROM
            (
                SELECT
                    ROWNUM rank,
                    d.tran_date,
                    d.userid   AS access_user_id,
                    d.access_cus_cnt
                FROM
                    (
                        SELECT
                            trunc(tran_date, 'mm') AS tran_date,
                            userid,
                            COUNT(*) AS access_cus_cnt
                        FROM
                            sso.tran_log
--    WHERE  trunc(tran_log, 'mon') = date_start
                        GROUP BY
                            trunc(tran_date, 'mm'),
                            userid
                        ORDER BY
                            access_cus_cnt DESC
                    ) d
                WHERE
                    ROWNUM <= 10
            ) core
            INNER JOIN sso.ed_regis reg ON core.access_user_id = reg.user_id
    ) d