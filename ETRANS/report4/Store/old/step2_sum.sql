SELECT
    core.caldr_year,
    TO_DATE('01/01/' || core.caldr_year, 'dd/mm/YYYY') AS start_date,
    TO_DATE('31/12/' || core.caldr_year, 'dd/mm/YYYY') AS end_date,
    trunc(SYSDATE) update_date,
    TO_CHAR(TO_DATE('01/'
                    || core.month_id
                    || '/'
                    || core.caldr_year, 'dd/mm/yyyy'), 'Q') AS quater_id,
    'ไตรมาสที่ '
    || TO_CHAR(TO_DATE('01/'
                       || core.month_id
                       || '/'
                       || core.caldr_year, 'dd/mm/yyyy'), 'Q') AS quater_short_name,
    'ปี '
    || core.caldr_year
    || ' ไตรมาสที่ '
    || TO_CHAR(TO_DATE('01/'
                       || core.month_id
                       || '/'
                       || core.caldr_year, 'dd/mm/yyyy'), 'Q') AS quater_long_name,
    core.month_id   AS month_id,
    TO_CHAR(TO_DATE('01/'
                    || core.month_id
                    || '/'
                    || core.caldr_year, 'dd/mm/yyyy'), 'MON') AS month_short_name,
    TO_CHAR(TO_DATE('01/'
                    || core.month_id
                    || '/'
                    || core.caldr_year, 'dd/mm/yyyy'), 'MONTH') AS month_long_name,
    core.region_no,
    core.region_name,
    core.manage_type_cd,
    core.manage_type_desc,
    core.imp_doc_type_cd,
    core.imp_doc_type_desc,
    nvl(cur.imp_doc_cur_year_cnt, 0) AS imp_doc_cur_year_cnt,
    NULL AS imp_doc_cur_year_pert,
    nvl(cur.imp_doc_prior_year_cnt, 0) AS imp_doc_prior_year_cnt,
    NULL AS imp_doc_prior_year_pert,
    SYSDATE         AS create_dtm,
    'RAW' AS create_user_id
FROM
    (
        SELECT
            TO_CHAR(TO_DATE('01/07/2018', 'dd/mm/yyyy'), 'yyyy') + 543 AS caldr_year,
            TO_CHAR(trunc(TO_DATE('01/07/2018', 'dd/mm/yyyy')), 'mm') AS month_id,
            99 AS region_no,
            'ทั่วประเทศ' AS region_name,
            m.manage_type_cd,
            m.manage_type_desc,
            im.imp_doc_type_cd,
            im.imp_doc_type_desc
        FROM
            manage_type m
            CROSS JOIN imp_doc_type im
    ) core
    LEFT JOIN (
        SELECT
            caldr_year,
            month_id,
            manage_type_cd,
            imp_doc_type_cd,
            SUM(imp_doc_cur_year_cnt) AS imp_doc_cur_year_cnt,
            SUM(imp_doc_prior_year_cnt) AS imp_doc_prior_year_cnt
        FROM
            rept_imp_trans_doc
        WHERE
            caldr_year = TO_CHAR(TO_DATE('01/07/2018', 'dd/mm/yyyy'), 'yyyy') + 543
            AND month_id = TO_CHAR(trunc(TO_DATE('01/07/2018', 'dd/mm/yyyy')), 'mm')
        GROUP BY
            caldr_year,
            month_id,
            manage_type_cd,
            imp_doc_type_cd
    ) cur ON cur.month_id = core.month_id
             AND cur.caldr_year = core.caldr_year
             AND cur.imp_doc_type_cd = core.imp_doc_type_cd
             AND cur.manage_type_cd = core.manage_type_cd;