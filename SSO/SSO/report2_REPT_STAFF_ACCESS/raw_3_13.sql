create or replace PROCEDURE rept_staff_access1 (
    date_start IN   DATE
) AS
BEGIN
    
    INSERT INTO rept_staff_access (
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
        access_date_id,
        userid_staff_cnt,
        access_staff_cnt,
        create_dtm,
        create_user_id
    )
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
            TO_CHAR(d.tran_date, 'dd') AS access_date_id,
            userid_cus_cnt,
            access_cus_cnt,
            SYSDATE   AS create_dtm,
            'RAW' AS create_user_id
        FROM
            (
                SELECT
                    core.tran_date,
                    nvl(userid_cus_cnt, 0) AS userid_cus_cnt,
                    nvl(access_cus_cnt, 0) AS access_cus_cnt
                FROM
                    (
                        WITH t AS (
                            SELECT
                                TO_DATE('22/02/2015', 'dd/mm/yyyy') start_date,
                                TO_DATE('27/02/2015', 'dd/mm/yyyy') end_date
                            FROM
                                dual
                        )
                        SELECT
                            trunc(start_date) + level - 1 AS tran_date
                        FROM
                            t
                        CONNECT BY
                            trunc(end_date) >= trunc(start_date) + level - 1
                    ) core
                    LEFT JOIN (
                        SELECT
                            cu.tran_date,
                            userid_cus_cnt,
                            access_cus_cnt
                        FROM
                            (
                                SELECT
                                    tran_date,
                                    COUNT(userid) AS userid_cus_cnt
                                FROM
                                    (
                                        SELECT DISTINCT
                                            trunc(tran_date) tran_date,
                                            userid
                                        FROM
                                            sso.tran_log
                                        WHERE
                                            trunc(TRAN_DATE, 'mon') = date_start
                                    )
                                GROUP BY
                                    tran_date
                            ) cu
                            INNER JOIN (
                                SELECT
                                    tran_date,
                                    COUNT(*) AS access_cus_cnt
                                FROM
                                    sso.tran_log
                                WHERE
                                    trunc(TRAN_DATE, 'mon') = date_start
                                GROUP BY
                                    tran_date
                            ) ac ON ac.tran_date = cu.tran_date
                    ) d ON core.tran_date = d.tran_date
            ) d;

END;