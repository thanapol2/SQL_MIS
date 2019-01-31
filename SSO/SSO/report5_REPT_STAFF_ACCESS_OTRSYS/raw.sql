SELECT
--    d.month_year,
    TO_CHAR(d.tran_date, 'yyyy') + 543 AS caldr_year,
    trunc(add_months(d.tran_date, 6516), 'yyyy') AS start_date,
    trunc(add_months(d.tran_date, 6528), 'yyyy') - 1 AS end_date,
    trunc(SYSDATE) update_date,
    TO_CHAR(d.tran_date, 'Q') AS quater_id,
    'ไตรมาสที่ '
    || TO_CHAR(d.tran_date, 'Q') AS quater_short_name,
    'ปี '
    || TO_CHAR(TO_CHAR(d.tran_date, 'yyyy') + 543)
    || ' ไตรมาสที่ '
    || TO_CHAR(d.tran_date, 'Q') AS quater_long_name,
    TO_CHAR(d.tran_date, 'MM') AS month_id,
    TO_CHAR(d.tran_date, 'MON') AS month_short_name,
    TO_CHAR(d.tran_date, 'MONTH') AS month_long_name,
    '' AS region_no,
    '' AS region_name,
    '' as dept_code,
    dept_desc,
    '' AS ACCESS_USER_STATUS_CODE,
    '' as ACCESS_USER_STATUS,
    access_user_type,
    USERID_STAFF_CNT,
    rank,
    SYSDATE   AS create_dtm,
    'RAW' AS create_user_id
FROM
    (
select all.month_year,
all.dept,
(d.USERID_STAFF_CNT/all.USERID_STAFF_CNT_all)*100 as STATUS_BY_DEPT_PERT
from
(select trunc(sysdate,'mm') month_year,dept,count(*) USERID_STAFF_CNT_all
from sso.ed_regis
group by dept,activateflag ) all
inner join (select trunc(sysdate,'mm') month_year,dept,activateflag,count(*) USERID_STAFF_CNT
from sso.ed_regis
group by dept,activateflag) d
on all.dept = d.dept)d
