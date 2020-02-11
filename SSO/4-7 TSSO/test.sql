select tu.user_id
from tsso_user tu
inner join tsso_user_company tsc
on tu.user_id = tsc.user_id;

select tr.company_name,tc.company_name
from tsso_registe tr
inner join tsso_company tc
on tr.company_tin_id = tc.company_tin_id;


select count(*)
from (
select DISTINCT company_tin_id
from tsso_company);

select count(*)
from (
select DISTINCT COMPANY_ID
from tsso_company);

select count(*)
from (select DISTINCT company_tin_id
from tsso_registe)