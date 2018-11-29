BEGIN
    FOR r IN (
        SELECT
            region_no,
            caldr_year,
            month_id,
            cert_extend_cd,
            nullif(cert_cnt, 0) cert_all
        FROM
            rept_extend_cert_status
        WHERE
            cert_extend_cd = 0
            AND month_id != 13
                AND TO_DATE('01/' || month_id
                                     || '/'
                                        || caldr_year, 'dd/mm/yyyy') = TO_DATE('01/02/2562', 'dd/mm/yyyy')
    ) LOOP
        UPDATE rept_extend_cert_status t
        SET
            cert_pert = round(nvl(cert_cnt * 100 / r.cert_all, 0), 2)
        WHERE
            t.caldr_year = r.caldr_year
            AND t.month_id = r.month_id
                AND t.region_no = r.region_no
                    AND cert_extend_cd NOT IN (
                0,
                99
            );

    END LOOP;
END;