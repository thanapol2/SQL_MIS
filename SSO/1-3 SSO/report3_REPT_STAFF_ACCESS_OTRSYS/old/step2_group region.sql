CREATE OR REPLACE PROCEDURE rept_staff_otrsys_2 (
    month_id_in     IN              NUMBER,
    caldr_year_in   IN              NUMBER
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
            core.caldr_year,
            TO_DATE('01/01/' || core.caldr_year, 'dd/mm/YYYY') AS start_date,
            TO_DATE('31/12/' || core.caldr_year, 'dd/mm/YYYY') AS end_date,
            trunc(SYSDATE) update_date,
            TO_CHAR(TO_DATE('01/'
                            || core.month_id
                            || '/'
                            || core.caldr_year, 'dd/mm/yyyy'), 'Q') AS quater_id,
            'ไตรมาสที่ '
            || TO_CHAR(TO_DATE('01/'
                               || core.month_id
                               || '/'
                               || core.caldr_year, 'dd/mm/yyyy'), 'Q') AS quater_short_name,
            'ปี '
            || core.caldr_year
            || ' ไตรมาสที่ '
            || TO_CHAR(TO_DATE('01/'
                               || core.month_id
                               || '/'
                               || core.caldr_year, 'dd/mm/yyyy'), 'Q') AS quater_long_name,
            core.month_id   AS month_id,
            TO_CHAR(TO_DATE('01/'
                            || core.month_id
                            || '/'
                            || core.caldr_year, 'dd/mm/yyyy'), 'MON') AS month_short_name,
            TO_CHAR(TO_DATE('01/'
                            || core.month_id
                            || '/'
                            || core.caldr_year, 'dd/mm/yyyy'), 'MONTH') AS month_long_name,
            '99' AS region_no,
            'ทั่วประเทศ' AS region_name,
            '9999999999' AS dept_code,
            'รวม สท.' AS dept_desc,
            access_user_status_code,
            '' AS access_user_status,
            userid_staff_cnt,
            status_by_dept_pert,
            SYSDATE         AS create_dtm,
            'STEP2_grp DEPT' AS create_user_id
        FROM
            (
                SELECT
                    core.month_id,
                    core.caldr_year,
                    core.access_user_status_code,
                    core.userid_staff_cnt,
                    core.userid_staff_cnt / s.userid_staff_all * 100 AS status_by_dept_pert
                FROM
                    (
                        SELECT
                            month_id,
                            caldr_year,
                            access_user_status_code,
                            SUM(userid_staff_cnt) userid_staff_cnt
                        FROM
                            rept_staff_access_otrsys
                        WHERE
                            create_user_id = 'RAW'
                            AND month_id = month_id_in
                            AND caldr_year = caldr_year_in
                        GROUP BY
                            month_id,
                            caldr_year,
                            access_user_status_code
                    ) core
                    INNER JOIN (
                        SELECT
                            month_id,
                            caldr_year,
                            SUM(userid_staff_cnt) userid_staff_all
                        FROM
                            rept_staff_access_otrsys
                        WHERE
                            create_user_id = 'RAW'
                            AND month_id = month_id_in
                            AND caldr_year = caldr_year_in
                        GROUP BY
                            month_id,
                            caldr_year
                    ) s ON core.month_id = s.month_id
                           AND core.caldr_year = s.caldr_year
            ) core;

END;