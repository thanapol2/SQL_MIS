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
--            round(nvl(reqt_cnt/reqt_all*100,0),2) reqt_pert,
    SYSDATE            create_dtm,
    'RAW' create_user_id
            from ( 
            SELECT
    all_region.offcode,
    all_region.offname,
    all_region.region_id,
    all_region.region_name,
    all_region.month_year,
    all_region.status_code,
    'REQUEST' status_name_EN,
    nvl(cal.reqt_cnt, 0) reqt_cnt
FROM
    (
        SELECT
            r.offcode,
            r.offname,
            r.region_id,
            r.region_name,
            t.month_year,
            '4' as status_code
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
    LEFT JOIN (
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
                                   ( (step_request = '2' and ca_status = '3') or (step_request='3' and ca_status = '3'))
                                    and trunc(created_date, 'mon') <= trunc(SYSDATE)
--                    trunc(created_date, 'mon') between add_months(trunc(SYSDATE),-4)and trunc(SYSDATE)
                            ) tr
                        GROUP BY
                            month_year,
                            off_id
                    ) cal ON cal.month_year = all_region.month_year
                             AND cal.off_id = all_region.offcode) d