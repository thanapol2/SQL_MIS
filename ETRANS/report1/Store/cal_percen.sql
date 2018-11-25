BEGIN
    FOR r IN (
        SELECT
            off_id,
            region_no,
            caldr_year,
            month_id,
            nullif(reqt_cnt, 0) reqt_all
        FROM
            rept_req_cert_status
        WHERE
            create_user_id != 'RAW'
            AND caldr_year = TO_CHAR(SYSDATE, 'yyyy') + 543
            AND status_code = 1
    ) LOOP
        UPDATE rept_req_cert_status t
        SET
            reqt_pert = round(nvl(reqt_cnt * 100 / r.reqt_all, 0), 2)
        WHERE
            t.caldr_year = r.caldr_year
            and t.month_id = r.month_id
            AND t.region_no = r.region_no
            AND t.off_id = r.off_id
            and create_user_id != 'RAW'
            AND status_code NOT IN (
                1,
                99
            );
    END LOOP;
END;