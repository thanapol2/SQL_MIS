create or replace PROCEDURE REPT_IMP_STEP4  (
    caldr_year_in in NUMBER,
    month_id_in  in  NUMBER
--    B.C.
) IS
BEGIN
    --    insert data case 3
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
            999 as imp_doc_type_cd,
            'All Status' as imp_doc_type_desc,
            nvl(cur.imp_doc_cur_year_cnt, 0) AS imp_doc_cur_year_cnt,
            NULL AS imp_doc_cur_year_pert,
            nvl(cur.imp_doc_prior_year_cnt, 0) AS imp_doc_prior_year_cnt,
            NULL AS imp_doc_prior_year_pert,
            SYSDATE         AS create_dtm,
            'CAL4' AS create_user_id
        FROM
            (
                SELECT
                    caldr_year_in AS caldr_year,
                    month_id_in AS month_id,
                    99 AS region_no,
                    'ทั่วประเทศ' AS region_name,
                    m.manage_type_cd,
                    m.manage_type_desc
                FROM
                    manage_type m
            ) core
            LEFT JOIN (
                SELECT
                    caldr_year,
                    month_id,
                    manage_type_cd,
                    SUM(imp_doc_cur_year_cnt) AS imp_doc_cur_year_cnt,
                    SUM(imp_doc_prior_year_cnt) AS imp_doc_prior_year_cnt
                FROM
                    rept_imp_trans_doc
                WHERE
                    caldr_year = caldr_year_in
                    AND month_id = month_id_in
                    AND create_user_id = 'RAW'
                GROUP BY
                    caldr_year,
                    month_id,
                    manage_type_cd
            ) cur ON cur.month_id = core.month_id
                     AND cur.caldr_year = core.caldr_year
                     AND cur.manage_type_cd = core.manage_type_cd;

END;