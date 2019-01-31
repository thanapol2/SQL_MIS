-- SUM IMP_DOC_TYPE yearly all region all status
CREATE OR REPLACE PROCEDURE rept_imp_step5 (
    caldr_year_in IN   NUMBER
--    B.C.
) IS
BEGIN
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
            9 AS quater_id,
            'รวม ทุกไตรมาส' AS quater_short_name,
            'ปี '
            || core.caldr_year
            || ' รวม ทุกไตรมาส' AS quater_long_name,
            13 AS month_id,
            'รวมทั้งหมด' AS month_short_name,
            'รวมทั้งหมด' AS month_long_name,
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
            SYSDATE   AS create_dtm,
            'CAL5' AS create_user_id
        FROM
            (
                SELECT
                    caldr_year_in   AS caldr_year,
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
                    manage_type_cd,
                    SUM(imp_doc_cur_year_cnt) AS imp_doc_cur_year_cnt,
                    SUM(imp_doc_prior_year_cnt) AS imp_doc_prior_year_cnt
                FROM
                    rept_imp_trans_doc
                WHERE
                    caldr_year = caldr_year_in
                    AND create_user_id = 'RAW'
                GROUP BY
                    caldr_year,
                    manage_type_cd
            ) cur ON cur.caldr_year = core.caldr_year
                     AND cur.manage_type_cd = core.manage_type_cd;

END;