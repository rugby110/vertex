create or replace view vertex_fact_daily_gl_entries as

-- for credit_change table, need to do this for the three other CC tables as well and UNION them ...
/*
select cc.effective_day_id, -- dimension reference
  cc.credit_change_type_id,  -- dimension reference
  cc.accounting_category_id, -- dimension reference
  dim_ma.contract_entity_id, -- dimension reference
  0 as partner_id, -- dimension reference
  av.aggregate_version_id,
  SUM(case when cc.price > 0 then 1 else 0 end) as num_items_plus,
  SUM(case when cc.price > 0 then cc.price else 0 end) as total_amount_plus,
  SUM(case when cc.price <= 0 then 1 else 0 end) as num_items_minus,
  SUM(case when cc.price <= 0 then cc.price else 0 end) as total_amount_minus
from vertex_fact_credit_change cc
inner join vertex_dim_credit_change_type dim_cct on cc.credit_change_type_id = dim_cct.credit_change_type_id
left join vertex_dim_managed_account dim_ma on cc.fund_account_id = dim_ma.fund_account_id
inner join verse.verse_ods_kiva_gl_aggregate_version av on av.effective_day_id = cc.effective_day_id and cc.create_time between av.aggregation_start_time and av.aggregation_end_time
where av.verse_report_name = 'daily_gl_entries'
-- make sure we're only getting entries for dates after the accounting books closed
-- in theory the Kc layer is preventing the creation of any such entries, but just in case...
-- we base our closed/audited periods on KUF - don't grab entries created for dates before these times
-- we can't get to API_GLCompany::KUF_CORE_COMPANY_ID - so hard-coding 3 :-(
and (cc.effective_time > (select last_closed_period from verse.verse_ods_kiva_gl_company where id = 3) and dim_cct.enforce_closed_period = 'yes')
  or (cc.effective_time > (select last_audited_period from verse.verse_ods_kiva_gl_company where id = 3) and dim_cct.enforce_closed_period = 'audited_only')
	or (dim_cct.enforce_closed_period = 'no')
group by cc.effective_day_id, cc.credit_change_type_id, cc.accounting_category_id,
  dim_ma.contract_entity_id, av.aggregate_version_id
UNION ALL
*/

select lcc.effective_day_id,
  lcc.credit_change_type_id,
  lcc.accounting_category_id,
  lcc.contract_entity_id,
  lcc.partner_id,
  lcc.aggregate_version_id,
  lcc.num_items_plus,
  lcc.total_amount_plus,
  lcc.num_items_minus,
  lcc.total_amount_minus
from vertex_fact_daily_gl_ledger_credit_change lcc
left join vertex_materialized.vertex_dim_credit_change_type dim_cct on dim_cct.credit_change_type_id = lcc.credit_change_type_id
where (
  (lcc.effective_day_id > (select TO_CHAR(TO_TIMESTAMP(last_closed_period), 'YYYYMMDD')::INT from verse.verse_ods_kiva_gl_company where id = 3) and dim_cct.enforce_closed_period = 'yes')
  or (lcc.effective_day_id > (select TO_CHAR(TO_TIMESTAMP(last_audited_period), 'YYYYMMDD')::INT from verse.verse_ods_kiva_gl_company where id = 3) and dim_cct.enforce_closed_period = 'audited_only')
	or (dim_cct.enforce_closed_period = 'no')
)
;