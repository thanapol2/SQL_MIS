SELECT
    ROWNUM,
    d.tran_date,
    d.userid,
    d.access_cus_cnt
FROM
    (
        SELECT
            tran_date,
            userid,
            COUNT(*) AS access_cus_cnt
        FROM
            sso.tran_log
--    WHERE  trunc(tran_log, 'mon') = date_start
        GROUP BY
            tran_date,
            userid
        ORDER BY
            access_cus_cnt DESC
    ) d
WHERE
    ROWNUM <= 10;


select *
from (
SELECT DISTINCT
    tran_date,
    userid
FROM
    sso.tran_log
--WHERE  trunc(tran_log) between date_start and date_end
)