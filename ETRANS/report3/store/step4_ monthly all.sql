    INSERT
    INTO rept_extend_cert_status (
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
        cert_extend_cd,
        cert_extend_status,
        cert_cnt,
        cert_pert,
        create_dtm,
        create_user_id
    )
SELECT
--    d.month_year,
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
           99 AS region_no,
           'ทั่วประเทศ' AS region_name,
           core.cert_extend_cd,
           c.cert_extend_status,
           core.cert_cnt,
           100 AS cert_pert,
           SYSDATE         create_dtm,
           'STEP4' create_user_id
       FROM
           (
               SELECT
                   cert_extend_cd,
                   caldr_year,
                   month_id,
                   SUM(cert_cnt) cert_cnt
               FROM
                   rept_extend_cert_status
               WHERE
                   create_user_id = 'RAW'
                   and month_id = TO_CHAR(trunc(TO_DATE('01/02/2019', 'dd/mm/yyyy'), 'mm'), 'mm')
                   AND caldr_year = TO_CHAR(trunc(TO_DATE('01/02/2019', 'dd/mm/yyyy'), 'yyyy'), 'yyyy') + 543
               GROUP BY
                   cert_extend_cd,
                   month_id,
                   caldr_year
           ) core
           INNER JOIN cert_extend c ON core.cert_extend_cd = c.cert_extend_cd