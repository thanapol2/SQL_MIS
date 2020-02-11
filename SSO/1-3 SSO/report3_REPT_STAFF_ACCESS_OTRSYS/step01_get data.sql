create or replace PROCEDURE rept_staff_otrsys_1 (
    date_start IN   DATE
) AS
BEGIN
    INSERT INTO rept_staff_access_otrsys (
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
        dept_code,
        dept_desc,
        access_user_status_code,
        access_user_status,
        userid_staff_cnt,
        status_by_dept_pert,
        create_dtm,
        create_user_id
    )
        SELECT
--    d.month_year,
            TO_CHAR(d.month_year, 'yyyy') + 543 AS caldr_year,
            trunc(add_months(d.month_year, 6516), 'yyyy') AS start_date,
            trunc(add_months(d.month_year, 6528), 'yyyy') - 1 AS end_date,
            trunc(SYSDATE) update_date,
            TO_CHAR(d.month_year, 'Q') AS quater_id,
            'ไตรมาสที่ '
            || TO_CHAR(d.month_year, 'Q') AS quater_short_name,
            'ปี '
            || TO_CHAR(TO_CHAR(d.month_year, 'yyyy') + 543)
            || ' ไตรมาสที่ '
            || TO_CHAR(d.month_year, 'Q') AS quater_long_name,
            TO_CHAR(d.month_year, 'MM') AS month_id,
            TO_CHAR(d.month_year, 'MON') AS month_short_name,
            TO_CHAR(d.month_year, 'MONTH') AS month_long_name,
            '' AS region_no,
            '' AS region_name,
            '' AS dept_code,
            dept_desc,
            access_user_status_code,
            '' AS access_user_status,
            userid_staff_cnt,
            status_by_dept_pert,
            SYSDATE   AS create_dtm,
            'RAW' AS create_user_id
        FROM
            (
                SELECT
                    core.month_year,
                    core.dept        dept_desc,
                    d.activateflag   AS access_user_status_code,
                    userid_staff_cnt,
                    ( d.userid_staff_cnt / core.userid_staff_cnt_all ) * 100 AS status_by_dept_pert
                FROM
                    (
                        SELECT
                            trunc(SYSDATE, 'mm') month_year,
                            dept,
                            COUNT(*) userid_staff_cnt_all
                        FROM
                            sso_ed_regis
                        GROUP BY
                            dept
                    ) core
                    INNER JOIN (
                        SELECT
                            trunc(SYSDATE, 'mm') month_year,
                            dept,
                            activateflag,
                            COUNT(*) userid_staff_cnt
                        FROM
                            sso_ed_regis
                        GROUP BY
                            dept,
                            activateflag
                    ) d ON core.dept = d.dept
            ) d;

END;