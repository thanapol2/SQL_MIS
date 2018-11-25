    INSERT INTO rept_req_cert_status (
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
        status_code,
        status_desc,
        reqt_cnt_status,
        reqt_cnt,
        reqt_pert,
        create_dtm,
        create_user_id
    )
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
            d.region_no,
            d.region_name,
            d.off_id,
            d.off_name,
            d.status_code,
            d.status_desc,
            'N' reqt_cnt_status,
            reqt_all   reqt_cnt,
            100 reqt_pert,
            SYSDATE    create_dtm,
            'RAW' create_user_id
        FROM
            (
                SELECT
                    all_region.off_id,
                    all_region.off_name,
                    all_region.region_no,
                    all_region.region_name,
                    all_region.month_year,
                    s.status_code,
                    s.status_desc,
                    nvl(cal.reqt_all, 0) reqt_all
                FROM
                    (
                        SELECT
                            r.off_id,
                            r.off_name,
                            r.region_no,
                            r.region_name,
                            t.month_year
                        FROM
                            region_off r
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
                            COUNT(*) reqt_all
                        FROM
                            (
                                SELECT
                                    trunc(created_date, 'mon') month_year,
                                    tr.off_id
                                FROM
                                    token_request tr
                                WHERE
                                    trunc(created_date, 'mon') <= trunc(SYSDATE)
--                    trunc(created_date, 'mon') between add_months(trunc(SYSDATE),-4)and trunc(SYSDATE)
                            ) tr
                        GROUP BY
                            month_year,
                            off_id
                    ) cal ON cal.month_year = all_region.month_year
                             AND cal.off_id = all_region.off_id
                    CROSS JOIN status s
                WHERE
                    s.status_code = '1'
            ) d;
    
        