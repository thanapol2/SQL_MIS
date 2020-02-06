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
        TO_CHAR(core.month_year, 'yyyy') + 543 AS caldr_year,
        trunc(add_months(core.month_year, 6516), 'yyyy') AS start_date,
        trunc(add_months(core.month_year, 6528), 'yyyy') - 1 AS end_date,
        trunc(SYSDATE) update_date,
        TO_CHAR(core.month_year, 'Q') AS quater_id,
        'ไตรมาสที่ '
        || TO_CHAR(core.month_year, 'Q') AS quater_short_name,
        'ปี '
        || TO_CHAR(TO_CHAR(core.month_year, 'yyyy') + 543)
        || ' ไตรมาสที่ '
        || TO_CHAR(core.month_year, 'Q') AS quater_long_name,
        TO_CHAR(core.month_year, 'MM') AS month_id,
        TO_CHAR(core.month_year, 'MON') AS month_short_name,
        TO_CHAR(core.month_year, 'MONTH') AS month_long_name,
        core.region_no,
        core.region_name,
        core.off_id,
        core.off_name,
        core.cert_status_cd,
        core.cert_status,
        NULL AS cert_reason_status_cd,
        NULL AS cert_reason_status,
        'N' AS cert_cnt_status,
        nvl(reqt_all, 0) AS cert_cnt,
        NULL cert_pert,
        SYSDATE   create_dtm,
        'RAW' create_user_id
    FROM
        (
            SELECT
                r.off_id,
                r.off_name,
                r.region_no,
                r.region_name,
                t.month_year,
                cs.cert_status_cd,
                cs.cert_status
            FROM
                region_off r
                CROSS JOIN (
                    WITH t AS (
                        SELECT
                  DATE '2018-01-01' start_date,
--                            add_months(trunc(SYSDATE), - 10) start_date,
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
                ) t
                CROSS JOIN cert_status cs
        ) core
        LEFT JOIN (
            SELECT
                month_year,
                tr.off_id,
                ca_status,
                COUNT(*) reqt_all
            FROM
                (
                    SELECT
                        trunc(created_date, 'mon') month_year,
                        ca_status,
                        tr.off_id
                    FROM
                        token_request tr
                    WHERE
                        trunc(created_date, 'mon') <= trunc(SYSDATE)
--                    trunc(created_date, 'mon') between add_months(trunc(SYSDATE),-4)and trunc(SYSDATE)
                ) tr
            GROUP BY
                month_year,
                off_id,
                ca_status
        ) t ON core.off_id = t.off_id
               AND core.month_year = t.month_year
               AND core.cert_status_cd = t.ca_status;