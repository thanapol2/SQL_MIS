BEGIN
    FOR r IN (
        WITH t AS (
            SELECT
                trunc(SYSDATE, 'yyyy') start_date,
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
        INSERT INTO rept_manage_cert_status (
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
            off_id,
            off_name,
            cert_status_cd,
            cert_status,
            cert_reason_status_cd,
            cert_reason_status,
            cert_cnt_status,
            cert_cnt,
            cert_pert,
            create_dtm,
            create_user_id
        )
            SELECT
                m.caldr_year,
                TO_DATE('01/01/' || m.caldr_year, 'dd/mm/YYYY') AS start_date,
                TO_DATE('31/12/' || m.caldr_year, 'dd/mm/YYYY') AS end_date,
                trunc(SYSDATE) update_date,
                TO_CHAR(TO_DATE('01/'
                                || m.month_id
                                || '/'
                                || m.caldr_year, 'dd/mm/yyyy'), 'Q') AS quater_id,
                'ไตรมาสที่ '
                || TO_CHAR(TO_DATE('01/'
                                   || m.month_id
                                   || '/'
                                   || m.caldr_year, 'dd/mm/yyyy'), 'Q') AS quater_short_name,
                'ปี '
                || m.caldr_year
                || ' ไตรมาสที่ '
                || TO_CHAR(TO_DATE('01/'
                                   || m.month_id
                                   || '/'
                                   || m.caldr_year, 'dd/mm/yyyy'), 'Q') AS quater_long_name,
                m.month_id   AS month_id,
                TO_CHAR(TO_DATE('01/'
                                || m.month_id
                                || '/'
                                || m.caldr_year, 'dd/mm/yyyy'), 'MON') AS month_short_name,
                TO_CHAR(TO_DATE('01/'
                                || m.month_id
                                || '/'
                                || m.caldr_year, 'dd/mm/yyyy'), 'MONTH') AS month_long_name,
                m.region_no,
                m.region_name,
                m.off_id,
                m.off_name,
                m.cert_status_cd,
                s.cert_status,
                NULL AS cert_reason_status_cd,
                NULL AS cert_reason_status,
                'A' AS cert_cnt_status,
                cert_cnt     AS cert_cnt,
                cert_pert,
                SYSDATE      create_dtm,
                'CAL8' create_user_id
            FROM
                (
                    SELECT
                        caldr_year,
                        TO_CHAR(trunc(SYSDATE), 'mm') AS month_id,
                        region_no,
                        region_name,
                        off_id,
                        off_name,
                        cert_status_cd,
                        'A' reqt_cnt_status,
                        SUM(cert_cnt) cert_cnt,
                        100 cert_pert
                    FROM
                        rept_manage_cert_status tr
                    WHERE
                        caldr_year = TO_CHAR(r.month_year, 'yyyy') + 543
                        AND month_id <= TO_CHAR(trunc(r.month_year), 'mm')
                        AND month_id != 13
                        AND tr.cert_cnt_status = 'N'
                    GROUP BY
                        caldr_year,
                        region_no,
                        region_name,
                        off_id,
                        off_name,
                        cert_status_cd
                ) m
                INNER JOIN cert_status s ON m.cert_status_cd = s.cert_status_cd;

    END LOOP;
END;