    INSERT INTO rept_extend_cert_status (
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
        cert_extend_cd,
        cert_extend_status,
        cert_cnt,
        cert_pert,
        create_dtm,
        create_user_id
    )
        SELECT
           --    d.month_year,
            core.caldr_year,
            TO_DATE('01/01/' || core.caldr_year, 'dd/mm/YYYY') AS start_date,
            TO_DATE('31/12/' || core.caldr_year, 'dd/mm/YYYY') AS end_date,
            trunc(SYSDATE) update_date,
            9 AS quater_id,
            'รวม ทุกไตรมาส' AS quater_short_name,
            'ปี '
            || core.caldr_year
            || ' รวม ทุกไตรมาส' AS quater_long_name,
            13 AS month_id,
            'รวมทั้งหมด' AS month_short_name,
            'รวมทั้งหมด' AS month_long_name,
            core.region_no,
            ro.region_name,
            core.cert_extend_cd,
            c.cert_extend_status,
            core.cert_cnt,
            100 AS cert_pert,
            SYSDATE   create_dtm,
            'STEP3' create_user_id
        FROM
            (
                SELECT
                    region_no,
                    cert_extend_cd,
                    caldr_year,
                    SUM(cert_cnt) cert_cnt
                FROM
                    rept_extend_cert_status
                WHERE
                    create_user_id = 'RAW'
                    AND caldr_year = TO_CHAR(trunc(TO_DATE('01/02/2019', 'dd/mm/yyyy'), 'yyyy'), 'yyyy') + 543
                GROUP BY
                    region_no,
                    cert_extend_cd,
                    caldr_year
            ) core
            INNER JOIN cert_extend c ON core.cert_extend_cd = c.cert_extend_cd
            INNER JOIN region_mas ro ON core.region_no = ro.region_no