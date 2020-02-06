SELECT
--    d.month_year,
    TO_CHAR(d.month_year, 'yyyy') + 543 AS caldr_year,
    trunc(add_months(d.month_year, 6516), 'yyyy') AS start_date,
    trunc(add_months(d.month_year, 6528), 'yyyy') - 1 AS end_date,
    trunc(SYSDATE) update_date,
    TO_CHAR(d.month_year, 'Q') AS quater_id,
    'ไตรมาสที่ '
    || TO_CHAR(d.month_year, 'Q') AS quater_short_name,
    'ปี '
    || TO_CHAR(TO_CHAR(d.month_year, 'yyyy') + 543)
    || ' ไตรมาสที่ '
    || TO_CHAR(d.month_year, 'Q') AS quater_long_name,
    TO_CHAR(d.month_year, 'MM') AS month_id,
    TO_CHAR(d.month_year, 'MON') AS month_short_name,
    TO_CHAR(d.month_year, 'MONTH') AS month_long_name,
    d.region_id        AS region_no,
    d.region_name,
    d.offcode          AS off_id,
    d.offname          AS off_name,
    d.status_code,
    d.status_name_en   AS status_desc,
    'N' reqt_cnt_status,
    reqt_cnt           reqt_cnt,
    round(nvl(reqt_cnt / reqt_all * 100, 0), 2) reqt_pert,
    SYSDATE            create_dtm,
    'RAW' create_user_id
FROM
    (
        SELECT
            all_region.offcode,
            all_region.offname,
            all_region.region_id,
            all_region.region_name,
            all_region.month_year,
            all_region.status_code,
            s.status_name_en,
            nvl(cal.reqt_cnt, 0) reqt_cnt,
            reqt_all
        FROM
            (
                SELECT
                    r.offcode,
                    r.offname,
                    r.region_id,
                    r.region_name,
                    t.month_year,
                    '1' AS status_code
                FROM
                    mst_office r
                    CROSS JOIN (
                        WITH t AS (
                            SELECT
                                DATE '2018-01-01' start_date,
--                        add_months(trunc(SYSDATE),-4) start_date,
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
            ) all_region
            INNER JOIN mst_status_code s ON all_region.status_code = s.id
            LEFT JOIN (
                SELECT
                    m_cal.*,
                    reqt_all
                FROM
                    (
                        SELECT
                            month_year,
                            tr.off_id,
                            COUNT(*) reqt_cnt
                        FROM
                            (
                                SELECT
                                    trunc(created_date, 'mon') month_year,
                                    tr.off_id
                                FROM
                                    etr_token_request tr
                                WHERE
--                                  Approve
                                    ( ( step_request = '2'
                                        AND ca_status = '3' )
                                      OR ( step_request = '3'
                                           AND ca_status = '3' ) )
                                    AND trunc(created_date, 'mon') <= trunc(SYSDATE)
--                    trunc(created_date, 'mon') between add_months(trunc(SYSDATE),-4)and trunc(SYSDATE)
                            ) tr
                        GROUP BY
                            month_year,
                            off_id
                    ) m_cal
                    INNER JOIN (
                        SELECT
                            month_year,
                            tr.off_id,
                            COUNT(*) reqt_all
                        FROM
                            (
                                SELECT
                                    trunc(created_date, 'mon') month_year,
                                    tr.off_id
                                FROM
                                    etr_token_request tr
                                WHERE
                                    trunc(created_date, 'mon') <= trunc(SYSDATE)
--                    trunc(created_date, 'mon') between add_months(trunc(SYSDATE),-4)and trunc(SYSDATE)
                            ) tr
                        GROUP BY
                            month_year,
                            off_id
                    ) all_cal ON m_cal.month_year = all_cal.month_year
                                 AND m_cal.off_id = all_cal.off_id
            ) cal ON cal.month_year = all_region.month_year
                     AND cal.off_id = all_region.offcode
    ) d