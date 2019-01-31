SELECT
--    d.month_year,
    TO_CHAR(d.month_year, 'yyyy') AS caldr_year,
    trunc(d.month_year) AS start_date,
    trunc(d.month_year) - 1 AS end_date,
    trunc(SYSDATE) update_date,
    TO_CHAR(d.month_year, 'Q') AS quater_id,
    'ไตรมาสที่ '
    || TO_CHAR(d.month_year, 'Q') AS quater_short_name,
    'ปี '
    || TO_CHAR(TO_CHAR(d.month_year, 'yyyy'))
    || ' ไตรมาสที่ '
    || TO_CHAR(d.month_year, 'Q') AS quater_long_name,
    TO_CHAR(d.month_year, 'MM') AS month_id,
    TO_CHAR(d.month_year, 'MON') AS month_short_name,
    TO_CHAR(d.month_year, 'MONTH') AS month_long_name,
    '999' AS access_date_id,
    userid_staff_cnt,
    access_staff_cnt,
    SYSDATE   AS create_dtm,
    'STEP2' AS create_user_id
FROM
    (
        SELECT
            trunc(TO_DATE(month_id
                          || '/'
                          || caldr_year, 'mm/yyyy'), 'mon') AS month_year,
            month_id,
            caldr_year,
            SUM(userid_staff_cnt) AS userid_staff_cnt,
            SUM(access_staff_cnt) AS access_staff_cnt
        FROM
            rept_staff_access
        GROUP BY
            month_id,
            caldr_year
    ) d