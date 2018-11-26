INSERT INTO rept_imp_trans_doc (
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
    manage_type_cd,
    manage_type_desc,
    imp_doc_type_cd,
    imp_doc_type_desc,
    imp_doc_cur_year_cnt,
    imp_doc_cur_year_pert,
    imp_doc_prior_year_cnt,
    imp_doc_prior_year_pert,
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
                        trunc(TO_DATE('01/07/2018', 'dd/mm/yyyy'), 'mm') month_year
                    FROM
                        dual
                ) t
                CROSS JOIN manage_type m
                CROSS JOIN imp_doc_type im
        ) core
        LEFT JOIN (
            SELECT
                dc.month_year,
                f.region_no,
                3 AS manage_type_cd,
                dc.doc_type,
                COUNT(*) imp_doc_cur_year_cnt
            FROM
                (
                    SELECT
                        trunc(created_date, 'mm') month_year,
                        username,
                        doc_type
                    FROM
                        doc_hist
                    WHERE
                        trunc(created_date, 'mm') = TO_DATE('01/07/2018', 'dd/mm/yyyy')
                        AND print_status = '1'
                ) dc
                INNER JOIN app_user ap ON dc.username = ap.username
                INNER JOIN region_off f ON ap.off_id = f.off_id
            GROUP BY
                dc.month_year,
                f.region_no,
                dc.doc_type
        ) cur ON cur.month_year = core.month_year
                 AND cur.region_no = core.region_no
                 AND cur.doc_type = core.imp_doc_type_desc
                 AND cur.manage_type_cd = core.manage_type_cd
        LEFT JOIN (
            SELECT
                dc.month_year,
                f.region_no,
                3 AS manage_type_cd,
                dc.doc_type,
                COUNT(*) imp_doc_prior_year_cnt
            FROM
                (
                    SELECT
                        trunc(created_date, 'mm') month_year,
                        username,
                        doc_type
                    FROM
                        doc_hist
                    WHERE
                        trunc(created_date, 'mm') = add_months(TO_DATE('01/07/2018', 'dd/mm/yyyy'), - 12)
                        AND print_status = '1'
                ) dc
                INNER JOIN app_user ap ON dc.username = ap.username
                INNER JOIN region_off f ON ap.off_id = f.off_id
            GROUP BY
                dc.month_year,
                f.region_no,
                dc.doc_type
        ) pr ON pr.month_year = core.month_year
                AND pr.region_no = core.region_no
                AND pr.doc_type = core.imp_doc_type_desc
                AND pr.manage_type_cd = core.manage_type_cd;