BEGIN
    FOR r IN (
        SELECT
            month_year,
            region_no,
            off_id,
            SUM(reqt_cnt) reqt_all
        FROM
            temp_r1
        WHERE
            reqt_cnt_status = 'A'
            AND status_desc = 'request'
        GROUP BY
            month_year,
            region_no,
            off_id
    ) LOOP
        UPDATE temp_r1 t
        SET
            reqt_pert = reqt_cnt * 100 / r.reqt_all
        WHERE
            t.month_year = r.month_year
            AND t.region_no = r.region_no
            AND t.off_id = r.off_id
            AND t.reqt_cnt_status = 'A';

    END LOOP;
END;