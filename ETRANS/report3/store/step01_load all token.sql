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
        core.region_id as region_no,
        core.region_name,
        core.id as cert_status_cd,
        core.cert_status_name_th as cert_status,
        nvl(cert_cnt, 0) AS cert_cnt,
        NULL cert_pert,
        SYSDATE   create_dtm,
        'RAW' create_user_id
    FROM
        (
            SELECT
                DISTINCT r.region_cd,
                r.region_name,
                t.month_year,
                cs.id,
                cs.cert_status_name_th
            FROM
                (select * from
                mst_office where region_id is not null) r
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
                CROSS JOIN (select * from mst_cert_status where id in ('2','4')) cs 
        ) core
        LEFT JOIN (
            SELECT
                month_year,
                tr.region_id,
                ca_status,
                COUNT(*) cert_cnt
            FROM
                (
                    SELECT
                        trunc(created_date, 'mon') month_year,
                        ca_status,
                        mo.region_id
                    FROM
                        etr_token_request tr
                        inner join mst_office mo
                        on mo.offcode = tr.off_id
                    WHERE
                        trunc(created_date, 'mon') <= trunc(SYSDATE) and
--                    trunc(created_date, 'mon') between add_months(trunc(SYSDATE),-4)and trunc(SYSDATE)
--                        add new condition
                    (CA_STATUS in ('4'))or(CA_STATUS in ('2')and CA_expiry_date>sysdate)

                ) tr
            GROUP BY
                month_year,
                region_id,
                ca_status
        ) t ON core.region_id = t.region_id
               AND core.month_year = t.month_year
               AND core.id = t.ca_status;