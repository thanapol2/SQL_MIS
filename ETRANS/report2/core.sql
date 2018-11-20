SELECT
    trunc(th.created_date, 'mon') month_year,
    th.ca_status,
    th.cancel_cause,
    au.dept_id,
    au.off_id,
    count(*)
FROM
    token_hist th
    INNER JOIN app_user au ON th.username = au.username
GROUP BY
    th.ca_status,
    th.cancel_cause,
    trunc(th.created_date, 'mon'),
    au.dept_id,
    au.off_id