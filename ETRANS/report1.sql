--date
SELECT
    d.created_date,
    TO_CHAR(d.created_date, 'yyyy') + 543 AS caldr_year,
    TO_CHAR(trunc(add_months(d.created_date, 6516), 'yyyy'), 'dd-MON-YYYY') AS start_date,
    TO_CHAR(trunc(add_months(d.created_date, 6528), 'yyyy') - 1, 'dd-MON-YYYY') AS end_date,
    TO_CHAR(d.created_date, 'Q') AS quater_id,
    'ไตรมาสที่ '
    || TO_CHAR(d.created_date, 'Q') AS quater_short_name,
    'ปี '
    || TO_CHAR(TO_CHAR(d.created_date, 'yyyy') + 543)
    || ' ไตรมาสที่ '
    || TO_CHAR(d.created_date, 'Q') AS quater_long_name,
    TO_CHAR(d.created_date, 'MM') AS month_id,
    TO_CHAR(d.created_date, 'MON') AS month_short_name,
    TO_CHAR(d.created_date, 'MONTH') AS month_long_name
FROM
    (
        SELECT
            TO_DATE('01/01/2018', 'dd/mm/yyyy') created_date
        FROM
            dual
    ) d;
--------------------------------
-- all list

SELECT
    de.month_year,
    de.dept_id,
    md.dept_name,
    de.off_id,
    'none' off_name,
    'none' status_code,
    de.status   AS status_desc,
    'N' reqt_cnt_status,
    reqt_cnt,
    reqt_cnt * 100 / reqt_all reqt_pert
FROM
    (
        SELECT
            month_year,
            tr.dept_id,
            tr.off_id,
            tr.status,
            COUNT(status) reqt_cnt
        FROM
            (
                SELECT
                    trunc(created_date, 'mon') month_year,
                    dept_id,
                    off_id,
                    status
                FROM
                    token_request
--                    where  trunc(created_date, 'mon') = 
            ) tr
        GROUP BY
            month_year,
            dept_id,
            off_id,
            status
    ) de
    INNER JOIN (
        SELECT
            trunc(created_date, 'mon') month_year,
            dept_id,
            off_id,
            COUNT(*) reqt_all
        FROM
            token_request
        GROUP BY
            trunc(created_date, 'mon'),
            dept_id,
            off_id
    ) al ON de.month_year = al.month_year
            AND de.dept_id = al.dept_id
            AND de.off_id = al.off_id
    INNER JOIN mst_dept md ON de.dept_id = md.dept_id;

--  sum year
SELECT
    de.month_year,
    de.dept_id,
    md.dept_name,
    de.off_id || 99 off_id,
    'รวม'||'none' off_name,
    'none' status_code,
    de.status   AS status_desc,
    'N' reqt_cnt_status,
    reqt_cnt,
    reqt_cnt * 100 / reqt_all reqt_pert
FROM
    (
        SELECT
            month_year,
            tr.dept_id,
            tr.off_id,
            tr.status,
            COUNT(status) reqt_cnt
        FROM
            (
                SELECT
                    trunc(created_date, 'year') month_year,
                    dept_id,
                    off_id,
                    status
                FROM
                    token_request
            ) tr
        GROUP BY
            month_year,
            dept_id,
            off_id,
            status
    ) de
    INNER JOIN (
        SELECT
            trunc(created_date, 'year') month_year,
            dept_id,
            off_id,
            COUNT(*) reqt_all
        FROM
            token_request
        GROUP BY
            trunc(created_date, 'year'),
            dept_id,
            off_id
    ) al ON de.month_year = al.month_year
            AND de.dept_id = al.dept_id
            AND de.off_id = al.off_id
    INNER JOIN mst_dept md ON de.dept_id = md.dept_id;
-- depart sum office 999999
SELECT
    de.month_year,
    de.dept_id,
    md.dept_name,
    '999999' off_id,
    'รวมสรรพสามิตพื้นที่ ภาคที่ '|| de.dept_id off_name,
    'none' status_code,
    de.status   AS status_desc,
    'N' reqt_cnt_status,
    reqt_cnt,
    reqt_cnt * 100 / reqt_all reqt_pert
FROM
    (
        SELECT
            month_year,
            tr.dept_id,
            tr.status,
            COUNT(status) reqt_cnt
        FROM
            (
                SELECT
                    trunc(created_date, 'mon') month_year,
                    dept_id,
                    status
                FROM
                    token_request
            ) tr
        GROUP BY
            month_year,
            dept_id,
            status
    ) de
    INNER JOIN (
        SELECT
            trunc(created_date, 'mon') month_year,
            dept_id,
            COUNT(*) reqt_all
        FROM
            token_request
        GROUP BY
            trunc(created_date, 'mon'),
            dept_id
    ) al ON de.month_year = al.month_year
            AND de.dept_id = al.dept_id
    INNER JOIN mst_dept md ON de.dept_id = md.dept_id;
    
-- sum all
SELECT
    de.month_year,
    '99' dept_id,
    'ทั่วประเทศ' dept_name,
    '999999' off_id,
    'ทั่วประเทศ' off_name,
    'none' status_code,
    de.status   AS status_desc,
    'N' reqt_cnt_status,
    reqt_cnt,
    reqt_cnt * 100 / reqt_all reqt_pert
FROM
    (
        SELECT
            month_year,
            tr.status,
            COUNT(status) reqt_cnt
        FROM
            (
                SELECT
                    trunc(created_date, 'mon') month_year,
                    status
                FROM
                    token_request
            ) tr
        GROUP BY
            month_year,
            status
    ) de
    INNER JOIN (
        SELECT
            trunc(created_date, 'mon') month_year,
            COUNT(*) reqt_all
        FROM
            token_request
        GROUP BY
            trunc(created_date, 'mon')
    ) al ON de.month_year = al.month_year;
    
-- Type A
