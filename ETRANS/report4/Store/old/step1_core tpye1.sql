select TO_CHAR(core.month_year, 'yyyy') + 543 AS caldr_year,
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
        core.manage_type_cd,
        core.manage_type_desc,
        core.imp_doc_type_cd,
        core.imp_doc_type_desc,
        nvl(cur.imp_doc_cur_year_cnt, 0) AS imp_doc_cur_year_cnt,
        NULL AS imp_doc_cur_year_pert,
        nvl(pr.imp_doc_prior_year_cnt, 0) AS imp_doc_prior_year_cnt,
        NULL AS imp_doc_prior_year_pert,
        SYSDATE   AS create_dtm,
        'RAW' AS create_user_id
FROM
        (
            SELECT
                r.region_no,
                r.region_name,
                t.month_year,
                m.manage_type_cd,
                m.manage_type_desc,
                im.imp_doc_type_cd,
                im.imp_doc_type_desc
            FROM
                region_mas r
                CROSS JOIN (
                    SELECT
                        trunc(to_date('01/01/2018','dd/mm/yyyy'), 'mm') month_year
                    FROM
                        dual
                ) t
                CROSS JOIN manage_type m
                CROSS JOIN imp_doc_type im
        ) core
        LEFT JOIN (SELECT
    dc.month_year,
                f.region_no,
                1 as manage_type_cd,
                COUNT(*) imp_doc_cur_year_cnt
FROM
    (
        SELECT
            trunc(created_date, 'mm') month_year,
            office_code,
            COUNT(*)
        FROM
            sign_log
--where trunc(created_date) = date_in
        GROUP BY
            office_code,
            trunc(created_date, 'mm')
    ) dc
    INNER JOIN region_off f ON TO_CHAR(dc.office_code) = f.off_id
GROUP BY
    dc.month_year,
    f.region_no) cur
    on cur.month_year = core.month_year
                 AND cur.region_no = core.region_no
                 AND cur.manage_type_cd = core.manage_type_cd
                 LEFT JOIN (
SELECT
    dc.month_year,
                f.region_no,
                1 as manage_type_cd,
                COUNT(*) imp_doc_prior_year_cnt
FROM
    (
        SELECT
            trunc(created_date, 'mm') month_year,
            office_code,
            COUNT(*)
        FROM
            sign_log
--where trunc(created_date) = add_months(date_in, - 12)
        GROUP BY
            office_code,
            trunc(created_date, 'mm')
    ) dc
    INNER JOIN region_off f ON TO_CHAR(dc.office_code) = f.off_id
GROUP BY
    dc.month_year,
    f.region_no
    ) pr ON pr.month_year = core.month_year
                AND pr.region_no = core.region_no
                AND pr.manage_type_cd = core.manage_type_cd;