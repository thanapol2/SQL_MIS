BEGIN
    FOR r IN (
        WITH t AS (
            SELECT
                DATE '2018-01-01' start_date,
                SYSDATE   end_date
            FROM
                dual
        )
        SELECT
            add_months(trunc(start_date, 'mm'), level - 1) month_year
        FROM
            t
        CONNECT BY
            trunc(end_date, 'mm') >= add_months(trunc(start_date, 'mm'), level - 1)
    ) LOOP
        INSERT INTO temp_r1 (
            month_year,
            dept_id,
            dept_name,
            off_id,
            off_name,
            status_code,
            status_desc,
            reqt_cnt_status,
            reqt_cnt,
            reqt_pert
--            create_dim,
--            create_user_id
        )
            SELECT
                month_year,
                cal.dept_id,
                md.dept_name,
                off_id,
                'none' off_name,
                'none' status_code,
                status_desc,
                reqt_cnt_status,
                reqt_cnt,
                reqt_pert
--                sysdate,
--                 'batch'
            FROM
                (
                    SELECT
                        dept_id,
                        off_id,
                        status_desc,
                        'A' reqt_cnt_status,
                        SUM(reqt_cnt) reqt_cnt,
                        null reqt_pert
                    FROM
                        temp_r1 tr
                    WHERE
                        tr.month_year <= r.month_year 
--                        AND tr.status_desc = 'request'
                        AND tr.reqt_cnt_status = 'N'
                    GROUP BY
                        dept_id,
                        off_id,
                        status_desc
                ) cal
                INNER JOIN mst_dept md ON cal.dept_id = md.dept_id
                cross join (
                    SELECT
                        r.month_year   month_year
                    FROM
                        dual
                ) mn;

    END LOOP;
     FOR r IN (
        WITH t AS (
            SELECT
                DATE '2018-01-01' start_date,
                SYSDATE   end_date
            FROM
                dual
        )
        SELECT
            add_months(trunc(start_date, 'mm'), level - 1) month_year
        FROM
            t
        CONNECT BY
            trunc(end_date, 'mm') >= add_months(trunc(start_date, 'mm'), level - 1)
    )
END;