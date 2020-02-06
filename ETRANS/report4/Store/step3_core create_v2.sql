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
                DISTINCT r.region_id,
                r.region_name,
                t.month_year,
                m.id as manage_type_cd,
                m.manage_type_name as manage_type_desc,
                im.system_id as imp_doc_type_cd,
                im.system_name_th as imp_doc_type_desc
            FROM
                (select * from
                mst_office where region_id is not null) r
                CROSS JOIN (
                    SELECT
                        trunc(TO_DATE('01/07/2018', 'dd/mm/yyyy'), 'mm') month_year
                    FROM
                        dual
                ) t
                CROSS JOIN (select * from mst_manage_type where id = '1') m
                CROSS JOIN mst_doc_type im
        ) core
        LEFT JOIN (
            SELECT
                dc.month_year,
                ms.region_id,
                3 AS manage_type_cd,
                dc.doc_type,
                COUNT(*) imp_doc_cur_year_cnt
            FROM
                (
                    SELECT
                        trunc(created_date, 'mm') month_year,
                        dept_id,
                        doc_type
                    FROM
                        ETR_doc_hist
                    WHERE
                        trunc(created_date, 'mon') = trunc(SYSDATE, 'mon')
--                        AND print_status = '0' and request_status = 0
                ) dc
                INNER JOIN mst_office ms ON LPAD(dc.dept_id,'6','0') = ms.offcode
            GROUP BY
                dc.month_year,
                ms.region_id,
                dc.doc_type
        ) cur ON cur.month_year = core.month_year
                 AND cur.region_id = core.region_id
                 AND cur.doc_type = core.imp_doc_type_desc
                 AND cur.manage_type_cd = core.manage_type_cd
        LEFT JOIN (
            SELECT
                dc.month_year,
                ms.region_id,
                2 AS manage_type_cd,
                dc.doc_type,
                COUNT(*) imp_doc_prior_year_cnt
            FROM
                (
                    SELECT
                        add_months(trunc(created_date, 'mm'),12) as month_year,
                        dept_id,
                        doc_type
                    FROM
                        ETR_doc_hist
                    WHERE
                        trunc(created_date, 'mon') = add_months(trunc(SYSDATE, 'mon'),-12)
--                        AND print_status = '0' and request_status = 0
                ) dc
                INNER JOIN mst_office ms ON LPAD(dc.dept_id,'6','0') = ms.offcode
            GROUP BY
                dc.month_year,
                ms.region_id,
                dc.doc_type
        ) pr ON pr.month_year = core.month_year
                 AND pr.region_id = core.region_id
                 AND pr.doc_type = core.imp_doc_type_desc
                 AND pr.manage_type_cd = core.manage_type_cd