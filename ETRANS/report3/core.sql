select *
from (select *
from TOKEN_REQUEST
where STATUS = 'APPROVE'
--and MONTHS_BETWEEN(trunc(to_date('01/02/2019','dd/mm/yyyy')),updated_Date) between 10 and 12
) tr
inner join TOKEN_HIST th
on th.username = tr.username
--and th.CANCEL_CAUSE	='2'
--and th.created_date between add_months(tr.updated_Date,-1) and add_months(tr.updated_Date,1)
INNER JOIN mst_dept md
ON tr.dept_id = md.dept_id;

