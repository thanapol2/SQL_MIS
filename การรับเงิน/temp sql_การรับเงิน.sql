-- 20-22
select  budget_year as FISCAL_YEAR,
		to_date('01+10-'||budget_year,'dd-mm-yyyy') as start_date,
		to_date('31+12-'||budget_year,'dd-mm-yyyy') as end_date, -- wait confirm
		sysdate as update_date,
		budget_month_cd as month_id,
		TO_CHAR(to_date(budget_month_cd,'mm'), 'MON')  AS month_short_name,
		REGION_CD as REGION_NAME,
		province_name as PROVINCE_OWRTAX_NAME,
		REG_NAME as CUS_NAME,
		FACTORY_NAME as cus_store_name,
		CUR_YEAR_TAX_1,
		round((CUR_YEAR_TAX_1/'1000000'),6) as CUR_YEAR_TAX_2,
		PRIOR_YEAR_TAX_1,
		round((PRIOR_YEAR_TAX_1/'1000000'),6) as PRIOR_YEAR_TAX_2,
		'' as INC_TYPE,  -- need master
		'' as rank
from (select cur.budget_month_cd,cur.budget_year,office.REGION_CD,office.province_name,reg.REG_NAME,
		reg.FACTORY_NAME, sum(CUR_YEAR_TAX_1) as CUR_YEAR_TAX_1, sum(PRIOR_YEAR_TAX_1) as PRIOR_YEAR_TAX_1
		from (select cur.budget_month_cd,cur.budget_year,cur.offcode_own,
				cur.product_code,cur.Tax_AMT as CUR_YEAR_TAX_1,nvl(old.Tax_AMT,0) as PRIOR_YEAR_TAX_1
				from PRC_WRITE_FILE_1MONTHLY cur
				left join PRC_WRITE_FILE_1MONTHLY old
				on cur.budget_month_cd = old.budget_month_cd
				and cur.budget_year = old.budget_year+1
				-- and cur.province_own_cd = old.province_own_cd
				-- and cur.REGION_OWN_CD = old.REGION_OWN_CD
				and cur.offcode_own = old.offcode_own
				and cur.product_code = old.product_code) core
		inner join PRC_WRITE_FILE_4PRODUCT PRO
		on pro.product_code = mon.product_code
		inner join PRC_WRITE_FILE_5REGISTER REG
		on mon.reg_sk = reg.reg_sk
		inner join PRC_WRITE_FILE_6OFFICE office
		on office.offcode = core.offcode_own
		group by cur.budget_month_cd,cur.budget_year,office.REGION_CD,office.province_name,reg.REG_NAME,reg.FACTORY_NAME
	)


-- 19
select  budget_year as FISCAL_YEAR,
		to_date('01+10-'||budget_year,'dd-mm-yyyy') as start_date,
		to_date('31+12-'||budget_year,'dd-mm-yyyy') as end_date, -- wait confirm
		sysdate as update_date,
		budget_month_cd as month_id,
		TO_CHAR(to_date(budget_month_cd,'mm'), 'MON')  AS month_short_name,
		REGION_CD as REGION_NAME,
		province_name as PROVINCE_OWRTAX_NAME,
		REG_NAME as CUS_NAME,
		band.BRAND_NAME, -- wait confirm
		--'' as INC_TYPE_ID
		--GROUP_NAME as INC_TYPE,
		FACTORY_NAME as cus_store_name
		CUR_YEAR_TAX_1,
		round((CUR_YEAR_TAX_1/'1000000'),6) as CUR_YEAR_TAX_2,
		TO_CHAR(to_date(budget_month_cd,'mm'), 'MONTH')  AS MONTH_LONG_NAME,
		'' as rank
from (select budget_year,budget_month_cd,office.REGION_CD,office.province_name,reg.REG_NAME,band.BRAND_NAME,FACTORY_NAME,CUR_YEAR_TAX_1
		from (select budget_month_cd,budget_year,offcode_own,product_code,Tax_AMT as CUR_YEAR_TAX_1
				from PRC_WRITE_FILE_1MONTHLY )core
		inner join PRC_WRITE_FILE_4PRODUCT PRO
		on pro.product_code = mon.product_code
		inner join PRC_WRITE_FILE_5REGISTER REG
		on mon.reg_sk = reg.reg_sk
		inner join PRC_WRITE_FILE_6OFFICE office
		on office.offcode = core.offcode_own
		inner join PRC_WRITE_FILE_7BRAND band
		on band.BRAND_CD = core.BRAND_CD
		group by core.budget_year,core.budget_month_cd,office.REGION_CD,office.province_name,reg.REG_NAME,band.BRAND_NAME,FACTORY_NAME
		) ;


-+18

select  core.budget_year as FISCAL_YEAR,
		to_date('01+10-'||core.budget_year,'dd-mm-yyyy') as start_date,
		to_date('31+12-'||core.budget_year,'dd-mm-yyyy') as end_date, -- wait confirm
		sysdate as update_date,
		core.budget_month_cd as month_id,
		TO_CHAR(to_date(cur_core.budget_month_cd,'mm'), 'MON')  AS month_short_name,
		office.REGION_CD as REGION_NAME,
		office.province_name as PROVINCE_OWRTAX_NAME,
		reg.REG_NAME as CUS_NAME,
		core.CUR_YEAR_TAX_1,
		round((CUR_YEAR_TAX_1/'1000000'),6) as CUR_YEAR_TAX_2,
		PRIOR_YEAR_TAX_1,
		round((PRIOR_YEAR_TAX_1/'1000000'),6) as PRIOR_YEAR_TAX_2,
		--core.CUR_YEAR_TAX_1 / core.CUR_YEAR_TAX_1 over (partition by province_name) as PERT_BY_ALTAX
from 
	(
		select budget_year,budget_month_cd,office.REGION_CD,office.province_name,reg.REG_NAME,
			sum(CUR_YEAR_TAX_1) as CUR_YEAR_TAX_1, sum(PRIOR_YEAR_TAX_1) as PRIOR_YEAR_TAX_1
		from (select cur.budget_month_cd,cur.budget_year,cur.offcode_own,cur.product_code,
				sum(cur.Tax_AMT) as CUR_YEAR_TAX_1,sum(nvl(old.Tax_AMT,0)) as PRIOR_YEAR_TAX_1
			from PRC_WRITE_FILE_1MONTHLY cur
			left join PRC_WRITE_FILE_1MONTHLY old
			on cur.budget_month_cd = old.budget_month_cd
			and cur.budget_year = old.budget_year+1
			-- and cur.province_own_cd = old.province_own_cd
			-- and cur.REGION_OWN_CD = old.REGION_OWN_CD
			and cur.offcode_own = old.offcode_own
			and cur.product_code = old.product_code
			group by cur.budget_month_cd,cur.budget_year,cur.offcode_own,cur.product_code) core
		inner join PRC_WRITE_FILE_4PRODUCT PRO
		on pro.product_code = mon.product_code
		inner join PRC_WRITE_FILE_5REGISTER REG
		on mon.reg_sk = reg.reg_sk
		inner join PRC_WRITE_FILE_6OFFICE office
		on office.offcode = core.offcode_own
		group by budget_month_cd,budget_year,offcode_own,product_code
	)
(select cur.budget_month_cd,cur.budget_year,cur.offcode_own,cur.product_code,sum(cur.Tax_AMT) as CUR_YEAR_TAX_1,sum(nvl(old.Tax_AMT,0)) as PRIOR_YEAR_TAX_1
		from PRC_WRITE_FILE_1MONTHLY cur
		left join PRC_WRITE_FILE_1MONTHLY old
		on cur.budget_month_cd = old.budget_month_cd
		and cur.budget_year = old.budget_year+1
		-- and cur.province_own_cd = old.province_own_cd
		-- and cur.REGION_OWN_CD = old.REGION_OWN_CD
		and cur.offcode_own = old.offcode_own
		and cur.product_code = old.product_code
		group by cur.budget_month_cd,cur.budget_year,cur.offcode_own,cur.product_code) core
inner join PRC_WRITE_FILE_4PRODUCT PRO
on pro.product_code = mon.product_code
inner join PRC_WRITE_FILE_5REGISTER REG
on mon.reg_sk = reg.reg_sk
inner join PRC_WRITE_FILE_6OFFICE office
on office.offcode = core.offcode_own;


-+16+17
select  core.budget_year as FISCAL_YEAR,
		to_date('01+10-'||core.budget_year,'dd-mm-yyyy') as start_date,
		to_date('31+12-'||core.budget_year,'dd-mm-yyyy') as end_date, -- wait confirm
		sysdate as update_date,
		core.budget_month_cd as month_id,
		TO_CHAR(to_date(cur_core.budget_month_cd,'mm'), 'MON')  AS month_short_name,
		office.REGION_CD as REGION_NAME,
		office.province_name as PROVINCE_OWRTAX_NAME,
		core.offcode_own as SUB_OFFCODE,
		'' as SUB_OFFCODE_NAME
		core.CUR_YEAR_TAX_1,
		'' as INC_TYPE_ID,
		pro.GROUP_NAME as INC_TYPE,
		round((CUR_YEAR_TAX_1/'1000000'),6) as CUR_YEAR_TAX_2,
		PRIOR_YEAR_TAX_1,
		round((PRIOR_YEAR_TAX_1/'1000000'),6) as PRIOR_YEAR_TAX_2,
		TO_CHAR(to_date(cur_core.budget_month_cd,'mm'), 'Q') AS quater_id,
		'ไตรมาสที่ '|| TO_CHAR(to_date(cur_core.month_id,'mm'), 'Q')AS quater_short_name
from (select cur.budget_month_cd,cur.budget_year,cur.offcode_own,cur.product_code,sum(cur.Tax_AMT) as CUR_YEAR_TAX_1,sum(nvl(old.Tax_AMT,0)) as PRIOR_YEAR_TAX_1
		from PRC_WRITE_FILE_1MONTHLY cur
		left join PRC_WRITE_FILE_1MONTHLY old
		on cur.budget_month_cd = old.budget_month_cd
		and cur.budget_year = old.budget_year+1
		-- and cur.province_own_cd = old.province_own_cd
		-- and cur.REGION_OWN_CD = old.REGION_OWN_CD
		and cur.offcode_own = old.offcode_own
		and cur.product_code = old.product_code
		group by cur.budget_month_cd,cur.budget_year,cur.offcode_own,cur.product_code) core
inner join PRC_WRITE_FILE_4PRODUCT PRO
on pro.product_code = mon.product_code
inner join PRC_WRITE_FILE_6OFFICE office
on office.offcode = core.offcode_own;


-- 14+15

select cur.budget_month_cd,cur.budget_year,cur.REGION_OWN_CD,cur.province_own_cd,cur.OFFCODE_OWN,cur.region_rec_cd,cur.province_rec_cd,cur.offcode_rec,cur.TAX_AMT
from PRC_WRITE_FILE_1MONTHLY cur

-- 13
ใช้ตาราง PRC_WRITE_FILE_1MONTHLY

-- 12
select  core.budget_year as FISCAL_YEAR,
		to_date('01+10-'||core.budget_year,'dd-mm-yyyy') as start_date,
		to_date('31+12-'||core.budget_year,'dd-mm-yyyy') as end_date, -- wait confirm
		sysdate as update_date,
		core.budget_month_cd as month_id,
		TO_CHAR(to_date(core.budget_month_cd,'mm'), 'MON')  AS month_short_name,
		office.REGION_CD as REGION_NAME,
		office.province_name as PROVINCE_OWRTAX_NAME,
		core.offcode_own as SUB_OFFCODE,
		office.offdesc as SUB_OFFCODE_NAME,
		FACTORY_NAME as cus_store_name,
		round((CUR_YEAR_TAX_1/'1000000'),6) as CUR_YEAR_TAX_2,
--		'' sum(CUR_YEAR_TAX_1) over (partition by REGION_CD) as CUR_BY_REGION
		round((PRIOR_YEAR_TAX_1/'1000000'),6) as PRIOR_YEAR_TAX_2,
		'' -- need confirm misunderstand
		'' -- need confirm misunderstand
from		
	(select cur.budget_month_cd,cur.budget_year,cur.offcode_own,
		cur.product_code,sum(cur.Tax_AMT) as CUR_YEAR_TAX_1,sum(nvl(old.Tax_AMT,0)) as PRIOR_YEAR_TAX_1
		from PRC_WRITE_FILE_1MONTHLY cur
		left join PRC_WRITE_FILE_1MONTHLY old
		on cur.budget_month_cd = old.budget_month_cd
		and cur.budget_year = old.budget_year+1
		-- and cur.province_own_cd = old.province_own_cd
		-- and cur.REGION_OWN_CD = old.REGION_OWN_CD
		and cur.offcode_own = old.offcode_own
		and cur.product_code = old.product_code
		group by cur.budget_month_cd,cur.budget_year,cur.offcode_own) core
inner join PRC_WRITE_FILE_6OFFICE office
on office.offcode = core.offcode_own
		
		
-- 11,9,7,5
--- Wait confirm table

-- 10 wait confirm
select  core.budget_year as FISCAL_YEAR,
		to_date('01+10-'||core.budget_year,'dd-mm-yyyy') as start_date,
		to_date('31+12-'||core.budget_year,'dd-mm-yyyy') as end_date, -- wait confirm
		sysdate as update_date,
		core.budget_month_cd as month_id,
		TO_CHAR(to_date(cur_core.budget_month_cd,'mm'), 'MON')  AS month_short_name,
		office.REGION_CD as REGION_NAME,
		office.province_name as PROVINCE_OWRTAX_NAME,
		pro.GROUP_NAME as INC_TYPE,
		round((CUR_YEAR_TAX_1/'1000000'),6) as CUR_YEAR_TAX_2,
		PRIOR_YEAR_TAX_1,
		round((PRIOR_YEAR_TAX_1/'1000000'),6) as PRIOR_YEAR_TAX_2,
		TO_CHAR(to_date(cur_core.budget_month_cd,'mm'), 'Q') AS quater_id,
		'ไตรมาสที่ '|| TO_CHAR(to_date(cur_core.month_id,'mm'), 'Q')AS quater_short_name
from (select cur.budget_month_cd,cur.budget_year,cur.offcode_own,cur.product_code,
		sum(cur.Tax_AMT) as CUR_YEAR_TAX_1,sum(nvl(old.Tax_AMT,0)) as PRIOR_YEAR_TAX_1
		from PRC_WRITE_FILE_1MONTHLY cur
		left join PRC_WRITE_FILE_1MONTHLY old
		on cur.budget_month_cd = old.budget_month_cd
		and cur.budget_year = old.budget_year+1
		-- and cur.province_own_cd = old.province_own_cd
		-- and cur.REGION_OWN_CD = old.REGION_OWN_CD
		and cur.offcode_own = old.offcode_own
		and cur.product_code = old.product_code
		group by cur.budget_month_cd,cur.budget_year,cur.offcode_own,cur.product_code) core
inner join PRC_WRITE_FILE_4PRODUCT PRO
on pro.product_code = mon.product_code
inner join PRC_WRITE_FILE_6OFFICE office
on office.offcode = core.offcode_own;

--8
-- ใช้ write group by region,year

--6 , 2
select  core.budget_year as FISCAL_YEAR,
		to_date('01+10-'||core.budget_year,'dd-mm-yyyy') as start_date,
		to_date('31+12-'||core.budget_year,'dd-mm-yyyy') as end_date, -- wait confirm
		sysdate as update_date,
		core.budget_month_cd as month_id,
		TO_CHAR(to_date(cur_core.budget_month_cd,'mm'), 'MON')  AS month_short_name,
		office.REGION_CD as REGION_NAME,
		office.province_name as PROVINCE_OWRTAX_NAME,
		core.GROUP_NAME as INC_TYPE,
		round((CUR_YEAR_TAX_1/'1000000'),6) as CUR_YEAR_TAX_2,
		round((PRIOR_YEAR_TAX_1/'1000000'),6) as PRIOR_YEAR_TAX_2,
		-- rank()
from(
	select 	core.budget_year,core.budget_month_cd,core.offcode_own,pro.GROUP_NAME,sum(CUR_YEAR_TAX_1),sum(PRIOR_YEAR_TAX_1)
	from (select cur.budget_month_cd,cur.budget_year,cur.offcode_own,cur.product_code,
		cur.Tax_AMT as CUR_YEAR_TAX_1,nvl(old.Tax_AMT,0) as PRIOR_YEAR_TAX_1
		from PRC_WRITE_FILE_1MONTHLY cur
		left join PRC_WRITE_FILE_1MONTHLY old
		on cur.budget_month_cd = old.budget_month_cd
		and cur.budget_year = old.budget_year+1
		-- and cur.province_own_cd = old.province_own_cd
		-- and cur.REGION_OWN_CD = old.REGION_OWN_CD
		and cur.offcode_own = old.offcode_own
		and cur.product_code = old.product_code) core
	inner join PRC_WRITE_FILE_4PRODUCT PRO
	on pro.product_code = mon.product_code
	group by core.budget_year,core.budget_month_cd,core.offcode_own,pro.GROUP_NAME) core
inner join PRC_WRITE_FILE_6OFFICE office
on office.offcode = core.offcode_own;


--4
-- ใช้ write group by region,year

--3,1
select  core.budget_year as FISCAL_YEAR,
		to_date('01+10-'||core.budget_year,'dd-mm-yyyy') as start_date,
		to_date('31+12-'||core.budget_year,'dd-mm-yyyy') as end_date, -- wait confirm
		sysdate as update_date,
		core.budget_month_cd as month_id,
		TO_CHAR(to_date(cur_core.budget_month_cd,'mm'), 'Q') AS quater_id,
		'ไตรมาสที่ '|| TO_CHAR(to_date(cur_core.month_id,'mm'), 'Q')AS quater_short_name,
		core.REGION_OWN_CD as REGION_NAME,
		core.CUR_YEAR_TAX_1,
		core.PRIOR_YEAR_TAX_1
from(
	select core.budget_year,core.budget_month_cd,core.REGION_OWN_CD,sum(cur.Tax_AMT) as CUR_YEAR_TAX_1,sum(nvl(old.Tax_AMT,0)) as PRIOR_YEAR_TAX_1
	from PRC_WRITE_FILE_1MONTHLY cur
	inner join PRC_WRITE_FILE_1MONTHLY old
	on cur.budget_month_cd = old.budget_month_cd
	and cur.budget_year = old.budget_year+1
	-- and cur.province_own_cd = old.province_own_cd
	-- and cur.REGION_OWN_CD = old.REGION_OWN_CD
	and cur.offcode_own = old.offcode_own
	and cur.product_code = old.product_code
	group by core.budget_year,core.budget_month_cd,core.REGION_OWN_CD) core
	
	