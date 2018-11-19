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
            off_id,
            status_desc,
            reqt_cnt_status,
            reqt_cnt,
            reqt_pert
        )
            SELECT
                month_year,
                dept_id,
                off_id,
                status_desc,
                reqt_cnt_status,
                reqt_cnt,
                reqt_pert
            FROM
                (
                    SELECT
                        dept_id,
                        off_id,
                        status_desc,
                        'A' reqt_cnt_status,
                        SUM(reqt_cnt) reqt_cnt,
                        100 reqt_pert
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
                ) cal,
                (
                    SELECT
                        r.month_year   month_year
                    FROM
                        dual
                ) mn;

    END LOOP;
END;