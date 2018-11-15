--date
SELECT
    d.created_date,
    TO_CHAR(d.created_date, 'yyyy') + 543 AS caldr_year,
    TO_CHAR(trunc(add_months(d.created_date, 6516), 'yyyy'), 'dd-MON-YYYY') AS start_date,
    TO_CHAR(trunc(add_months(d.created_date, 6528), 'yyyy') - 1, 'dd-MON-YYYY') AS end_date,
    TO_CHAR(d.created_date, 'Q') AS quater_id,
    '????????? '
    || TO_CHAR(d.created_date, 'Q') AS quater_short_name,
    '?? '
    || TO_CHAR(TO_CHAR(d.created_date, 'yyyy') + 543)
    || ' ????????? '
    || TO_CHAR(d.created_date, 'Q') AS quater_long_name,
    TO_CHAR(d.created_date, 'MM') as month_id,
    TO_CHAR(d.created_date, 'MON') as month_short_name,
    TO_CHAR(d.created_date, 'MONTH') as month_long_name
FROM
    (
        SELECT
            TO_DATE('01/01/2018', 'dd/mm/yyyy') created_date
        FROM
            dual
    )d;
--------------------------------
SELECT
    tr.created_date,
    TO_CHAR(tr.created_date, 'yyyy') + 543 AS caldr_year,
    TO_CHAR(trunc(add_months(tr.created_date, 6516), 'yyyy'), 'dd-MON-YYYY') AS start_date,
    TO_CHAR(trunc(add_months(tr.created_date, 6528), 'yyyy') - 1, 'dd-MON-YYYY') AS end_date,
    TO_CHAR(tr.created_date, 'Q') AS quater_id,
    '????????? '
    || TO_CHAR(tr.created_date, 'Q') AS quater_short_name,
    '?? '
    || TO_CHAR(TO_CHAR(tr.created_date, 'yyyy') + 543)
       || ' ????????? '
          || TO_CHAR(tr.created_date, 'Q') AS quater_long_name,
    tr.dept_id,
    tr.off_id,
    'none' AS off_name,
    'none' AS status_cd,
    tr.status,
    'A' AS reqt_cnt_status
--    count(tr.status) as reqt_cnt,
--    count(tr.status)*100 as reqt_pert
FROM
    token_request tr
--group by tr.dept_id,tr.off_id,tr.status